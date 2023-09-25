clc;
clear;
close all;
%% �˳����ʾ�������Ӵ��ܡ����������������������
%% ����
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
%% ���
[Result,Cost,PDE,PWind,Loss] = Yalmip_Cplex1(Load,Wind,mpc,tan,wind,loadloss);
zongfeng = 0.25*sum(Wind-PWind');
qifeng=(Wind-PWind')
qifuhe=Loss
zongloss = 0.25*sum(Loss);
%% ��ͼ
figure(1);
bar(PDE(1,:));
hold on
bar(PWind);
plot(Load,'r-*');
plot(PDE(1,:)+PWind,'k--');
hold off
legend('һ�Ż���','������','��������','�ܷ��繦��','�ܷ��繦��');
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

figure(3);
plot(Wind-PWind','r-^');
hold on
plot(Loss,'b--*');
hold off
legend('���繦��','�����ɹ���');
xlabel('ʱ��/15min');
ylabel('����/MW');
title('���������');
