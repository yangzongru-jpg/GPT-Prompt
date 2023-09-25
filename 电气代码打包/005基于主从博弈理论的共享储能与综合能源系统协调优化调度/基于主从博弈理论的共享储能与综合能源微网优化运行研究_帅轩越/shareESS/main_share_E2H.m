%% 基于主从博弈理论的共享储能与综合能源微网优化运行研究——帅轩越
%场景 4:含有共享储能和电制热设备

clc;clear;close all;% 程序初始化
%% 读取数据
shuju=xlsread('share+EtoH数据.xlsx'); %把一天划分为24小时
load_e=shuju(2,:); %初始电负荷
load_h=shuju(3,:); %初始热负荷
P_PV=shuju(4,:);    %光电预测
pe_grid_S=shuju(5,:); %电网售电价
pe_grid_B=shuju(6,:); %电网购电价
ph_max=shuju(7,:); %热价上限
ph_min=shuju(8,:); %热价下限

%% 主从博弈过程

F = 0.5;   % 缩放因子
CR = 0.9;  % 交叉因子
%参数设置
groupSize =40;        %个体数目(Number of individuals)
groupDimension=48;  %染色体长度
MAXGEN =80;      %最大遗传代数(Maximum number of generations)
v=zeros(groupSize,groupDimension);    % 变异种群
u=zeros(groupSize,groupDimension);    % 交叉种群
Unew=zeros(groupSize,groupDimension); % 边界处理后的种群
%初始种群
population = smartGroupInit(groupSize,groupDimension);% 初始化群体
gen=0;                                         %种群世代计数器
fitness=0; %初始适应度
user=0;%用户收益
while gen<MAXGEN
   gen=gen+1 
%计算目标函数值   
    [P_MT,F_user,F_share,Eload,Hload,ES,P_h,Prl,P_buy,P_sell] = computeObj(population,load_e,load_h,P_PV,pe_grid_B);
%变异操作
   v=mutate(population,F,MAXGEN,gen); %针对整个种群的变异
%交叉操作
   u=crossover(population,v,CR);
%边界处理
   Unew = boundaryprocess(u,pe_grid_S,pe_grid_B,ph_max,ph_min);
% 选择操作 (计算新的适应度)
[Newpopulation,fitbest,best] =select(Unew,population,P_MT,P_h,P_buy,pe_grid_S);
trace(gen,1)=gen; %赋值世代数
    population=Newpopulation;
    %追踪最优适应度和售电售热价
    if fitness<=fitbest
    fitness = fitbest;  
    trace(gen,2)=fitbest;
    remainbest=best;
    else
    trace(gen,2)=fitness;
    end
    trace(gen,3)=F_share; %共享储能商的收益
%追踪最优目标函数
if user<=F_user
    user=F_user;
    trace(gen,4)=F_user;%用户收益曲线
else
    trace(gen,4)=user;
end
end

%% 画图
figure(1)
plot(trace(:,2),'c-*','linewidth',2)
hold on
xlabel('迭代次数');
ylabel('综合能源系统目标函数');
yyaxis right
plot(trace(:,4),'g-*','linewidth',2);
ylabel('用户聚合商目标函数');
title('迭代过程');
legend('微网运营商收益曲线','用户收益曲线')

figure(2)
bar(P_PV)
hold on
plot(load_e,'g-*','linewidth',2)
hold on
plot(load_h,'y-*','linewidth',2)
hold on
xlabel('时间/h');
ylabel('曲线/kW');
legend('光伏出力','电负荷','热负荷');

figure(3)
bar(load_e-Eload);
hold on 
ylabel('负荷/kW');
yyaxis right
plot(shuju(5,:),'g-*','linewidth',2)
xlabel('时间/h');
ylabel('电价');
title('电负荷优化结果');
legend('负荷转移结果','市场电价');


figure(4)
bar(load_e,'b');
hold on
plot(Eload,'r-*','linewidth',2)
hold on 
xlabel('时间/h');
ylabel('电负荷/kW');
title('电负荷变化');
legend('原始电负荷值','优化电负荷值');


figure(5)
bar(load_h,'b');
hold on
plot(Hload,'r-*','linewidth',2)
hold on 
xlabel('时间/h');
ylabel('热负荷/kW');
title('热负荷变化');
legend('原始热负荷值','优化热负荷值');


figure(6)
xx=1:24;
stairs(pe_grid_S,'r--*','linewidth',2);
hold on
stairs(pe_grid_B,'b--*','linewidth',2);
hold on
stairs(best(1,xx),'y--','linewidth',2);
xlabel('时间/h');
ylabel('电价/元');
title('微网运营商电价');
legend('电网售电价','电网购电价','微网运营商售电价');


figure(7)
xx=1:24;
stairs(ph_min,'c--*','linewidth',2);
hold on
stairs(ph_max,'g--*','linewidth',2);
hold on
stairs(best(1,xx+24),'b--*','linewidth',2);
xlabel('时间/h');
ylabel('电价/元');
title('微网运营商热价');
axis([1,24,0.1,0.6]);
legend('热价下限','热价上限','微网聚合商售热价');

figure(8)
bar(ES,'stack')
hold on
xlabel('时间/h');
ylabel('功率/kW');
yyaxis right
plot(shuju(5,:),'r--*','linewidth',2)
xlabel('时间/h');
ylabel('电价');
title('共享储能聚合商');
legend('储能容量','市场电价');

xx=1:24;
PP=value([P_h;Prl]);
figure(9)
bar(PP',0.5,'stack');
hold on
plot(value(P_h+Prl),'g--*','linewidth',2);
legend('购入热功率','电制热出力','优化后的热负荷');
xlabel('时段');ylabel('功率/kW');


