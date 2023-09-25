clc
clear
close all
%%运行潮流
t0 = clock;
%% 列索引
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;


casename = 'case9'; 
mpopt = mpoption;       %% use default options
%% 打印选项
verbose = mpopt(31);
%% 1.初始潮流
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
%% -----  输出结果  -----
[mpc.bus, mpc.gen, mpc.branch] = deal(bus, gen, branch);
printpf(mpc, 1, mpopt);



%% 2.加入分布式电源后潮流
% 读数据
fprintf('请输入分布式电源的节点位置，有功与无功大小    bus  Pg   Qg  ') 
DGs2=[0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0]
DGbus=input('请输入DG节点位置的值：');%4
DGPg=input('请输入DG有功大小的值：');%30
DGQg=input('请输入DG无功大小的值：');%30
DGs1=[DGbus DGPg DGQg] 
DGs=[DGs1,DGs2]
mpc.gen=[mpc.gen;DGs]

%% 转换为内部输入
[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);

%% 转换为pq,pv,参考节点
[ref, pv, pq] = bustypes(bus, gen);

%%电源信息
on = find(gen(:, GEN_STATUS) > 0);      %% 哪个电源在工作
gbus = gen(on, GEN_BUS);                %% 在那条母线



    %% 初始化
V0    = ones(size(bus, 1), 1);            %% flat start
%     V0  = bus(:, VM) .* exp(sqrt(-1) * pi/180 * bus(:, VA));
V0(gbus) = gen(on, VG) ./ abs(V0(gbus)).* V0(gbus);
    
        %% 建立导纳矩阵
[Ybus, Yf, Yt] = makeYbus(baseMVA, bus, branch);
        
        %% 计算母线功率注入（发电 - 负载）
Sbus = makeSbus(baseMVA, bus, gen);
        
        %% 潮流计算
[V, success, iterations] = newtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt);
V2=sqrt(abs(V).^2);
hold on
plot(V2,'-d')  
xlabel('节点号');
ylabel('电压分布');
title('分布式电源接入前后对比')
legend('分布式电源接入前','分布式电源接入后');

        %% update data matrices with solution
[bus, gen, branch] = pfsoln(baseMVA, bus, gen, branch, Ybus, Yf, Yt, V, ref, pv, pq);


mpc.et = etime(clock, t0);
mpc.success = success;


%% 输出结果
[mpc.bus, mpc.gen, mpc.branch] = deal(bus, gen, branch);
printpf(mpc, 1, mpopt);
