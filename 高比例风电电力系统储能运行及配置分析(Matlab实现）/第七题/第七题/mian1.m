clc;
clear;
close all;
%% 此程序表示——不加储能、存在弃风弃负荷情况！！！
%% 定义
biaoge = xlsread('附件2');
Load = biaoge(:,2);
Wind = biaoge(:,3);
Load = Load(673:768);
Wind = Wind(673:768);
mpc = [600,300,150;
    180,90,45;
    0.72,0.75,0.79;
    786.8,451.32,1049.5;
    30.42,65.12,139.6;
    0.226,0.588,0.785];
tan = 0;
wind = [0.045,0.3];
loadloss = 8;
%% 求解
[Result,Cost,PDE,PWind,Loss] = Yalmip_Cplex1(Load,Wind,mpc,tan,wind,loadloss);
zongfeng = sum(Wind-PWind');
zongloss = sum(Loss);
%% 画图
figure(1);
bar(PDE(1,:));
hold on
bar(PWind);
%plot(Load-Loss','r-*');
plot(Load,'r-*');
plot(PDE(1,:)+PWind,'k--')
hold off
legend('一号机组','风电机组','负荷需求','总发电功率');
xlabel('时间/15min');
ylabel('功率/MW');
title('机组日发电计划成本');

figure(2);
plot(PWind,'r-^');
hold on
plot(Wind,'b--*');
hold off
legend('风电实际出力','风电功率情况');
xlabel('时间/15min');
ylabel('功率/MW');
title('风电情况');

figure(3);
plot(Wind-PWind','r-^');
hold on
plot(Loss,'b--*');
hold off
legend('弃风功率','弃负荷功率');
xlabel('时间/15min');
ylabel('功率/MW');
title('系统功率变化情况');
