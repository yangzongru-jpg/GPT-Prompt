function [Cost,PDE] = Yalmip_Cplex(Load,mpc,tan)
%% ��ʼ����
yalmip;
T = 96; %��������
% ���߱���
P_DE = sdpvar(3,T,'full');
%% Լ��
St = [];
for t = 1:T
    for i = 1:3
        St = [St, mpc(2,i) <= P_DE(i,t) <= mpc(1,i)];
    end
    St = [St, P_DE(1,t) + P_DE(2,t) + P_DE(3,t) - Load(t)*900 == 0];
end
%% Ŀ��
Object = 0; % �ܳɱ�
F = 0;
Tan = 0;
% ú�����ɱ�
for t = 1:T
    for i = 1:3
        F = F + 0.25*(mpc(6,i)*P_DE(i,t)^2 + mpc(5,i)*P_DE(i,t) + mpc(4,i));
    end
end
Object= (F/1000)*1.5*700; % ���гɱ�
% ��̼��
for t = 1:T
    for i = 1:3
        Tan = Tan + P_DE(i,t)*mpc(3,i)*0.25*tan;
    end
end
Object = Object + Tan; % ����̼�����ɱ�
%% ���
Option = sdpsettings('solver','cplex','debug',0);
tic;
Result = optimize(St,Object,Option);
fprintf('ģ�����ʱ�䣺')
toc;
%% ���
fprintf('ȫ�����з��ã�');
disp(value(Object));
PDE = [value(P_DE)];
Cost = [value(Object),value(Tan),value((F/1000)*700),value((F/1000)*350)];



b=0  %�ܹ���ɱ�
b=b+((value(Tan)+value(F/1000)*700)+value((F/1000)*350))
a=0  %��λ����ɱ�
a=a+(value(Tan)+value((F/1000)*700)+value((F/1000)*350))/(sum(Load)*900)
end

