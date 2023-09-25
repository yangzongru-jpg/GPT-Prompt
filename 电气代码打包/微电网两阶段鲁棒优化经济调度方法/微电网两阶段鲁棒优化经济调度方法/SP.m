function [u,UB] = SP(x)

%% 1.参数设置
%燃气轮机参数设置
pg_max=800;         %燃气轮机最大功率限制
pg_min=80;          %燃气轮机最小功率限制
a=0.67;             %燃气轮机成本系数a,b设置
b=0;

%蓄电池参数设置
ps_max=500;         %储能允许最大充放电给功率
Es_max=1800;        %蓄电池调度过程中允许的最大剩余容量
Es_min=400;         %蓄电池调度过程中允许的最小剩余容量
Es_0=1000;          %调度过程中初始容量
Ks=0.38;            %折算后充放电成本
yita=0.95;          %充放电效率

%需求响应负荷参数设置
K_DR=0.32;          %需求响应负荷单位调度成本
D_DR=2940;          %需求响应总用电需求
D_DR_min=50;        %需求响应用电需求最大值
D_DR_max=200;       %需求响应用电需求最小值

%配电网交互功率参数设置
pm_max=1500;        %微电网与配电网交互功率最大值

%配电网日前交易电价，为24*1向量
price = [0.48;0.48;0.48;0.48;0.48;0.48;0.48;0.9;1.35;1.35;1.35;0.9;0.9;0.9;0.9;0.9;0.9;0.9;1.35;1.35;1.35;1.35;1.35;0.48];

%光伏日前预测，为24*1向量
p_pv_forecast_0=1500*[  0         0         0         0         0    0.0465    0.1466    0.3135     0.4756    0.5213    0.6563    1.0000    0.7422    0.6817    0.4972    0.4629    0.2808    0.0948    0.0109         0         0         0         0         0]';
%p_pv_forecast=[0; 0; 0; 0; 0; 0; 40; 200; 425; 731; 884; 1180; 900; 830; 600; 510; 340; 50; 0; 0; 0; 0; 0; 0];      %初始最坏数据
%负荷日前预测，为24*1向量
p_l_forecast_0=1500*[ 0.4658    0.4601    0.5574    0.5325    0.5744    0.6061    0.6106    0.6636    0.7410    0.7080    0.7598    0.8766    0.7646    0.7511    0.6721    0.5869    0.6159    0.6378    0.6142    0.6752    0.6397    0.5974    0.5432    0.4803]';
%p_l_forecast=[400; 350; 320; 300; 300; 310; 451; 561; 605; 748; 720; 810; 891; 836; 770; 726; 775.5; 730; 790; 810; 850; 800; 505; 410];        %初始最坏数据
%
C=[];
c=[a*ones(1,24)     Ks*yita*ones(1,24)      (Ks/yita)*ones(1,24)        zeros(1,24)     K_DR*ones(1,48)     price'  -price'   zeros(1,48)];%子问题第一行约束等式右边的c
%% 2.变量设置
%对偶变量设置（决策形函数）
gamma=sdpvar(192,1);     
lamda=sdpvar(50,1);      
miu=sdpvar(192,1);        
pai=sdpvar(48,1);       

%二元变量B设置
%B=binvar(48,1);           %B为子问题初始二元变量，取到1即为最坏情况 

%% 3.1 设子问题第一行约束(对应式29第一行的变量)
%其中，D为192*240矩阵，d为192*1矩阵
D=[eye(24)  zeros(24,216);
  -eye(24)  zeros(24,216);
  zeros(24,24)   yita.*tril(ones(24,24),0)  -1/yita.*tril(ones(24,24),0) zeros(24,168);
  zeros(24,24)   -yita.*tril(ones(24,24),0)  1/yita.*tril(ones(24,24),0) zeros(24,168);
  zeros(24,72)   eye(24)   zeros(24,144);
  zeros(24,72)   -eye(24)  zeros(24,144);
  zeros(24,96)   eye(24)   zeros(24,120);
  zeros(24,120)   eye(24)   zeros(24,96);];

d=[pg_min.*ones(24,1);
   -pg_max.*ones(24,1);
   (Es_min-Es_0).*ones(24,1);
   -(Es_max-Es_0).*ones(24,1);
   D_DR_min.*ones(24,1);
   -D_DR_max.*ones(24,1);
   zeros(48,1)];

%其中，K为50*240矩阵，s为50*1矩阵
K=[zeros(1,24)   yita.*ones(1,24)  -1/yita.*ones(1,24) zeros(1,168);
   zeros(1,72)  ones(1,24)  zeros(1,144);
   zeros(24,72) eye(24)     eye(24)     -eye(24)    zeros(24,96);
   eye(24)     -eye(24)    eye(24)     -eye(24)    zeros(24,48)    eye(24) -eye(24)    eye(24) -eye(24)];
s=[0;
   2940;       %总的需求响应
    110
   100
    90
    80
   100
   100
   130
   100
   120
   160
   175
   200
   140
   100
   100
   120
   140
   150
   190
   200
   200
   190
    80
    60
     %每个调度时刻的期望需求响应
   zeros(24,1)];

%其中，G为192*240矩阵，h为192*1向量，F为192*48矩阵
G=[zeros(24,48)     eye(24)    zeros(24,168);
   zeros(24,48)     -eye(24)   zeros(24,168);
   zeros(24)        eye(24)    zeros(24,192);
   zeros(24)        -eye(24)   zeros(24,192);
   zeros(24,144)    eye(24)    zeros(24,72);
   zeros(24,144)    -eye(24)   zeros(24,72);
   zeros(24,168)    eye(24)    zeros(24,48);
   zeros(24,168)    -eye(24)   zeros(24,48)];
h=[zeros(72,1);
   -ps_max.*ones(24,1);
   zeros(72,1);
   -pm_max.*ones(24,1)];
F=[zeros(24,48);
   ps_max.*eye(24)  zeros(24,24);
   zeros(24,48);
   -ps_max.*eye(24) zeros(24,24);
   zeros(24,48);
   zeros(24,24)     pm_max*eye(24);
   zeros(24,48);
   zeros(24,24)     -pm_max*eye(24);];


%I为48*240矩阵，u为48*1向量
I=[zeros(24,192)    eye(24)     zeros(24);
   zeros(24,216)    eye(24)];

u0=[p_pv_forecast_0;p_l_forecast_0];
C = [C, D'*gamma+K'*lamda+G'*miu+I'*pai<=c'];     %子问题第一行约束

%% 
Dp_pv_max=0.15*1500*[     0         0         0         0         0    0.0465    0.1466    0.3135     0.4756    0.5213    0.6563    1.0000    0.7422    0.6817    0.4972    0.4629    0.2808    0.0948    0.0109         0         0         0         0         0]';
DPL_max=0.1*1500*[ 0.4658    0.4601    0.5574    0.5325    0.5744    0.6061    0.6106    0.6636    0.7410    0.7080    0.7598    0.8766    0.7646    0.7511    0.6721    0.5869    0.6159    0.6378    0.6142    0.6752    0.6397    0.5974    0.5432    0.4803]';
delta_u=[Dp_pv_max;DPL_max];%式29函数后面的Δu

BPV=binvar(24,1,'full');
BL=binvar(24,1,'full');

B=[BPV;BL];                 %式29函数后面的B'    
BB=sdpvar(48,1);%引入的辅助变量B’，记为BB

C = [C, gamma>=0];
C = [C, miu>=0];
%C = [C, lamda>=0];
%C = [C, pai>=0];
C = [C, BB>=0];
C = [C,BB<=1000000*B];
%C = [C, BB>=pai-10*(ones(48,1)-B)];
C = [C, pai-1000000*(1-B)<=BB,BB<=pai];
C = [C, sum(B(1:24,:))<=6];
C = [C, sum(B(25:48,:))<=12];

%L1=[ones(1,24) zeros(1,24)];
%L2=[zeros(1,24) ones(1,24)];
%C = [C, L1*B<=12];
%C = [C, L2*B<=12];

%% 4.目标函数

Z=-(d'*gamma+s'*lamda+(h-F*x)'*miu+u0'*B+delta_u'*BB)+6200;
% Z=-(d'*gamma+s'*lamda+(h-F*x)'*miu+u0'*pai+delta_u'*BB);
%% 5.求解

ops = sdpsettings('solver','cplex');  
result = optimize(C,Z,ops);

BBB=value(B);
BBBB=value(BB);
GAMMA=value(gamma);
LAMDA=value(lamda);
MIU=value(miu);
PAI=value(pai);
UB=value(Z);

for k=1:24
    p_pv(k,1)=p_pv_forecast_0(k,1)-BBB(k,1)*delta_u(k,1);
    PL(k,1)=p_l_forecast_0(k,1)+BBB(k+24,1)*delta_u(k+24,1);
end

u=[p_pv;PL];

%% 画图
% figure(6)
% plot(BBB(1:24),'r','linewidth',2)
% hold on
% plot(BBB(25:48),'b','linewidth',2)
% %hold on
% %plot(BBBB,'k','linewidth',3)

figure(6)
plot(p_pv,'k','linewidth',1)
hold on
plot(p_pv_forecast_0,'r.--','linewidth',1)
hold on
plot(p_pv_forecast_0+Dp_pv_max,'g.--','linewidth',1)
hold on
plot(p_pv_forecast_0-Dp_pv_max,'g.--','linewidth',1)
legend('光伏实际出力','光伏预测出力','光伏区间出力上限','光伏区间出力下限');
xlabel('时间/h')
ylabel('功率/kw')