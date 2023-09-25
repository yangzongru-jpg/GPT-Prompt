function Sbus = makeSbus(baseMVA, bus, gen)
%MAKESBUS  ��������ע�벿�ֵ�Sbus
%   Sbus = makeSbus(baseMVA, bus, gen) 

%% ������
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

%% ��Դ��Ϣ
on = find(gen(:, GEN_STATUS) > 0);      %% ����ĸ���Դ������
gbus = gen(on, GEN_BUS);                %% ������ĸ���ϣ�

%% ��������ע�벿��
nb = size(bus, 1);
ngon = size(on, 1);
Cg = sparse(gbus, (1:ngon)', ones(ngon, 1), nb, ngon);  %% �������
                                                       
Sbus =  ( Cg * (gen(on, PG) + 1j * gen(on, QG)) ... %%��Դ�͸��ɵĹ���ע��
           - (bus(:, PD) + 1j * bus(:, QD)) ) / ...  
        baseMVA;                                    
