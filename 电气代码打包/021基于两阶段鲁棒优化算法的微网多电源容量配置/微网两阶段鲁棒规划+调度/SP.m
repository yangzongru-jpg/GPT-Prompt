function [p_wt,p_pv,p_load,x,UB] = SP(ee_bat_int,p_wt_int,p_pv_int,p_g_int,LB,yita)
%% 1.设参
pm_max = 500;%联络线功率上限
p_bat_int = ee_bat_int*0.21;%假设储能的功率上限和容量上限有比值关系

ee0 = 0.55*ee_bat_int; %储能初始电量
eta = 0.95;%储能充放电效率
M = 100000;%一个极大正实数
c_wt_om = 0.0296;c_pv_om = 0.0096;c_g_om = 0.059;c_bat_om = 0.009;%运维成本系数
c_fuel = 0.6;%燃料成本系数
%% 2.设决策变量
p_ch = sdpvar(24,4);%储能充电
p_dis = sdpvar(24,4);%储能放电
uu_bat = binvar(24,4);%充放电标识

uu_m = binvar(24,4);%发电机标识
p_buy = sdpvar(24,4);%配网购电
p_sell = sdpvar(24,4);%配网售电

p_wt = sdpvar(24,4);
p_pv = sdpvar(24,4);
p_load = sdpvar(24,4);

p_g = sdpvar(24,4);%微型燃气轮机

%风光出力和电价（以春季典型日为例）
p_l = xlsread('四个典型日数据.xlsx','0%','B3:E26')*900;
max_p_wt = xlsread('四个典型日数据.xlsx','0%','H3:K26')*p_wt_int; 
max_p_pv = xlsread('四个典型日数据.xlsx','0%','N3:Q26')*p_pv_int; 
%price=xlsread('四个典型日数据.xlsx','电价','A2:A25');
price = [0.48;0.48;0.48;0.48;0.48;0.48;0.48;0.9;1.35;1.35;1.35;0.9;0.9;0.9;0.9;0.9;0.9;0.9;1.35;1.35;1.35;1.35;1.35;0.48];
%% 3.设约束
C = [];
load = p_l';
%储能功率约束
wwt = 0.05;wpv = 0.1;wl = 0.15;%不确定度
C = [C, (1 - wwt)*max_p_wt <= p_wt,p_wt <= (1 + wwt)*max_p_wt];%不确定性风
C = [C, (1 - wpv)*max_p_pv <= p_pv,p_pv <= (1 + wpv)*max_p_pv];%不确定性光
C = [C, (1 - wl)*load' <= p_load,p_load <= (1 + wl)*load'];%不确定性负荷
%设定对偶变量
lam1 = sdpvar(96,1);lam11 = sdpvar(96,1);
lam2 = sdpvar(192,1);lam21 = sdpvar(192,1);lam3 = sdpvar(4,1);
lam4 = sdpvar(192,1);lam41 = sdpvar(192,1);lam5 = sdpvar(96,1);
lam51 = sdpvar(96,1);lam6 = sdpvar(96,1);
%大m条件中的01变量
beta1 = binvar(96,1);beta11 = binvar(96,1);
beta2 = binvar(192,1);beta21 = binvar(192,1);beta3 = binvar(4,1);
beta4 = binvar(192,1);beta41 = binvar(192,1);beta5 = binvar(96,1);
beta51 = binvar(96,1);beta6 = binvar(96,1);beta7 = binvar(480,1);beta8 = binvar(288,1);

x = [p_buy(:,1)' p_sell(:,1)' p_g(:,1)' p_ch(:,1)' p_dis(:,1)' p_buy(:,2)' p_sell(:,2)' p_g(:,2)' p_ch(:,2)' p_dis(:,2)' p_buy(:,3)' p_sell(:,3)' p_g(:,3)' p_ch(:,3)' p_dis(:,3)' p_buy(:,4)' p_sell(:,4)' p_g(:,4)' p_ch(:,4)' p_dis(:,4)']';
u = [p_wt(:,1)' p_pv(:,1)' p_load(:,1)' p_wt(:,2)' p_pv(:,2)' p_load(:,2)' p_wt(:,3)' p_pv(:,3)' p_load(:,3)' p_wt(:,4)' p_pv(:,4)' p_load(:,4)']';
%x为变量，u为不确定性
P = [price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)...
     price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)...
     price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)... 
     price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)]';
%下面相关的计算参数和参考资料一致
Q1 = [              zeros(24,48) eye(24)      zeros(24,48) zeros(24,360);
      zeros(24,120) zeros(24,48) eye(24)      zeros(24,48) zeros(24,240);
      zeros(24,240) zeros(24,48) eye(24)      zeros(24,48) zeros(24,120);
      zeros(24,360) zeros(24,48) eye(24)      zeros(24,48)];
Q2 = [zeros(48,72) eye(48) zeros(48,360);
      zeros(48,120) zeros(48,72) eye(48) zeros(48,240);
      zeros(48,240) zeros(48,72) eye(48) zeros(48,120);
      zeros(48,360) zeros(48,72) eye(48)];
Q3 = [zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,360);
      zeros(1,120) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,240);
      zeros(1,240) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,120);
      zeros(1,360) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24)];
Q4 = [eye(48) zeros(48,72) zeros(48,360);
      zeros(48,120) eye(48) zeros(48,72) zeros(48,240);
      zeros(48,240) eye(48) zeros(48,72) zeros(48,120);
      zeros(48,360) eye(48) zeros(48,72)];
Q5 = [zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,360);
      zeros(24,120) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,240);
      zeros(24,240) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,120);
      zeros(24,360) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0)];
Q6 = [eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,360);
      zeros(24,120) eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,240);
      zeros(24,240) eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,120);
      zeros(24,360) eye(24) -eye(24) eye(24) -eye(24) eye(24)];
Q10=[eye(48) zeros(48,72) zeros(48,360);
      zeros(48,120) eye(48) zeros(48,72) zeros(48,240);
      zeros(48,240) eye(48) zeros(48,72) zeros(48,120);
      zeros(48,360) eye(48) zeros(48,72)];

G = [eye(24) eye(24) -eye(24) zeros(24,216);
     zeros(24,72) eye(24) eye(24) -eye(24) zeros(24,144);
     zeros(24,144) eye(24) eye(24) -eye(24) zeros(24,72);
     zeros(24,216) eye(24) eye(24) -eye(24)];
T2 = [uu_bat(:,1);(1-uu_bat(:,1));uu_bat(:,2);(1-uu_bat(:,2));uu_bat(:,3);(1-uu_bat(:,3));uu_bat(:,4);(1-uu_bat(:,4))].*p_bat_int;
T4 = [uu_m(:,1);1-uu_m(:,1);uu_m(:,2);1-uu_m(:,2);uu_m(:,3);1-uu_m(:,3);uu_m(:,4);1-uu_m(:,4)].*pm_max;
T5 = repmat(0.9*ee_bat_int-ee0,96,1);
T51 = repmat(0.1*ee_bat_int-ee0,96,1);

%% 增加原始约束
%微型燃气轮机上下限约束
C = [C, Q1*x <= p_g_int];
C = [C, Q1*x >= 0];
C = [C, Q2*x <= T2];
C = [C, Q2*x >= 0];
%充放电量平衡约束
C = [C, Q3*x == 0];
%配电网交互约束
C = [C, Q4*x <= T4];
C = [C, Q4*x >= 0];
%SOC约束
C = [C, Q5*x <= T5];
C = [C, Q5*x >= T51];
%功率平衡
C = [C, Q6*x + G*u == 0];%这里的u是定值

%kkt
C = [C, Q1'*lam1-Q1'*lam11+Q2'*lam2-Q2'*lam21+Q3'*lam3+Q4'*lam4-Q4'*lam41+Q5'*lam5-Q5'*lam51+Q6'*lam6>=-P];
 
C = [C, Q1*x-p_g_int>=-(1-beta1).*M,lam1<=beta1.*M];
C = [C, Q1*x<=beta11.*M,lam11>=-(1-beta11).*M];

C = [C, Q2*x-T2>=-(1-beta2).*M,lam2<=beta2.*M];
C = [C, Q2*x<=beta21.*M,lam21>=-(1-beta21).*M];

C = [C, Q4*x-T4>=-(1-beta4).*M,lam4<=beta4.*M];
C = [C, Q4*x<=beta41.*M,lam41>=-(1-beta41).*M];

C = [C, Q5*x-T5>=-(1-beta5).*M,lam5<=beta5.*M];
C = [C, Q5*x-T51<=beta51.*M,lam51>=-(1-beta51).*M]; 

C = [C, lam1>=0,lam11<=0,lam2>=0,lam21<=0,lam4>=0,lam41<=0,lam5>=0,lam51<=0];
C = [C, P+Q1'*lam1-Q1'*lam11+Q2'*lam2-Q2'*lam21+Q3'*lam3+Q4'*lam4-Q4'*lam41+Q5'*lam5-Q5'*lam51+Q6'*lam6<=M.*beta7,x<=M.*(1-beta7)];

 %春季典型日
obj_o = sum(sum(repmat(price,1,4).*(p_buy(:,:)-p_sell(:,:)))+c_fuel*sum(p_g(:,1))+...%购售电成本和燃料成本
        sum(c_wt_om*p_wt(:,:))+sum(c_pv_om*p_pv(:,:))+sum(c_g_om*p_g(:,:))+sum(c_bat_om*p_dis(:,:))+sum(c_bat_om*p_ch(:,:)));%+...%运维成本
        %c_bat(1,1)/3*ee_bat_int*k_suo;%储能寿命损耗成本 
Cj = -obj_o;
ops = sdpsettings('solver','cplex');
reuslt = optimize(C,Cj,ops);
ops.cplex.exportmodel='abcd.lp';
Q=value(Cj);
UB=LB-yita-Q;
%wwt=value(wwt);wpv=value(wpv);wl=value(wl);
p_wt=value(p_wt);p_pv=value(p_pv);p_load=value(p_load);
x=value(x);

% figure(6)
% % [ss,gg]=meshgrid(1:4,1:24 );
% % mesh(gg,ss,pload);
% plot(pload)
% xlabel('微网编号');
% ylabel('时刻');
% % zlabel('负荷调度结果');
% title('负荷调度结果图');

