function [ref, pv, pq] = bustypes(bus, gen)
%创建参考节点，pq节点和pv节点
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
nb = size(bus, 1);
ng = size(gen, 1);
Cg = sparse(gen(:, GEN_BUS), (1:ng)', gen(:, GEN_STATUS) > 0, nb, ng);  
                                        
bus_gen_status = Cg * ones(ng, 1);     

ref = find(bus(:, BUS_TYPE) == REF & bus_gen_status);   %% 参考节点索引
pv  = find(bus(:, BUS_TYPE) == PV  & bus_gen_status);   %% PV 节点索引
pq  = find(bus(:, BUS_TYPE) == PQ | ~bus_gen_status);   %% PQ 节点索引

%% 如果没有合适的参考节点则从新选择
if isempty(ref)
    ref = pv(1);                %% 选取第一个PV节点
    pv = pv(2:length(pv));      %% 将它从pv节点中删除
end
