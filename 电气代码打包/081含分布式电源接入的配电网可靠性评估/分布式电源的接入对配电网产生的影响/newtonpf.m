function [V, converged, i] = newtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt)
%   牛顿法解潮流的主程序
%   [V, converged, i] = newtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt)
%   输入参数有节点导纳矩阵，功率注入矩阵，电压向量，参考节点，pv节点，pq节点，选项等。

%% 默认输入元素个数。
if nargin < 7
    mpopt = mpoption;
end

%% 选项。最大迭代次数选项。显示输出选项等。
tol     = mpopt(2);
max_it  = mpopt(3);
verbose = mpopt(31);

%% 初始化  converged表示收敛标志  初始设定为不收敛。
converged = 0;
i = 0;
V = V0;
Va = angle(V);
Vm = abs(V);

%% 建立V矩阵的索引
npv = length(pv);
npq = length(pq);
j1 = 1;         j2 = npv;           %% j1:j2 - j1至j2为PV节点的电压相角
j3 = j2 + 1;    j4 = j2 + npq;      %% j3:j4 - j3至j4为pq节点的电压相角
j5 = j4 + 1;    j6 = j4 + npq;      %% j5:j6 - j5至j6为pq节点的电压幅值
%% 计算出误差
mis = V .* conj(Ybus * V) - Sbus;
F = [   real(mis([pv; pq]));
        imag(mis(pq))   ];

%% 检查是否收敛
normF = norm(F, inf);
if verbose > 1
    fprintf('\n it    max P & Q mismatch (p.u.)');
    fprintf('\n----  ---------------------------');
    fprintf('\n%3d        %10.3e', i, normF);
end
if normF < tol
    converged = 1;
    if verbose > 1
        fprintf('\nConverged!\n');
    end
end

%% 牛顿法进行迭代运算
while (~converged && i < max_it)
    %% 当没有到达最大迭代次数并且不收敛则一直迭代。
    i = i + 1;
    
    %% 调用dSbus_dV子程序形成雅克比矩阵。
    [dSbus_dVm, dSbus_dVa] = dSbus_dV(Ybus, V);
    
    j11 = real(dSbus_dVa([pv; pq], [pv; pq]));
    j12 = real(dSbus_dVm([pv; pq], pq));
    j21 = imag(dSbus_dVa(pq, [pv; pq]));
    j22 = imag(dSbus_dVm(pq, pq));
    
    J = [   j11 j12;
            j21 j22;    ];

    %% 表示修正方程
    dx = -(J \ F);

    %% 对电压向量进行修正
    if npv
        Va(pv) = Va(pv) + dx(j1:j2);
    end
    if npq
        Va(pq) = Va(pq) + dx(j3:j4);
        Vm(pq) = Vm(pq) + dx(j5:j6);
    end
    V = Vm .* exp(1j * Va);
    Vm = abs(V);            %% 对电压相角和幅值进行修正
    Va = angle(V);          

    %%重新计算误差F(x).
    mis = V .* conj(Ybus * V) - Sbus;
    F = [   real(mis(pv));
            real(mis(pq));
            imag(mis(pq))   ];

    %% 再次检验是否收敛。是否需要继续迭代
    normF = norm(F, inf);
    if verbose > 1
        fprintf('\n%3d        %10.3e', i, normF);
    end
    if normF < tol
        converged = 1;
        if verbose
            fprintf('\nNewton''s method power flow converged in %d iterations.\n', i);
        end
    end
end

if verbose
    if ~converged
        fprintf('\nNewton''s method power did not converge in %d iterations.\n', i);
    end
end