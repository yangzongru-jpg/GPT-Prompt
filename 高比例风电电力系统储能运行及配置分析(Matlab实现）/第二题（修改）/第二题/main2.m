clc;
clear;
%% ���һ���ʺŵĽ��
biaoge = xlsread('����1');
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
%% ���
[Result,Cost,PDE,PWind,rate] = Yalmip_Cplex(Load,Wind,mpc,tan,wind);
fprintf('���װ���������Խ�������');
disp(rate);
%% ���ӻ�
figure(1);
plot(PWind);
hold on
plot(rate*Wind);
plot(PDE(1,:));
plot(PDE(2,:));
plot(Load);
hold off
legend('���ʵ�ʳ���','������','һ�Ż������','���Ż������','�������');
xlabel('ʱ��(15min)');
ylabel('����(MW)');
title('�ڶ������һ�ʽ��');

figure(2);
bar(rate*Wind-PWind');
legend('�������');
xlabel('ʱ��(15min)');
ylabel('����(MW)');