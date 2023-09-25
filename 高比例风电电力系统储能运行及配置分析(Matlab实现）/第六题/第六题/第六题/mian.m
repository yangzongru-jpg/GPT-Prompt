clc;
clear;
close all;
%% 
biaoge = xlsread('����1');
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
Bat =[3000,3000,0.05,0.9,0.4]; % [��λ���ʳɱ�����λ�����ɱ�����λ��ά�ɱ�����ŵ繦�ʡ���ʼ����]
% ע�����ܵ�س�ʼ�ɵ�״̬Ϊ0.4���������ɵ�״̬Ϊ0.95����С����ɵ�״̬Ϊ0.05

Total = cell(10,6); % �ռ�����
%% ѭ������
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
%% ���ӻ�
% ͼһ�������������׼��
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
legend('ú�ĳɱ�','̼�����ɱ�','������гɱ�','����ɱ�');
ylim([0,2.6*(10^6)]);
xlabel('ʱ��/15min');
ylabel('�ɱ�/��Ԫ');
title('����ɱ��仯���');

figure(2);
bar(Bat_Pcost+Bat_Scost);
legend('���ܳɱ�');
xlabel('ʱ��/15min');
ylabel('�ɱ�/��Ԫ');

% figure(2);
% subplot(1,2,1)
% bar(Bat_Pcost,'r');
% legend('���ܹ������óɱ�');
% xlabel('ʱ��(15min)');
% ylabel('�ɱ�');
% subplot(1,2,2)
% bar(Bat_Scost,'b');
% legend('�����������óɱ�');
% xlabel('ʱ��(15min)');
% ylabel('�ɱ�');




    