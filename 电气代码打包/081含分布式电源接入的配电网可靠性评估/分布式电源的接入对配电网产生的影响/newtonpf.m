function [V, converged, i] = newtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt)
%   ţ�ٷ��⳱����������
%   [V, converged, i] = newtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt)
%   ��������нڵ㵼�ɾ��󣬹���ע����󣬵�ѹ�������ο��ڵ㣬pv�ڵ㣬pq�ڵ㣬ѡ��ȡ�

%% Ĭ������Ԫ�ظ�����
if nargin < 7
    mpopt = mpoption;
end

%% ѡ�����������ѡ���ʾ���ѡ��ȡ�
tol     = mpopt(2);
max_it  = mpopt(3);
verbose = mpopt(31);

%% ��ʼ��  converged��ʾ������־  ��ʼ�趨Ϊ��������
converged = 0;
i = 0;
V = V0;
Va = angle(V);
Vm = abs(V);

%% ����V���������
npv = length(pv);
npq = length(pq);
j1 = 1;         j2 = npv;           %% j1:j2 - j1��j2ΪPV�ڵ�ĵ�ѹ���
j3 = j2 + 1;    j4 = j2 + npq;      %% j3:j4 - j3��j4Ϊpq�ڵ�ĵ�ѹ���
j5 = j4 + 1;    j6 = j4 + npq;      %% j5:j6 - j5��j6Ϊpq�ڵ�ĵ�ѹ��ֵ
%% ��������
mis = V .* conj(Ybus * V) - Sbus;
F = [   real(mis([pv; pq]));
        imag(mis(pq))   ];

%% ����Ƿ�����
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

%% ţ�ٷ����е�������
while (~converged && i < max_it)
    %% ��û�е����������������Ҳ�������һֱ������
    i = i + 1;
    
    %% ����dSbus_dV�ӳ����γ��ſ˱Ⱦ���
    [dSbus_dVm, dSbus_dVa] = dSbus_dV(Ybus, V);
    
    j11 = real(dSbus_dVa([pv; pq], [pv; pq]));
    j12 = real(dSbus_dVm([pv; pq], pq));
    j21 = imag(dSbus_dVa(pq, [pv; pq]));
    j22 = imag(dSbus_dVm(pq, pq));
    
    J = [   j11 j12;
            j21 j22;    ];

    %% ��ʾ��������
    dx = -(J \ F);

    %% �Ե�ѹ������������
    if npv
        Va(pv) = Va(pv) + dx(j1:j2);
    end
    if npq
        Va(pq) = Va(pq) + dx(j3:j4);
        Vm(pq) = Vm(pq) + dx(j5:j6);
    end
    V = Vm .* exp(1j * Va);
    Vm = abs(V);            %% �Ե�ѹ��Ǻͷ�ֵ��������
    Va = angle(V);          

    %%���¼������F(x).
    mis = V .* conj(Ybus * V) - Sbus;
    F = [   real(mis(pv));
            real(mis(pq));
            imag(mis(pq))   ];

    %% �ٴμ����Ƿ��������Ƿ���Ҫ��������
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