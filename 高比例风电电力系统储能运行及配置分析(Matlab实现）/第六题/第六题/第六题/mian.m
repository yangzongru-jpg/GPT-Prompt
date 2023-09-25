clc;
clear;
close all;
%% 
biaoge = xlsread('附件1');
Load = biaoge(:,2)*900;
mpc = [600,300,150;
    180,90,45;
    0.72,0.75,0.79;
    786.8,451.32,1049.5;
    30.42,65.12,139.6;
    0.226,0.588,0.785];
tan = 60;
wind = [0.045,0.3];
loadloss = 8;
tan = 60;
wind = [0.045,0.3];
loadloss = 8;
Bat =[3000,3000,0.05,0.9,0.4]; % [单位功率成本、单位能量成本、单位运维成本、充放电功率、初始容量]
% 注：储能电池初始荷电状态为0.4、最大允许荷电状态为0.95、最小允许荷电状态为0.05

Total = cell(10,6); % 收集数据
%% 循环测试
rate = [0.1:0.1:1];
for i = 1:10
    Wind = biaoge(:,3)*900*rate(i);
    [Result,Cost,PDE,PWind,S_Bat,Bat_limit,P_Bat,Pdis,Pcha] = Yalmip_Cplex(Load,Wind,mpc,tan,wind,Bat);
    Total{i,1} = Cost;
    Total{i,2} = PDE;
    Total{i,3} = PWind;
    Total{i,4} = S_Bat;
    Total{i,5} = Bat_limit;
    Total{i,6} = [P_Bat;Pdis;Pcha];
end
%% 可视化
% 图一、二及相关数据准备
Mei_Hao = [];Tan_BJ = [];WIND_yunxing = [];
WIND_qifeng = [];Bat_Pcost = [];Bat_Scost=[];
S_Bat = [];Bat_limit=[];
for i = 1:10
    Mei_Hao =  [Mei_Hao,Total{i,1}(1)];
    Tan_BJ = [Tan_BJ,Total{i,1}(2)];
    WIND_yunxing = [WIND_yunxing,Total{i,1}(3)];
    WIND_qifeng = [WIND_qifeng,Total{i,1}(4)];
    Bat_Pcost = [Bat_Pcost,Total{i,1}(5)];
    Bat_Scost = [Bat_Scost,Total{i,1}(6)];
end
figure(1);
bar(Mei_Hao);
hold on
bar(Tan_BJ);
bar(WIND_yunxing);
bar(WIND_qifeng);
hold off
legend('煤耗成本','碳捕集成本','风电运行成本','弃风成本');
ylim([0,2.6*(10^6)]);
xlabel('时间/15min');
ylabel('成本/万元');
title('发电成本变化情况');

figure(2);
bar(Bat_Pcost+Bat_Scost);
legend('储能成本');
xlabel('时间/15min');
ylabel('成本/万元');

% figure(2);
% subplot(1,2,1)
% bar(Bat_Pcost,'r');
% legend('储能功率配置成本');
% xlabel('时间(15min)');
% ylabel('成本');
% subplot(1,2,2)
% bar(Bat_Scost,'b');
% legend('储能能量配置成本');
% xlabel('时间(15min)');
% ylabel('成本');




    