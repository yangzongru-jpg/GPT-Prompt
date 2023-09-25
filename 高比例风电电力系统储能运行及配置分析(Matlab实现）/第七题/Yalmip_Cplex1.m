function [Result,Cost,PDE,PWind,Loss] = Yalmip_Cplex1(Load,Wind,mpc,tan,wind,loadloss)
%% ��ʼ����
yalmip;
T = 96; %��������
% ���߱���
P_DE1 = sdpvar(1,T,'full');
P_Wind = sdpvar(1,T,'full');
P_loss = sdpvar(1,T,'full');
%% Լ��
St = [];
for t = 1:T
    St = [St, mpc(2,1) <= P_DE1(t) <= mpc(1,1)];
    St = [St, 0<=P_Wind(t)<=Wind(t)];
    St = [St,0 <= P_loss(t) <= Load(t)];
    St = [St,-0.1 <= P_DE1(t) + P_Wind(t) - (Load(t) - P_loss(t)) <= 0.1];
end
%% Ŀ��
Object = 0; % �ܳɱ�
F = 0;
Tan = 0;
WIND_yunxing = 0;  WIND_qifeng = 0; % ���
Loss_cost = 0; % ������
% ú�ĳɱ�
for t = 1:T
    F = F + 0.25*(mpc(6,1)*P_DE1(t)^2 + mpc(5,1)*P_DE1(t) + mpc(4,1));
end
Object = (F/1000)*1.5*700; % ���гɱ�
% ��̼��
for t = 1:T
    Tan = Tan + P_DE1(t)*mpc(3,1)*0.25*tan;
end
Object = Object + Tan;
% ���ɱ�
for t = 1:T
    WIND_yunxing = WIND_yunxing + (Wind(t)*1000) * wind(1)*0.25;
    WIND_qifeng = WIND_qifeng + ((Wind(t)-P_Wind(t))*1000) * wind(2)*0.25;
end
Object = Object + WIND_yunxing; % �������
Object = Object + WIND_qifeng; % ����ɱ�
% ������
for t = 1:T
    Loss_cost = Loss_cost +  P_loss(t)*loadloss*0.25*1000;
end
Object = Object + Loss_cost;
%% ���
Option = sdpsettings('solver','cplex','debug',0);
tic;
Result = optimize(St,Object,Option);
fprintf('ģ�����ʱ�䣺')
toc;
%% ���
fprintf('ȫ�����з��ã�');
disp(value(Object));
PDE = [value(P_DE1)];
PWind = value(P_Wind);
Loss = value(P_loss);
Cost = [value((F/1000)*1.5*700),value(Tan),value(WIND_yunxing),value(WIND_qifeng),value(Loss_cost)];
end



