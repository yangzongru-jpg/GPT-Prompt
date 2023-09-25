function [x, LB, y] = MP(u)
%% 设置参数
pm_max=1500;%联络线功率上限
eta=0.95;%储能充放电效率
p_g_max=800;%燃气轮机最大功率限制
p_g_min=80;%燃气轮机最小功率限制
ps_max=500;%储能允许最大充放电给功率
ES_max=1800;%蓄电池调度过程中允许的最大剩余容量
ES_min=400; %蓄电池调度过程中允许的最小剩余容量
ES0=1000; %调度过程中初始容量
DDR=2940;%需求响应总用电需求

DR_max=200;%需求响应用电需求最大值
DR_min=50; %需求响应用电需求最小值

a=0.67;
b=0;
KS=0.38;
KDR=0.32; %需求响应负荷单位调度成本
price = [0.48;0.48;0.48;0.48;0.48;0.48;0.48;0.9;1.35;1.35;1.35;0.9;0.9;0.9;0.9;0.9;0.9;0.9;1.35;1.35;1.35;1.35;1.35;0.48];
%这是个列向量（配电网日前交易电价）

PW_=[0.6564    0.6399    0.6079    0.5594    0.5869    0.5794    0.6138    0.6192   0.6811    0.6400    0.7855    0.7615    0.6861    0.8780    0.6715    0.7023    0.6464    0.6321    0.6819    0.6943    0.7405    0.6727    0.6822    0.6878];
%p_pv=1500*[     0         0         0         0         0    0.0465    0.1466    0.3135     0.4756    0.5213    0.6563    1.0000    0.7422    0.6817    0.4972    0.4629    0.2808    0.0948    0.0109         0         0         0         0         0];
%PL=1500*[ 0.4658    0.4601    0.5574    0.5325    0.5744    0.6061    0.6106    0.6636    0.7410    0.7080    0.7598    0.8766    0.7646    0.7511    0.6721    0.5869    0.6159    0.6378    0.6142    0.6752    0.6397    0.5974    0.5432    0.4803];
%这三个是横向量（p_pv是光伏发电，PL是固定日负荷）    
%MP这里没考虑p_pv和PL
P_DR=1*[110 100 90 80 100 100 130 100 120 160 175 200 140 100 100 120 140 150 190 200 200 190 80 60];
%这是个行向量(可转移负荷量)

%%设决策变量
p_ch=sdpvar(1,24,'full');%储能充电
p_dis=sdpvar(1,24,'full');%储能放电
us=binvar(1,24,'full');%充放电标识

p_buy=sdpvar(1,24,'full');%配网购电
p_sell=sdpvar(1,24,'full');%配网售电
um=binvar(1,24,'full');%购售电标识

%p_pv=sdpvar(1,24,'full');%光伏发电 
%pL=sdpvar(1,24,'full');%固定日负荷


p_g=sdpvar(1,24,'full');%分布式电源
PDR=sdpvar(1,24,'full');%可转移负荷
PDR1=sdpvar(1,24,'full');%可转移负荷辅助变量
PDR2=sdpvar(1,24,'full');%可转移负荷辅助变量

afa=sdpvar(1,1,'full');%式25的α


%% 构建矩阵
x=[us,um]';%第一阶段变量
y=[p_g,p_ch,p_dis,PDR,PDR1,PDR2,p_buy,p_sell]';%第二阶段变量 这里没有考虑最恶劣情况
%u=[p_pv,PL]';%不确定量。这里为确定量为最恶劣场景（子问题的解）
%MP没有考虑u=[p_pv,PL]'
Q01=[eye(24),zeros(24,24)];%us 其中eye（24）指返回24*24的单位矩阵
Q02=[zeros(24,24),eye(24)];%um

Q1=[eye(24),zeros(24,168)];%分布式电源约束的系数矩阵
Q2=[zeros(1,24),eta.*ones(1,24),-1/eta.*ones(1,24),zeros(1,120)];

Q31=[zeros(24,24),eye(24),zeros(24,144)];%p_ch9c 
Q32=[zeros(24,48),eye(24),zeros(24,120)];%p_dis

Q4=[zeros(24,24),eta.*tril(ones(24,24),0),-1/eta.*tril(ones(24,24),0),zeros(24,120)];
Q51=[zeros(24,144),eye(24),zeros(24,24)];%p_buy
Q52=[zeros(24,168),eye(24)];%p_sell

Q6=[eye(24),-eye(24),eye(24),-eye(24),zeros(24,24),zeros(24,24),eye(24),-eye(24)];

%Q7=[zeros(24,72),eye(24),-eye(24)];

Q8=[zeros(1,72),ones(1,24),zeros(1,96)];
Q9=[zeros(24,72),eye(24),zeros(24,96)];

Q101=[zeros(24,96),eye(24),zeros(24,72)];
Q102=[zeros(24,120),eye(24),zeros(24,48)];
Q103=[zeros(24,72),eye(24),eye(24),-eye(24),zeros(24,48)];

QCS=[zeros(24,24),KS*eta.*eye(24),KS*1/eta.*eye(24),zeros(24,120)];
QCDR=[zeros(24,96),KDR*eye(24),KDR*eye(24),zeros(24,48)];
QCM=[zeros(24,144),eye(24),-eye(24)];
QC=[a*ones(1,24),KS*eta.*ones(1,24),KS*1/eta.*ones(1,24),zeros(1,24),KDR*ones(1,24),KDR*ones(1,24),price'.*ones(1,24),-price'.*ones(1,24)];


G1=[eye(24),-eye(24)];

%T1=ps_max*[(1-us),us]';
%T2=pm_max*[(1-um),um]';


%% 增加原始约束
C=[-Q1*y>=-p_g_max];%分布式电源约束
C=C+[Q1*y>=p_g_min];

C=C+[-Q31*y-ps_max*Q01*x>=-ps_max];%储能约束
C=C+[-Q32*y>=-Q01*x*ps_max];
C=C+[Q31*y>=0];
C=C+[Q32*y>=0];
C=C+[Q2*y==0];%保证储能在调度前后能量相同
C=C+[-Q4*y>=-(ES_max-ES0)];
C=C+[Q4*y>=(ES_min-ES0)];

C=C+[-Q52*y-pm_max*Q02*x>=-pm_max];%配电网交互约束
C=C+[-Q51*y>=-Q02*x*pm_max];
C=C+[Q51*y>=0];
C=C+[Q52*y>=0];
C=C+[Q6*y+G1*u==0];

C=C+[Q8*y==DDR];%可转移负荷约束
C=C+[-Q9*y>=-DR_max];
C=C+[Q9*y>=DR_min];
C=C+[Q101*y>=0];
C=C+[Q102*y>=0];
%C=C+[Q9*y+Q101*y-Q102*y=P_DR];
C=C+[Q103*y==P_DR'];


%% 两阶段鲁棒优化模型
%cy
%Dy>=d
%Ky=g
%Fx+Gy>=h
%Ly+Yu=0

D=[-Q1;Q1;Q31;Q32;-Q4;Q4;Q51;Q52;-Q9;Q9;Q101;Q102];%D、K、F、G 和 Iu 为对应约束下变量的系数矩阵；d、h 为常数列向量
d=[-p_g_max*ones(24,1);p_g_min*ones(24,1);0*ones(24,1);0*ones(24,1);-(ES_max-ES0)*ones(24,1);(ES_min-ES0)*ones(24,1);0*ones(24,1);0*ones(24,1);-DR_max*ones(24,1);DR_min*ones(24,1);0*ones(24,1);0*ones(24,1)];

K=[Q2;Q8;Q103];
g=[0;DDR;P_DR'.*ones(24,1)];

F=[-ps_max*Q01;ps_max*Q01;-pm_max*Q02;pm_max*Q02];
G=[-Q31;-Q32;-Q52;-Q51];
h=[-ps_max*ones(24,1);0*ones(24,1);-pm_max*ones(24,1);0*ones(24,1)];

L=[Q6];
Y=[G1];

%CG=a*p_g+b;
%CS=KS*(p_ch+p_dis);
%CM=price.*(p_buy-p_sell);
%CDR=KDR*abs(PDR-P_DR);

CG=a*Q1*y;
%CS=KS*(1/eta.*Q32*y+eta.*Q31*y);
CS=QCS*y;
%CM=price.*(Q51*y-Q52*y);
% CM=price.*QCM*y;
%CDR=KDR*(Q101*y+Q102*y);
CDR=QCDR*y;

c=QC;%紧凑后的目标函数

C=C+[D*y>=d];%紧凑后的约束条件
C=C+[K*y==g];
C=C+[F*x+G*y>=h];
C=C+[L*y+Y*u==0];
C=C+[afa>=c*y];%这里的afa指的是式25的α
%% 进行求解,

Fj=afa;
%Fj=sum(CG)+sum(CM)+sum(CS)+sum(CDR);
ops = sdpsettings('solver','cplex');
result = optimize(C,Fj,ops);

%x_1=value(x);
result_p_ch=value(p_ch);
result_p_dis=value(-p_dis);
result_p_g=value(p_g);
result_p_buy=value(p_buy);
result_p_sell=value(-p_sell);
result_PDR=value(PDR);

result_us=value(us);
result_um=value(um);
x=value(x);
y=value(y);
LB=value(afa);
%PL1=PL+result_p_ch-result_p_dis-result_p_g;

figure(2)
bar(result_p_g,0.7,'b')
axis([1,24 0 1000])
legend('燃气轮机出力');
xlabel('时间/h')
ylabel('功率/kw')

figure(3)
plot(-result_p_buy,'-d')
xlim([1 24])
grid
hold on
plot(-result_p_sell,'-d')
legend('市场售电量','市场购电量');
xlabel('时间/h')
ylabel('功率/kw')

% stairs(-result_p_buy,'b','linewidth',2)
% hold on
% stairs(-result_p_sell,'g','linewidth',2)
% hold off

figure(4)
bar(-result_p_ch,0.75,'b')
hold on
bar(-result_p_dis,0.75,'g')
legend('充电功率','放电功率');
xlabel('时间/h')
ylabel('功率/kw')


figure(5)
xlim([1 24])
grid
plot(P_DR,'-d')
hold on
plot(result_PDR,'-d')
legend('可转移负荷','实际用电计划');
xlabel('时间/h')
ylabel('功率/kw')