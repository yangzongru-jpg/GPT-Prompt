clc;
clear;
%% 定义
load One_day_load;
load One_day_Wind;
mpc = [600,300,150;
    180,90,45;
    0.72,0.75,0.79;
    786.8,451.32,1049.5;
    30.42,65.12,139.6;
    0.226,0.588,0.785];
tan = 0;
%% 求解
[Cost,PDE] = Yalmip_Cplex(Load,mpc,tan);

zongfuhe=0.25*sum(Load)
%% 画图
figure(1);
bar(PDE(1,:));
hold on
bar(PDE(2,:));
bar(PDE(3,:));
plot(Load,'r-*');
plot(PDE(1,:)+PDE(2,:)+PDE(3,:),'k--')
hold off
legend('一号机组','二号机组','三号机组','负荷需求','总发电功率');
xlabel('时段/15min');
ylabel('功率/MW');
title('机组日发电计划曲线');