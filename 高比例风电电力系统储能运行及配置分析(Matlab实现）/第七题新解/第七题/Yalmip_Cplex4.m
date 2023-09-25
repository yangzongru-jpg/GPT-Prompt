function [Result,Cost,PDE,PWind,P_Bat,Pdis,Pcha,Loss] = Yalmip_Cplex4(Load,Wind,mpc,tan,wind,Bat,loadloss)
%% ��ʼ����
yalmip clear;
yalmip;
T = size(Load); %��������
% ���߱���
P_DE1 = sdpvar(1,T,'full');
P_Wind = sdpvar(1,T,'full');
P_loss = sdpvar(1,T,'full');
P_Bat = sdpvar(1,T,'full'); %���س���
Pdis = sdpvar(1,T,'full'); %���طŵ�
Pcha = sdpvar(1,T,'full'); %���س��
Temp_Battery = binvar(1,T,'full'); %��|�ŵ��־��1�ŵ磬0��磩
S_Bat = 1.5984*10^4; % ��������
P_limit = 368.5508; % ���ܹ���Լ��
%% Լ��
St = [];
% St = [St, 0<=S_Bat<=10000000000, 0<=P_limit<=1000000]; % ��ʱ����������
St = [St, -P_limit<=P_Bat<=P_limit, 0<=Pdis<=P_limit, -P_limit<=Pcha<=0];
for t = 1:T
    % ��������Լ��
    St = [St, mpc(2,1) <= P_DE1(t) <= mpc(1,1)];
    St = [St, 0 <= P_Wind(t) <= Wind(t)];
    St = [St, 0 <= P_loss(t) <= Load(t)];
    % �������
    St = [St,implies(Temp_Battery(t),[P_Bat(t) >= 0, Pdis(t) == P_Bat(t), Pcha(t) == 0])]; %�ŵ�Լ��
    St = [St,implies(1-Temp_Battery(t),[P_Bat(t) <= 0, Pcha(t) == P_Bat(t), Pdis(t) == 0])]; %���Լ��
    St = [St,-0.45*S_Bat <= -sum(Pdis(1:t)/Bat(4) + Bat(4)*Pcha(1:t)) <= 0.45*S_Bat]; %���ص����������Լ��(0.05S-0.95S)
    % ����ƽ��
    St = [St,-0.5 <= P_DE1(t) + P_Wind(t) + P_Bat(t) - (Load(t)-P_loss(t)) <= 0.5];
end
% SOC����
for i = 1:15
    St = [St, 0.2*S_Bat <= S_Bat*Bat(5) - sum(Pdis(1,1:i*96)/Bat(4) + Bat(4)*Pcha(1,1:i*96)) <= 0.95*S_Bat];
end
%% Ŀ��
Object = 0; % �ܳɱ�
F = 0;
Tan = 0;
WIND_yunxing = 0;  WIND_qifeng = 0; % ���
Cost_Bat = 0; % ���ܳɱ�
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
% ���ܳɱ� = ���ܹ������óɱ� + �����������óɱ� + ȫ������ά���ɱ�
Cost_Bat = (1000*Bat(1)/(10*365))*P_limit + (1000*Bat(2)/(10*365))*S_Bat;
for t = 1:T
    Cost_Bat = Cost_Bat + abs(P_Bat(t))*0.05*1000*0.25;
end
Object = Object + Cost_Bat;
%% ���
Option = sdpsettings('solver','cplex','debug',0);
tic;
Result = optimize(St,Object,Option);
fprintf('ģ�����ʱ�䣺')
toc;
%% ���
fprintf('ȫ�����з��ã�');
disp(value(Object));
PDE = value(P_DE1);
PWind = value(P_Wind);
Loss = value(P_loss);
% S_Bat = value(S_Bat);
% Bat_limit = value(P_limit);
P_Bat = value(P_Bat);
Pdis = value(Pdis);
Pcha = value(Pcha);
Cost = [value((F/1000)*1.5*700),value(Tan),value(WIND_yunxing),value(WIND_qifeng),value(Loss_cost),value((1000*Bat(1)/(10*365))*P_limit),value((1000*Bat(2)/(10*365))*S_Bat)];
end



