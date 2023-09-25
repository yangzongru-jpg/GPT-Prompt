function [Result,Cost,PDE,PWind,Loss] = Yalmip_Cplex1(Load,Wind,mpc,tan,wind,loadloss)
%% 初始定义
yalmip;
T = 96; %调度周期
% 决策变量
P_DE1 = sdpvar(1,T,'full');
P_Wind = sdpvar(1,T,'full');
P_loss = sdpvar(1,T,'full');
%% 约束
St = [];
for t = 1:T
    St = [St, mpc(2,1) <= P_DE1(t) <= mpc(1,1)];
    St = [St, 0<=P_Wind(t)<=Wind(t)];
    St = [St,0 <= P_loss(t) <= Load(t)];
    St = [St,-0.1 <= P_DE1(t) + P_Wind(t) - (Load(t) - P_loss(t)) <= 0.1];
end
%% 目标
Object = 0; % 总成本
F = 0;
Tan = 0;
WIND_yunxing = 0;  WIND_qifeng = 0; % 风电
Loss_cost = 0; % 弃负荷
% 煤耗成本
for t = 1:T
    F = F + 0.25*(mpc(6,1)*P_DE1(t)^2 + mpc(5,1)*P_DE1(t) + mpc(4,1));
end
Object = (F/1000)*1.5*700; % 运行成本
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
Object = Object + WIND_yunxing; % 风电运行
Object = Object + WIND_qifeng; % 弃风成本
% 弃负荷
for t = 1:T
    Loss_cost = Loss_cost +  P_loss(t)*loadloss*0.25*1000;
end
Object = Object + Loss_cost;
%% 求解
Option = sdpsettings('solver','cplex','debug',0);
tic;
Result = optimize(St,Object,Option);
fprintf('模型求解时间：')
toc;
%% 表达
fprintf('全天运行费用：');
disp(value(Object));
PDE = [value(P_DE1)];
PWind = value(P_Wind);
Loss = value(P_loss);
Cost = [value((F/1000)*1.5*700),value(Tan),value(WIND_yunxing),value(WIND_qifeng),value(Loss_cost)];
end



