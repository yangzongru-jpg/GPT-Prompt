function [Cost,PDE] = Yalmip_Cplex(Load,mpc,tan)
%% 初始定义
yalmip;
T = 96; %调度周期
% 决策变量
P_DE = sdpvar(3,T,'full');
%% 约束
St = [];
for t = 1:T
    for i = 1:3
        St = [St, mpc(2,i) <= P_DE(i,t) <= mpc(1,i)];
    end
    St = [St, P_DE(1,t) + P_DE(2,t) + P_DE(3,t) - Load(t)*900 == 0];
end
%% 目标
Object = 0; % 总成本
F = 0;
Tan = 0;
% 煤耗量成本
for t = 1:T
    for i = 1:3
        F = F + 0.25*(mpc(6,i)*P_DE(i,t)^2 + mpc(5,i)*P_DE(i,t) + mpc(4,i));
    end
end
Object= (F/1000)*1.5*700; % 运行成本
% 产碳量
for t = 1:T
    for i = 1:3
        Tan = Tan + P_DE(i,t)*mpc(3,i)*0.25*tan;
    end
end
Object = Object + Tan; % 加上碳捕集成本
%% 求解
Option = sdpsettings('solver','cplex','debug',0);
tic;
Result = optimize(St,Object,Option);
fprintf('模型求解时间：')
toc;
%% 表达
fprintf('全天运行费用：');
disp(value(Object));
PDE = [value(P_DE)];
Cost = [value(Object),value(Tan),value((F/1000)*700),value((F/1000)*350)];



b=0  %总供电成本
b=b+((value(Tan)+value(F/1000)*700)+value((F/1000)*350))
a=0  %单位供电成本
a=a+(value(Tan)+value((F/1000)*700)+value((F/1000)*350))/(sum(Load)*900)
end

