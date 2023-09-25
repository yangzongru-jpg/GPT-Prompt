function [Ybus, Yf, Yt] = makeYbus(baseMVA, bus, branch)
%MAKEYBUS   形成节点导纳矩阵。
%   [Ybus, Yf, Yt] = makeYbus(baseMVA, bus, branch) 

%% constants
nb = size(bus, 1);          %% number of buses
nl = size(branch, 1);       %% number of lines

%% define named indices into bus, branch matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

%% check that bus numbers are equal to indices to bus (one set of bus numbers)
if any(bus(:, BUS_I) ~= (1:nb)')
    error('buses must appear in order by bus number')
end
%%      | If |   | Yff  Yft |   | Vf |
%%      |    | = |          | * |    |
%%      | It |   | Ytf  Ytt |   | Vt |
stat = branch(:, BR_STATUS);                    %% 找到线路的运行状态，运行为1
Ys = stat ./ (branch(:, BR_R) + 1j * branch(:, BR_X));  %% 导纳。
Bc = stat .* branch(:, BR_B);                           %% 电纳
tap = ones(nl, 1);                              %% 调相机调节比例t
i = find(branch(:, TAP));                       %% 
tap(i) = branch(i, TAP);                        %% 
tap = tap .* exp(1j*pi/180 * branch(:, SHIFT)); %% 
Ytt = Ys + 1j*Bc/2;
Yff = Ytt ./ (tap .* conj(tap));
Yft = - Ys ./ conj(tap);
Ytf = - Ys ./ tap;

%% 计算泄露元件并联导纳
Ysh = (bus(:, GS) + 1j * bus(:, BS)) / baseMVA; 

%% 建立联络矩阵
f = branch(:, F_BUS);                           %% 列出起点序号
t = branch(:, T_BUS);                           %%列出终点序号
Cf = sparse(1:nl, f, ones(nl, 1), nl, nb);      %% 联络矩阵中起点所在母线
Ct = sparse(1:nl, t, ones(nl, 1), nl, nb);      %% 联络终点所在母线


i = [1:nl; 1:nl]';                              
Yf = sparse(i, [f; t], [Yff; Yft], nl, nb);
Yt = sparse(i, [f; t], [Ytf; Ytt], nl, nb);

%% build Ybus
Ybus = Cf' * Yf + Ct' * Yt + ...                %% branch admittances
        sparse(1:nb, 1:nb, Ysh, nb, nb);        %% shunt admittance