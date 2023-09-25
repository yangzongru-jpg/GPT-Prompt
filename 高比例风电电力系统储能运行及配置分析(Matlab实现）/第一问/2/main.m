clc;
clear;
%% ����
load One_day_load;
load One_day_Wind;
mpc = [600,300,150;
    180,90,45;
    0.72,0.75,0.79;
    786.8,451.32,1049.5;
    30.42,65.12,139.6;
    0.226,0.588,0.785];
tan = 0;
%% ���
[Cost,PDE] = Yalmip_Cplex(Load,mpc,tan);
%% ��ͼ
figure(1);
bar(PDE(1,:));
hold on
bar(PDE(2,:));
bar(PDE(3,:));
plot(Load,'r-*');
hold off
legend('һ�Ż���','���Ż���','���Ż���','��������');
xlabel('ʱ��(15min)');
ylabel('����(MW)');