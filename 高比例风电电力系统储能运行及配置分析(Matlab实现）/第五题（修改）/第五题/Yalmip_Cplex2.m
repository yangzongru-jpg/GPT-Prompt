function [Result,Cost,PDE,PWind,S_Bat,Bat_limit,P_Bat,Pdis,Pcha] = Yalmip_Cplex2(Load,Wind,mpc,tan,wind,Bat)
%% 初始定义
yalmip;
T = 96; %调度周期
% 决策变量
P_DE1 = sdpvar(1,T,'full');
P_Wind = sdpvar(1,T,'full');

P_Bat = sdpvar(1,T,'full'); %蓄电池出力
Pdis = sdpvar(1,T,'full'); %蓄电池放电
Pcha = sdpvar(1,T,'full'); %蓄电池充电
Temp_Battery = binvar(1,T,'full'); %充|放电标志（1放电，0充电）
S_Bat = sdpvar(1,1,'full'); % 储能容量
P_limit = sdpvar(1,1,'full'); % 储能功率约束
%% 约束
St = [];
St = [St, 0<=S_Bat<=1000000000, 0<=P_limit<=100000000]; % 暂时不设置上限
St = [St, -P_limit<=P_Bat<=P_limit, 0<=Pdis<=P_limit, -P_limit<=Pcha<=0];
for t = 1:T
    % 其他机组约束
    St = [St, mpc(2,1) <= P_DE1(t) <= mpc(1,1)];
    St = [St,0 <= P_Wind(t) <= Wind(t)];
    % St = [St,0 <= P_loss(t) <= Load(t)];
    % 储能情况
    St = [St,implies(Temp_Battery(t),[P_Bat(t) >= 0, Pdis(t) == P_Bat(t), Pcha(t) == 0])]; %放电约束
    St = [St,implies(1-Temp_Battery(t),[P_Bat(t) <= 0, Pcha(t) == P_Bat(t), Pdis(t) == 0])]; %充电约束
    St = [St,-0.35*S_Bat <= -sum(Pdis(1:t)/Bat(4) + Bat(4)*Pcha(1:t)) <= 0.55*S_Bat]; %蓄电池电量最大限制约束(0.05S-0.95S)
    % 功率平衡
    St = [St,-0.1 <= P_DE1(t) + P_Wind(t) + P_Bat(t) - Load(t) <= 0.1];
end
%% 目标
Object = 0; % 总成本
F = 0;
Tan = 0;
WIND_yunxing = 0;  WIND_qifeng = 0; % 风电
Loss_cost = 0; % 弃负荷
Cost_Bat = 0; % 储能成本
% 煤耗成本
for t = 1:T
    F = F + 0.25*(mpc(6,1)*P_DE1(t)^2 + mpc(5,1)*P_DE1(t) + mpc(4,1));
end
% Object = (F/1000)*1.5*700; % 运行成本
% 产碳量
for t = 1:T
    Tan = Tan + P_DE1(t)*mpc(3,1)*0.25*tan;
end
Object = Object + Tan;
% 风电成本
for t = 1:T
    WIND_yunxing = WIND_yunxing + (Wind(t)*1000) * wind(1)*0.25;
    WIND_qifeng = WIND_qifeng + ((Wind(t)-P_Wind(t))*1000) * wind(2)*0.25;
end
% Object = Object + WIND_yunxing; % 风电运行
% Object = Object + WIND_qifeng; % 弃风成本

% 储能成本 = 储能功率配置成本 + 储能容量配置成本 + 全天运行维护成本
Cost_Bat = (1000*Bat(1)/(10*365))*P_limit + (1000*Bat(2)/(10*365))*S_Bat;
for t = 1:T
    Cost_Bat = Cost_Bat + abs(P_Bat(t))*0.05*1000*0.25;
end
Object = Object + Cost_Bat;
%% 求解
Option = sdpsettings('solver','cplex','debug',0);
tic;
Result = optimize(St,Object,Option);
fprintf('模型求解时间：')
toc;
%% 表达
fprintf('全天运行费用：');
disp(value((F/1000)*1.5*700+WIND_yunxing+WIND_qifeng+Object));
PDE = value(P_DE1);
PWind = value(P_Wind);
S_Bat = value(S_Bat);
Bat_limit = value(P_limit);
P_Bat = value(P_Bat);
Pdis = value(Pdis);
Pcha = value(Pcha);
Cost = [value((F/1000)*1.5*700),value(Tan),value(WIND_yunxing),value(WIND_qifeng),value((1000*Bat(1)/(10*365))*P_limit),value((1000*Bat(2)/(10*365))*S_Bat)];
end



