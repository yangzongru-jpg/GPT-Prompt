clc;
clear;
close all;
%% ǰ�����ʺŵĽ��
load X;
biaoge = xlsread('����1');
Load = biaoge(:,2)*900;
Wind = biaoge(:,3)*300;
X(3,:) = Wind';
Un_bal = Load - sum(X)';
Qi_feng = 0;Shi_fuhe = 0;
for t = 1:96
    if Un_bal(t)<0
        Qi_feng = Qi_feng - Un_bal(t);
    else 
        Shi_fuhe = Shi_fuhe + Un_bal(t);
    end
end

% ��ͼ��ʾ
figure(1);
plot(X(3,:));
hold on
plot(X(1,:));
plot(X(2,:));
plot(Load);
bar(-Un_bal);
hold off
legend('���ʵ�ʳ���','һ�Ż������','���Ż������','�������','���ʲ�ƽ����');
xlabel('ʱ��/15min');
ylabel('����/MW');
title('�����շ���ƻ�����');
% 
fprintf('�ܵ����繦�ʣ�')
disp(Qi_feng);
fprintf('�ܵ������ɹ��ʣ�')
disp(Shi_fuhe);