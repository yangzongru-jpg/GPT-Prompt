clc;
clear;
close all;
%% 定义
biaoge = xlsread('附件1');
Load = biaoge(:,2)*900;
%Wind = biaoge(:,3)*600;
Wind = biaoge(:,3)*300;
mpc = [600,300,150;
    180,90,45;
    0.72,0.75,0.79;
    786.8,451.32,1049.5;
    30.42,65.12,139.6;
    0.226,0.588,0.785];
tan =60;
wind = [0.045,0.3];
loadloss = 8;
%% 求解
[Result,Cost,PDE,PWind,Loss] = Yalmip_Cplex(Load,Wind,mpc,tan,wind,loadloss);
zongfeng = sum(Wind-PWind');
qifeng=Wind-PWind'
zongloss = sum(Loss);
%% 画图
figure(1);
bar(PDE(1,:));
hold on
bar(PWind);
bar(PDE(2,:));
plot(Load-Loss','r-*');
plot(PDE(1,:)+PWind+PDE(2,:),'k--')
hold off
legend('一号机组','风电机组','二号机组','负荷需求','总发电功率');
xlabel('时刻/15min');
ylabel('功率/MW');
title('机组日发电计划曲线');

figure(2);
plot(PWind,'r-^');
hold on
plot(Wind,'b--*');
hold off
legend('风电实际出力','风电功率情况');
xlabel('时刻/15min');
ylabel('功率/MW');
title('风电情况');

figure(3);
plot(Wind-PWind','r-^');
hold on
plot(Loss,'b--*');
hold off
legend('弃风功率','弃负荷功率');
xlabel('时刻/15min');
ylabel('功率/MW');
title('弃功率情况');
