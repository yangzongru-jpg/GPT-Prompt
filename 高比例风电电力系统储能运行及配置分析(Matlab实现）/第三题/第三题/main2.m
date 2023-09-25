clc;
clear;
close all;
%% ����
biaoge = xlsread('����1');
Load = biaoge(:,2)*900;
Wind = biaoge(:,3)*600;
mpc = [600,300,150;
    180,90,45;
    0.72,0.75,0.79;
    786.8,451.32,1049.5;
    30.42,65.12,139.6;
    0.226,0.588,0.785];
tan =100;
wind = [0.045,0.3];
%% ���
[Result,Cost,PDE,PWind,rate] = Yalmip_Cplex(Load,Wind,mpc,tan,wind);
zongfeng = 0.25*sum(rate*Wind-PWind');
qifeng=rate*Wind-PWind';
%% ��ͼ
figure(1);
bar(PDE(1,:));
hold on
bar(PWind);
bar(PDE(2,:));
plot(Load,'r-*');
plot(PDE(1,:)+PDE(2,:)+PWind,'k--');
hold off
legend('һ�Ż���','������','���Ż���','��������','�ܷ��繦��');
xlabel('ʱ��/15min');
ylabel('����/MW');
title('�����շ���ƻ�����');

figure(2);
plot(PWind,'r-^');
hold on
plot(rate*Wind,'b--*');
hold off
legend('���ʵ�ʳ���','��繦�����');
xlabel('ʱ��/15min');
ylabel('����/MW');
title('������');

figure(3);
plot(rate*Wind-PWind','r-^');
legend('���繦��');
xlabel('ʱ��/15min');
ylabel('����/MW');
title('���������');


