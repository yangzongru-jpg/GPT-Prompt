function [Result,Cost,PDE,PWind,rate] = Yalmip_Cplex(Load,Wind,mpc,tan,wind)
%% ��ʼ����
yalmip;
T = 96; %��������
% ���߱���
P_DE1 = sdpvar(1,T,'full');
P_DE3 = sdpvar(1,T,'full');
P_Wind = sdpvar(1,T,'full');
rate = sdpvar(1,1,'full'); % �������װ������ϵ��
%% Լ��
St = [];
St = [St,1<=rate(1,1)<=10];
for t = 1:T
    St = [St, mpc(2,1) <= P_DE1(t) <= mpc(1,1)];
    St = [St, mpc(2,3) <= P_DE3(t) <= mpc(1,3)];
end
for t = 1:T
    St = [St,0 <= P_Wind(t) <= rate*Wind(t)];
    St = [St,-0.1 <= P_DE1(t) + P_DE3(t) + P_Wind(t) - Load(t) <= 0.1];
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
    F = F + 0.25*(mpc(6,3)*P_DE3(t)^2 + mpc(5,3)*P_DE3(t) + mpc(4,3));
end
Object = (F/1000)*1.5*700; % ���гɱ�
% ��̼��
for t = 1:T
    Tan = Tan + P_DE1(t)*mpc(3,1)*0.25*tan;
    Tan = Tan + P_DE3(t)*mpc(3,3)*0.25*tan;
end
Object = Object + Tan;
% ���ɱ�
for t = 1:T
    WIND_yunxing = WIND_yunxing + (Wind(t)*1000) * wind(1)*0.25;
    WIND_qifeng = WIND_qifeng + ((rate*Wind(t)-P_Wind(t))*1000) * wind(2)*0.25;
end
Object = Object + WIND_yunxing; % �������
Object = Object + WIND_qifeng; % ����ɱ�
%% ���
Option = sdpsettings('solver','cplex','debug',0);
tic;
Result = optimize(St,Object,Option);
fprintf('ģ�����ʱ�䣺')
toc;
%% ���
fprintf('ȫ�����з��ã�');
disp(value((F/1000)*1.5*700+Tan+WIND_yunxing+WIND_qifeng));
PDE = [value(P_DE1);value(P_DE3)];
PWind = value(P_Wind);
rate = value(rate);
Cost = [value((F/1000)*1.5*700),value(Tan),value(WIND_yunxing),value(WIND_qifeng)];
end



