clc
clear
close all
%%���г���
t0 = clock;
%% ������
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;


casename = 'case9'; 
mpopt = mpoption;       %% use default options
%% ��ӡѡ��
verbose = mpopt(31);
%% 1.��ʼ����
mpc = loadcase(casename);
mpc.branch
[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);
[ref, pv, pq] = bustypes(bus, gen);
[Ybus, Yf, Yt] = makeYbus(baseMVA, bus, branch);
Sbus = makeSbus(baseMVA, bus, gen);
V0    = ones(size(bus, 1), 1);   
[V, success, iterations] = newtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt);
V1=sqrt(abs(V).^2);
figure
plot(V1,'-*')
[bus, gen, branch] = pfsoln(baseMVA, bus, gen, branch, Ybus, Yf, Yt, V, ref, pv, pq);
mpc.et = etime(clock, t0);
mpc.success = success;
%% -----  ������  -----
[mpc.bus, mpc.gen, mpc.branch] = deal(bus, gen, branch);
printpf(mpc, 1, mpopt);



%% 2.����ֲ�ʽ��Դ����
% ������
fprintf('������ֲ�ʽ��Դ�Ľڵ�λ�ã��й����޹���С    bus  Pg   Qg  ') 
DGs2=[0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0]
DGbus=input('������DG�ڵ�λ�õ�ֵ��');%4
DGPg=input('������DG�й���С��ֵ��');%30
DGQg=input('������DG�޹���С��ֵ��');%30
DGs1=[DGbus DGPg DGQg] 
DGs=[DGs1,DGs2]
mpc.gen=[mpc.gen;DGs]

%% ת��Ϊ�ڲ�����
[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);

%% ת��Ϊpq,pv,�ο��ڵ�
[ref, pv, pq] = bustypes(bus, gen);

%%��Դ��Ϣ
on = find(gen(:, GEN_STATUS) > 0);      %% �ĸ���Դ�ڹ���
gbus = gen(on, GEN_BUS);                %% ������ĸ��



    %% ��ʼ��
V0    = ones(size(bus, 1), 1);            %% flat start
%     V0  = bus(:, VM) .* exp(sqrt(-1) * pi/180 * bus(:, VA));
V0(gbus) = gen(on, VG) ./ abs(V0(gbus)).* V0(gbus);
    
        %% �������ɾ���
[Ybus, Yf, Yt] = makeYbus(baseMVA, bus, branch);
        
        %% ����ĸ�߹���ע�루���� - ���أ�
Sbus = makeSbus(baseMVA, bus, gen);
        
        %% ��������
[V, success, iterations] = newtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt);
V2=sqrt(abs(V).^2);
hold on
plot(V2,'-d')  
xlabel('�ڵ��');
ylabel('��ѹ�ֲ�');
title('�ֲ�ʽ��Դ����ǰ��Ա�')
legend('�ֲ�ʽ��Դ����ǰ','�ֲ�ʽ��Դ�����');

        %% update data matrices with solution
[bus, gen, branch] = pfsoln(baseMVA, bus, gen, branch, Ybus, Yf, Yt, V, ref, pv, pq);


mpc.et = etime(clock, t0);
mpc.success = success;


%% ������
[mpc.bus, mpc.gen, mpc.branch] = deal(bus, gen, branch);
printpf(mpc, 1, mpopt);
