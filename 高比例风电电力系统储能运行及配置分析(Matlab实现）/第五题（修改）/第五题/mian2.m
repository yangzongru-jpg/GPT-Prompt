clc;
clear;
close all;
%% ����
%% �����Ϊ���˴��ܵ�
biaoge = xlsread('����1');
Load = biaoge(:,2)*900;
Wind = biaoge(:,3)*900;
mpc = [600,300,150;
    180,90,45;
    0.72,0.75,0.79;
    786.8,451.32,1049.5;
    30.42,65.12,139.6;
    0.226,0.588,0.785];
tan = 60;
wind = [0.045,0.3];
loadloss = 8;
Bat =[3000,3000,0.05,0.9,0.4]; % [��λ���ʳɱ�����λ�����ɱ�����λ��ά�ɱ�����ŵ繦�ʡ���ʼ����]
% ע�����ܵ�س�ʼ�ɵ�״̬Ϊ0.4���������ɵ�״̬Ϊ0.95����С����ɵ�״̬Ϊ0.05
%% ���
[Result,Cost,PDE,PWind,S_Bat,Bat_limit,P_Bat,Pdis,Pcha] = Yalmip_Cplex2(Load,Wind,mpc,tan,wind,Bat);
zongfeng = 0.25*sum(Wind-PWind');
qifeng=0.25*(Wind-PWind');

S = [];SOC = [];
SOC(1) = S_Bat*Bat(5);
for t = 1:96
    S(t) = S_Bat*Bat(5) - sum(Pdis(1:t)/Bat(4) + Bat(4)*Pcha(1:t));
    SOC(t+1) = S(t);
end
SOC = SOC/S_Bat;
%% ��ͼ
figure(1);
bar(PDE(1,:));
hold on
bar(PWind);
bar(P_Bat);
plot(Load,'r-*');
plot(PDE(1,:)+PWind+P_Bat,'k--')
hold off
legend('һ�Ż���','������','���ܵ��','��������','�ܷ��繦��');
xlabel('ʱ��/15min');
ylabel('����/MW');
title('�����շ���ƻ�����');

figure(2);
plot(PWind,'r-^');
hold on
plot(Wind,'b--*');
hold off
legend('���ʵ�ʳ���','��繦�����');
xlabel('ʱ��/15min');
ylabel('����/MW');
title('������');

figure(4);
plot(P_Bat,'LineWidth',2);
legend('���ܹ���');
xlabel('ʱ��/15min');
ylabel('����/MW');
title('����ϵͳ����');

figure(5);
plot(SOC,'LineWidth',2);
legend('��������/MW');
xlabel('ʱ��/15min');
ylabel('����ϵͳ�ɵ�״̬');
title('����SOC');

