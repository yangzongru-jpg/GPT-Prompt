clc;
clear;
%% 最后一个问号的解答
biaoge = xlsread('附件1');
Load = biaoge(:,2)*900;
Wind = biaoge(:,3)*300;
mpc = [600,300,150;
    180,90,45;
    0.72,0.75,0.79;
    786.8,451.32,1049.5;
    30.42,65.12,139.6;
    0.226,0.588,0.785];
tan =0;
wind = [0.045,0.3];
%% 求解
[Result,Cost,PDE,PWind,rate] = Yalmip_Cplex(Load,Wind,mpc,tan,wind);
fprintf('风电装机容量可以降低至：');
disp(rate);
%% 可视化
figure(1);
plot(PWind);
hold on
plot(rate*Wind);
plot(PDE(1,:));
plot(PDE(2,:));
plot(Load);
hold off
legend('风电实际出力','风电出力','一号机组出力','二号机组出力','负荷情况');
xlabel('时间(15min)');
ylabel('功率(MW)');
title('第二题最后一问结果');

figure(2);
bar(rate*Wind-PWind');
legend('弃风情况');
xlabel('时间(15min)');
ylabel('功率(MW)');