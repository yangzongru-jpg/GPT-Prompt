function [Result,Cost,PDE,PWind,S_Bat,Bat_limit,P_Bat,Pdis,Pcha] = Yalmip_Cplex2(Load,Wind,mpc,tan,wind,Bat)
%% ��ʼ����
yalmip;
T = 96; %��������
% ���߱���
P_DE1 = sdpvar(1,T,'full');
P_Wind = sdpvar(1,T,'full');

P_Bat = sdpvar(1,T,'full'); %���س���
Pdis = sdpvar(1,T,'full'); %���طŵ�
Pcha = sdpvar(1,T,'full'); %���س��
Temp_Battery = binvar(1,T,'full'); %��|�ŵ��־��1�ŵ磬0��磩
S_Bat = sdpvar(1,1,'full'); % ��������
P_limit = sdpvar(1,1,'full'); % ���ܹ���Լ��
%% Լ��
St = [];
St = [St, 0<=S_Bat<=1000000000, 0<=P_limit<=100000000]; % ��ʱ����������
St = [St, -P_limit<=P_Bat<=P_limit, 0<=Pdis<=P_limit, -P_limit<=Pcha<=0];
for t = 1:T
    % ��������Լ��
    St = [St, mpc(2,1) <= P_DE1(t) <= mpc(1,1)];
    St = [St,0 <= P_Wind(t) <= Wind(t)];
    % St = [St,0 <= P_loss(t) <= Load(t)];
    % �������
    St = [St,implies(Temp_Battery(t),[P_Bat(t) >= 0, Pdis(t) == P_Bat(t), Pcha(t) == 0])]; %�ŵ�Լ��
    St = [St,implies(1-Temp_Battery(t),[P_Bat(t) <= 0, Pcha(t) == P_Bat(t), Pdis(t) == 0])]; %���Լ��
    St = [St,-0.35*S_Bat <= -sum(Pdis(1:t)/Bat(4) + Bat(4)*Pcha(1:t)) <= 0.55*S_Bat]; %���ص����������Լ��(0.05S-0.95S)
    % ����ƽ��
    St = [St,-0.1 <= P_DE1(t) + P_Wind(t) + P_Bat(t) - Load(t) <= 0.1];
end
%% Ŀ��
Object = 0; % �ܳɱ�
F = 0;
Tan = 0;
WIND_yunxing = 0;  WIND_qifeng = 0; % ���
Loss_cost = 0; % ������
Cost_Bat = 0; % ���ܳɱ�
% ú�ĳɱ�
for t = 1:T
    F = F + 0.25*(mpc(6,1)*P_DE1(t)^2 + mpc(5,1)*P_DE1(t) + mpc(4,1));
end
% Object = (F/1000)*1.5*700; % ���гɱ�
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
% Object = Object + WIND_yunxing; % �������
% Object = Object + WIND_qifeng; % ����ɱ�

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
disp(value((F/1000)*1.5*700+WIND_yunxing+WIND_qifeng+Object));
PDE = value(P_DE1);
PWind = value(P_Wind);
S_Bat = value(S_Bat);
Bat_limit = value(P_limit);
P_Bat = value(P_Bat);
Pdis = value(Pdis);
Pcha = value(Pcha);
Cost = [value((F/1000)*1.5*700),value(Tan),value(WIND_yunxing),value(WIND_qifeng),value((1000*Bat(1)/(10*365))*P_limit),value((1000*Bat(2)/(10*365))*S_Bat)];
end



