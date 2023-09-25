function [bus, gen, branch] = pfsoln(baseMVA, bus0, gen0, branch0, Ybus, Yf, Yt, V, ref, pv, pq)
%PFSOLN  用潮流计算的解更新矩阵
%   [bus, gen, branch] = pfsoln(baseMVA, bus0, gen0, branch0, ...
%                                   Ybus, Yf, Yt, V, ref, pv, pq)
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

%%初始化返回值
bus     = bus0;
gen     = gen0;
branch  = branch0;

%%-更新电压矢量。
bus(:, VM) = abs(V);
bus(:, VA) = angle(V) * 180 / pi;


%% 电源信息
on = find(gen(:, GEN_STATUS) > 0);      %% 哪个电源在运行中
gbus = gen(on, GEN_BUS);                %% 在哪个节点
refgen = find(gbus == ref);             %% 哪个是发电机参考节点

%% 计算总注入功率
Sg = V(gbus) .* conj(Ybus(gbus, :) * V);

%% 更新每个电源的Qg 
gen(:, QG) = zeros(size(gen, 1), 1);                %% zero out all Qg
gen(on, QG) = imag(Sg) * baseMVA + bus(gbus, QD);   %% inj Q + local Qd
if length(on) > 1
    %%建立联络矩阵   再i,j都运行中的情况下i, j 为 1 
    nb = size(bus, 1);
    ngon = size(on, 1);
    Cg = sparse((1:ngon)', gbus, ones(ngon, 1), ngon, nb);
    ngg = Cg * sum(Cg)';    %% ngon x 1, number of gens at this gen's bus
    gen(on, QG) = gen(on, QG) ./ ngg;
    
    
    %% divide proportionally
    Cmin = sparse((1:ngon)', gbus, gen(on, QMIN), ngon, nb);
    Cmax = sparse((1:ngon)', gbus, gen(on, QMAX), ngon, nb);
    Qg_tot = Cg' * gen(on, QG);     %% nb x 1 vector of total Qg at each bus
    Qg_min = sum(Cmin)';            %% nb x 1 vector of min total Qg at each bus
    Qg_max = sum(Cmax)';            %% nb x 1 vector of max total Qg at each bus
    ig = find(Cg * Qg_min == Cg * Qg_max);  %% gens at buses with Qg range = 0
    Qg_save = gen(on(ig), QG);
    gen(on, QG) = gen(on, QMIN) + ...
        (Cg * ((Qg_tot - Qg_min)./(Qg_max - Qg_min + eps))) .* ...
            (gen(on, QMAX) - gen(on, QMIN));    %%    ^ avoid div by 0
    gen(on(ig), QG) = Qg_save;
end                                            

%% 更新电源供给的有功功率
gen(on(refgen(1)), PG) = real(Sg(refgen(1))) * baseMVA + bus(ref, PD);  %% inj P + local Pd
if length(refgen) > 1       %% 大于一个电源在参考节点
    %% subtract off what is generated by other gens at this bus
    gen(on(refgen(1)), PG) = gen(on(refgen(1)), PG) - sum(gen(on(refgen(2:length(refgen))), PG));
end

%%更新线路的潮流参数
out = find(branch(:, BR_STATUS) == 0);      %% out-of-service branches
br = find(branch(:, BR_STATUS));            %% in-service branches
Sf = V(branch(br, F_BUS)) .* conj(Yf(br, :) * V) * baseMVA; %% complex power at "from" bus
St = V(branch(br, T_BUS)) .* conj(Yt(br, :) * V) * baseMVA; %% complex power injected at "to" bus
branch(br, [PF, QF, PT, QT]) = [real(Sf) imag(Sf) real(St) imag(St)];
branch(out, [PF, QF, PT, QT]) = zeros(length(out), 4);