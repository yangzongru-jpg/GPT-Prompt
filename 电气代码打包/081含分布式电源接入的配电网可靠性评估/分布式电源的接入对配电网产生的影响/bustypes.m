function [ref, pv, pq] = bustypes(bus, gen)
%�����ο��ڵ㣬pq�ڵ��pv�ڵ�
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
nb = size(bus, 1);
ng = size(gen, 1);
Cg = sparse(gen(:, GEN_BUS), (1:ng)', gen(:, GEN_STATUS) > 0, nb, ng);  
                                        
bus_gen_status = Cg * ones(ng, 1);     

ref = find(bus(:, BUS_TYPE) == REF & bus_gen_status);   %% �ο��ڵ�����
pv  = find(bus(:, BUS_TYPE) == PV  & bus_gen_status);   %% PV �ڵ�����
pq  = find(bus(:, BUS_TYPE) == PQ | ~bus_gen_status);   %% PQ �ڵ�����

%% ���û�к��ʵĲο��ڵ������ѡ��
if isempty(ref)
    ref = pv(1);                %% ѡȡ��һ��PV�ڵ�
    pv = pv(2:length(pv));      %% ������pv�ڵ���ɾ��
end
