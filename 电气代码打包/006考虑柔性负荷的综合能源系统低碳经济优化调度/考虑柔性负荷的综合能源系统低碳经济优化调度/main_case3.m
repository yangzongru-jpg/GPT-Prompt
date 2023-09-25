
%采用CPIEX求解某微网的运行优化情况，下层优化得出的微网向配电网购电或售电功率，以及各机组的出力
%基于能源集线器概念，结合需求侧柔性负荷的可平移、可转移、可削减特性，构建了含风光储、燃气轮机、柔性负荷等
%在内的 IES 模型。 综合考虑了系统运行成本和碳交易成本，建立了以总成本最低为优化目标的 IES 低碳经济
%调度模型，采用cplex求解器对算例进行求解。
%场景3 不考虑柔性负荷参与系统优化调度的情况
clc;clear;close all;
%读取数据 
%电负荷、热负荷、光伏、风机、购电价、售电价
e_load=[160	150	140	140	130	135	150	180	215	250	275	320	335	290	260	275	270	280	320	360	345	310	220	160];%电负荷
h_load=[135	140 150 135 140 120 115 100 115 115 160 180 190 170 140 130 145 200 220 230 160 150 140 130];%热负荷
ppv=[0 0 0	0 0	10 15 25 45 75 90 100 80 100 50  40 30 15 10 0 0 0 0 0  ];%光伏预测数据
pwt=[60 65  70 75 80 85 90 100 125 150 130 110 100 120 125 130 140 160 180 200 175 160 155 150];%风机预测数据
buy_price=[0.25	0.25 0.25 0.25 0.25 0.25 0.25 0.53 0.53 0.53 0.82 0.82 0.82 0.82 0.8 0.53 0.53 0.53 0.82 0.82 0.82 0.53 0.53 0.53];%购电价
sell_price=[0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.42 0.42 0.42 0.65 0.65 0.65 0.65 0.65 0.42 0.42 0.42 0.65 0.65 0.65 0.42 0.42 0.42];%售电价
%需求响应数据
Pcut=[10 10 10 10 10 10 15 15 25 50 50 50 50 50 50 50 50 50 50 50 40 40 15 10];%可削减电负荷
Temp_Pcut=binvar(1,24,'full'); % 电负荷削减标志
PPcut=sdpvar(1,24,'full');%电负荷消减量
n1=zeros(1,1);%消减连续
Hcut=[25 25 25 25 25 25 25 25 30 40 40 40 40 40 40 40 40 40 50 50 30 30 20 15];%可削减热负荷
Temp_Hcut=binvar(1,24,'full'); % 热负荷削减标志
HHcut=sdpvar(1,24,'full');%热负荷消减量
n2=zeros(1,1);%消减连续

Ptran=[0 0 0 0 0 0 0 0 0 0 0 0 25 25 25 25 0 0 0 0 0 0 0 0 ];%可转移电负荷
Temp_Ptran=binvar(1,24,'full'); % 可转移电负荷 转移标志
PPtran=sdpvar(1,24,'full');%电负荷转移量

Pshift1=[0 0 0 0 0 0 0 0 0 0 0 25 25 0 0 0 0 0 0 0 0 0 0 0 ];%可平移电负荷1
Temp_Pshift1=binvar(1,24,'full'); % 可平移电负荷1 平移标志
PPshift1=sdpvar(1,24,'full');%可平移电负荷1量
Pshift2=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  25 25 25 0 0 ];%可平移电负荷2
Temp_Pshift2=binvar(1,24,'full'); % 可平移电负荷2 平移标志
PPshift2=sdpvar(1,24,'full');%可平移电负荷2量
Hshift=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 45 45 45 0 0 0 0 ];%可平移热负荷
Temp_Hshift=binvar(1,24,'full'); % 可平移热负荷 平移标志
HHshift=sdpvar(1,24,'full');%可平移热负荷量

for i=1:24
    Pfix(i)=e_load(i)-Pshift1(i)-Pshift2(i)-Ptran(i)-Pcut(i);%基础电负荷
end
for i=1:24
    Hfix(i)=h_load(i)-Hshift(i)-Hcut(i);%基础热负荷
end


%定义机组变量
P_pv=sdpvar(1,24,'full');%光伏电输出功率
P_wt=sdpvar(1,24,'full');%风机电输出功率
P_mt=sdpvar(1,24,'full');%燃气轮机电输出功率
P_GB=sdpvar(1,24,'full');%燃气锅炉输出热功率

Pbuy=sdpvar(1,24,'full');%从电网购电电量
Psell=sdpvar(1,24,'full');%向电网售电电量
Pnet=sdpvar(1,24,'full');%与电网交换功率
Temp_net=binvar(1,24,'full'); % 购|售电标志

Pcharge=sdpvar(1,24,'full');%充电功率
UPcharge=binvar(1,24,'full');%充电标志  
Pdischarge=sdpvar(1,24,'full');%放电功率
UPdischarge=binvar(1,24,'full');%放电标志  
B=sdpvar(1,24,'full');%电储能余量

Hcharge=sdpvar(1,24,'full');%储热系统充热
Hdischarge=sdpvar(1,24,'full');%储热系统放热
UHcharge=binvar(1,24,'full'); %储热系统充热标志
UHdischarge=binvar(1,24,'full'); %储热系统放热标志
H=sdpvar(1,24,'full'); %热储能余量


%储能参数
%电储能参数
E_storage_max=0.95*100;E_storage_min=0.4*100;e_loss=0.001;e_charge=0.9;e_discharge=0.9;%电储能容量/自损/充电/放电
%热储能参数
H_storage_max=0.95*100;H_storage_min=0.4*100;h_loss=0.001;h_charge=0.9;h_discharge=0.9;%热储能容量//自损/充热/放热
%约束条件
Constraints =[];
 %% 电储能容量约束、SOC约束、充电约束、放电约束、充放电状态约束、爬坡约束
B(1,1)=E_storage_min;%电储能初始
 for t=2:25  %在一个周期内的充放电功率
    Constraints=[Constraints,(B(mod(t-1,24)+1)==(B(mod(t-2,24)+1)*(1-e_loss)+(e_charge*Pcharge(mod(t-2,24)+1)-(1/e_discharge)*Pdischarge(mod(t-2,24)+1))))];
 end
% % %   %全周期净交换功率为零
%     Constraints=[Constraints,B(1,24)==E_storage_min];%初始功率相等即可
for i=1:24
Constraints=[Constraints,E_storage_min<=B(1,i)<=E_storage_max];%容量约束限制
end
 for i=1:24
     Constraints=[Constraints,30*UPcharge(1,i)<=Pcharge(1,i)<=40*UPcharge(1,i)];%电储能充电约束
     Constraints=[Constraints,30*UPdischarge(1,i)<=Pdischarge(1,i)<=40*UPdischarge(1,i)];%电储能放电约束
 end
 %蓄电池充放电约束
 for i=1:24
     Constraints=[Constraints,UPcharge(1,i)+UPdischarge(1,i)<=1];   %不同时充放电 
 end
   Constraints=[Constraints,sum(UPcharge(1,1:24))+sum(UPdischarge(1,1:24))==16];%使用寿命小于24

 %% 热储能容量约束、SOC约束、充热约束、放热约束、充放热状态约束
H(1,1)=H_storage_min;%热储能初始
 for t=2:25  %在一个周期内的充放热功率
    Constraints=[Constraints,(H(mod(t-1,24)+1)==(H(mod(t-2,24)+1)*(1-h_loss)+(h_charge*Hcharge(mod(t-2,24)+1)-(1/h_discharge)*Hdischarge(mod(t-2,24)+1))))];
 end
% %  %全周期净交换功率为零
%    Constraints=[Constraints,H(1,24)==H_storage_min];%初始功率相等即可
for i=1:24
Constraints=[Constraints,H_storage_min<=H(1,i)<=H_storage_max];%容量约束限制
end
 for i=1:24
     Constraints=[Constraints,5*UHcharge(1,i)<=Hcharge(1,i)<=30*UHcharge(1,i)];%热储能充电约束
     Constraints=[Constraints,5*UHdischarge(1,i)<=Hdischarge(1,i)<=30*UHdischarge(1,i)];%热储能放电约束
 end
 %蓄热池充放电约束
 for i=1:24
     Constraints=[Constraints,UHcharge(1,i)+UHdischarge(1,i)<=1];   %不同时充放热 
 end
   Constraints=[Constraints,sum(UHcharge(1,1:24))+sum(UHdischarge(1,1:24))==16];%使用寿命小于24

%% 机组约束
for i=1:24
   Constraints = [Constraints,0<=P_pv(i)<=ppv(i)];%光伏上下限约束
    Constraints = [Constraints,0<=P_wt(i)<=pwt(i)];%风机上下限约束
   Constraints = [Constraints,0<=P_mt(i)<=65];%燃气轮机上下限约束
   Constraints = [Constraints,0<=P_GB(i)<=160];%燃气锅炉上下限约束
   Constraints = [Constraints, -160<=Pnet(i)<=160,0<=Pbuy(i)<=160, -160<=Psell(i)<=0]; %主网功率交换约束
   Constraints = [Constraints, implies(Temp_net(i),[Pnet(i)>=0,Pbuy(i)==Pnet(i),Psell(i)==0])]; %购电情况约束
   Constraints = [Constraints, implies(1-Temp_net(i),[Pnet(i)<=0,Psell(i)==Pnet(i),Pbuy(i)==0])]; %售电情况约束 
end 
 
%% 需求响应约束
% %% 可平移电负荷1量
%     Constraints= [Constraints,sum(Temp_Pshift1(1,1:24)) == 2,sum(Temp_Pshift1(1,5:21)) == 2];%可平移电负荷1 平移标志
%     for i=5:20 %时段区间为5~21-2+1
%    Constraints = [Constraints,sum(Temp_Pshift1(1,i:i+1)) >= 2*(Temp_Pshift1(1,i)-Temp_Pshift1(1,i-1))];%连续2个时段
%     end
%     for i=1:24
%        Constraints = [Constraints,PPshift1(1,i)== 25*Temp_Pshift1(1,i)];%可平移电负荷1量
%     end
% %% 可平移电负荷2量
%         Constraints = [Constraints,sum(Temp_Pshift2(1,1:24)) == 3,sum(Temp_Pshift2(1,7:23)) == 3];%可平移电负荷2 平移标志
%     for i=7:21 %时段区间为7~23-3+1
%     Constraints = [Constraints,sum(Temp_Pshift2(1,i:i+2)) >= 3*(Temp_Pshift2(1,i)-Temp_Pshift2(1,i-1)-Temp_Pshift2(1,i-2))];%连续3个时段
%     end
%        for i=1:24
%        Constraints = [Constraints,PPshift2(1,i)== 25*Temp_Pshift2(1,i)];%可平移电负荷2量
%        end
% %% 可平移热负荷量
%         Constraints = [Constraints,sum(Temp_Hshift(1,1:24)) == 3,sum(Temp_Hshift(1,5:21)) == 3];%可平移热负荷 平移标志
% 
%     for i=5:19%时段区间为5~21-3+1
%     Constraints = [Constraints,sum(Temp_Hshift(1,i:i+2)) >= 3*(Temp_Hshift(1,i)-Temp_Hshift(1,i-1))];%连续3个时段
%     end
%     for i=1:24
%        Constraints = [Constraints,HHshift(1,i)== 45*Temp_Hshift(1,i)];%可平移电负荷2量
%     end 
%     
%   %% 可转移电负荷(大于5自然会大于2)
%   for i=1:24
%       Constraints = [Constraints,Temp_Ptran(i)*8<=PPtran(i)<=Temp_Ptran(i)*26.7 ];%可转移电负荷
%   end
%       Constraints = [Constraints,sum(Temp_Ptran(1,1:24)) == 5,sum(Temp_Ptran(1,4:22)) ==5];%可转移电负荷
%             Constraints = [Constraints,sum(Temp_Ptran(1,1:24)) ==5];%可转移电负荷
%     for i=4:18 %时段区间为4~22-5+1
%     Constraints = [Constraints,sum(Temp_Ptran(1,i:i+4)) >= 5*(Temp_Ptran(1,i)-Temp_Ptran(1,i-1))];
%     end
% 
% 
% %% 可削减电负荷
% 
% Constraints=[Constraints,sum(Temp_Pcut)==8,sum(Temp_Pcut(1,5:22))==8];
% Constraints=[Constraints,2<=n1<=5];
%     for i=5:22-n1+1 %时段区间为5~22-n1+1
%     Constraints = [Constraints,sum(Temp_Pcut(1,i:i+n1-1)) >= n1*(Temp_Pcut(1,i)-Temp_Pcut(1,i-1))];
%     end
% for i=1:24
%        Constraints = [Constraints,0<=PPcut(1,i)<=Temp_Pcut(1,i)*0.9*Pcut(i)];%可消减电负荷
% end
% %% 可削减热负荷
% Constraints=[Constraints,sum(Temp_Hcut(1,1:24))==8,sum(Temp_Hcut(1,11:19))==8];
% Constraints=[Constraints,2<=n2<=5];
%     for i=11:19-n2+1 %时段区间为11~19-n2+1
%     Constraints = [Constraints,sum(Temp_Hcut(1,i:i+n1-1)) >= n1*(Temp_Hcut(1,i)-Temp_Hcut(1,i-1))];
%     end
% for i=1:24
%        Constraints = [Constraints,Temp_Hcut(1,i)*0<=HHcut(1,i)<=Temp_Hcut(1,i)*0.9*Hcut(i)];%可消减热负荷
% end
%% 电平衡
   for i=1:24       
   Constraints = [Constraints,P_mt(i)+P_pv(i)+P_wt(i)+Pnet(i)-Pcharge(1,i)+Pdischarge(1,i)==e_load(i)]; %电平衡约束
   Constraints = [Constraints,P_GB(i)+0.83*P_mt(i)/0.45-Hcharge(1,i)+Hdischarge(1,i)==h_load(i)]; %热平衡约束
   end
      
%% 目标函数
%% 从大电网的购电成本
C_gridbuy=0;
for i=1:24
    C_gridbuy=C_gridbuy+Pbuy(i)*buy_price(i);
end
%% 向大电网的售电成本
C_gridsell=0;
for i=1:24
    C_gridsell=C_gridsell+Psell(i)*sell_price(i);
end
%运行成本
C_OM=0;
for i=1:24
 C_OM=C_OM+0.72*P_pv(i)+0.52*P_wt(i);%风机光伏运维成本
end

%% 燃料成本
C_fuel=0;
for i=1:24
 C_fuel=C_fuel+2.5*P_GB(i)/9.7+2.5*P_mt(i)/0.45/9.7;%耗气成本
end
%% 储能运行成本
C_storge=0;
for i=1:24
 C_storge=C_storge+0.5*(Pcharge(i)+Pdischarge(i)+Hcharge(i)+Hdischarge(i));%储能运行成本
end

%% 补偿成本
C_L=0;
% for i=1:24
%     C_L=C_L+0.2*(PPshift1(i)+PPshift2(i))+0.1*HHshift(i)+0.3*PPtran(i)+0.4*PPcut(i)+0.2*HHcut(i);
% end
%% 碳交易成本

Q_carbon=0;%碳排放量-碳配额量(克)
for i=1:24
    Q_carbon=Q_carbon+(((1303-798)*(Pbuy(i)+abs(Psell(i)))+(564.7-424)*(P_GB(i)/9.7+P_mt(i)/0.45/9.7)+...
        (43-78)*P_wt(i)+(154.5-78)*P_pv(i)+91.3*(Pcharge(i)+Pdischarge(i))));
end

E_v=sdpvar(1,5);%每段区间内的长度,分为5段,每段长度是2000
lamda=0.15*10^(-3);%碳交易基价
Constraints=[Constraints,
   Q_carbon==sum(E_v),%总长度等于Q_carbon
   0<=E_v(1:4)<=120000,%除了最后一段，每段区间长度小于等于120000g
   0<=E_v(5),
  ];
%碳交易成本
C_CO2=0;
for v=1:5
    C_CO2=C_CO2+(lamda+(v-1)*0.25*lamda)*E_v(v);
end


F= C_OM+C_fuel+C_gridbuy+C_gridsell+C_storge+C_L+C_CO2;
ops = sdpsettings('solver','cplex', 'verbose', 2);%参数指定程序用cplex求解器
optimize(Constraints,F,ops)
% ops=sdpsettings('solver','cplex');%设置求解方式
% [model,recoveryalmip,diagnostic,internalmodel]=export(Constraints,F,ops);%转为cplex模型
% milpt=Cplex('milp for htc');
% milpt.Model.sense='minimize';
% milpt.Model.obj=model.f;
% milpt.Model.lb=model.lb;
% milpt.Model.ub=model.ub;
% milpt.Model.A=[model.Aineq;model.Aeq];
% milpt.Model.lhs=[-inf*ones(size(model.bineq,1),1);model.beq];
% milpt.Model.rhs=[model.bineq;model.beq];
% milpt.Model.ctype=model.ctype;
% milpt.writeModel('ab.lp');%输出cplex模型（注意大小写）
% milpt.solve();%模型求解

F=value(F)%成本
P_pv=value(P_pv);
P_wt=value(P_wt);
P_mt=value(P_mt);
P_GB=value(P_GB);
Pcharge=value(Pcharge);
Pdischarge=value(Pdischarge);
Hcharge=value(Hcharge);
Hdischarge=value(Hdischarge);
Pbuy=value(Pbuy);
Psell=value(Psell);
PPshift1=value(PPshift1);
PPshift2=value(PPshift2);
PPtran=value(PPtran);
PPcut=value(PPcut);
HHshift=value(HHshift);
HHcut=value(HHcut);

%% 画图

figure
ee=value([Pfix;Pcut;Pshift1;Pshift2;Ptran]);
bar(ee','stack');
legend('基础电负荷','可消减电负荷','可平移电负荷1','可平移电负荷2','可转移电负荷');
xlabel('时间/h');
ylabel('电负荷功率/kW');
title('优化前用户侧柔性电负荷分布');


figure
hh=value([Hfix;Hcut;Hshift]);
bar(hh','stack');
legend('基础热负荷','可消减热负荷','可平移热负荷');
xlabel('时间/h');
ylabel('热负荷功率/kW');
title('优化前用户侧柔性热负荷分布');

% for i=1:24
%     op_e_load(i)=Pfix(i)+Pcut(i)+PPshift1(i)+PPshift2(i)+PPtran(i)-PPcut(i);
% end
x=1:24;
figure
plot(x,e_load,'-rs',x,e_load,'-bo');
xlabel('时间/h');
ylabel('电负荷/kW');
title('需求响应前后电负荷曲线');
legend('优化前电负荷','优化后电负荷');

% for i=1:24
%     op_h_load(i)=Hfix(i)+Hcut(i)+HHshift(i)-HHcut(i);
% end
x=1:24;
figure
plot(x,h_load,'-rs',x,h_load,'-bo');
xlabel('时间/h');
ylabel('热负荷/kW');
title('需求响应前后热负荷曲线');
legend('优化前热负荷','优化后热负荷');


figure
stairs(x,buy_price,'-r')
hold on
stairs(x,sell_price,'-b')
hold on
title('价格曲线');
legend('购电价','售电价');

figure
plot(x,e_load,'-o')
hold on
plot(x,h_load,'-s')
hold on
plot(x,ppv,'-^')
hold on
plot(x,pwt,'-p')
title('价格曲线');
legend('电负荷','热负荷','光伏机组','风电机组');


b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
eee=value([Pbuy;Pdischarge;P_pv; P_mt;P_wt]);
eee1=value([Psell;-Pcharge;b;b;b]);
figure
bar(eee','stack');
hold on
plot(x,e_load,'-gs');
legend('电网交互功率','蓄电池充放电','光伏出力','燃气轮机供电','风电出力','电负荷需求');
bar(eee1','stack');
title('电负荷平衡');
xlabel('时段');ylabel('功率/kW');

b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
hhh=value([P_GB;Hdischarge;0.83*P_mt/0.45]);
hhh1=value([b;-Hcharge;b]);
figure
bar(hhh','stack');
hold on
plot(x,h_load,'-rs');
legend('燃气锅炉产热','热储能充放热','燃气轮机供热','热负荷需求');
bar(hhh1','stack');
title('热负荷平衡');
xlabel('时段');ylabel('功率/kW');


for i=1:24
    PPPcut(i)=Pcut(i)-0; %所剩的可消减电负荷
end
figure
ee=value([Pfix;PPPcut;Pshift1;Pshift2;Ptran]);
bar(ee','stack');
legend('基础电负荷','可消减电负荷','可平移电负荷1','可平移电负荷2','可转移电负荷');
xlabel('时间/h');
ylabel('电负荷功率/kW');
title('优化后用户侧柔性电负荷分布');

for i=1:24
    HHHcut(i)=Hcut(i)-0; %所剩的可消减热负荷
end
figure
hh=value([Hfix;HHHcut;Hshift]);
bar(hh','stack');
legend('基础热负荷','可消减热负荷','可平移热负荷');
xlabel('时间/h');
ylabel('热负荷功率/kW');
title('优化后用户侧柔性热负荷分布');
