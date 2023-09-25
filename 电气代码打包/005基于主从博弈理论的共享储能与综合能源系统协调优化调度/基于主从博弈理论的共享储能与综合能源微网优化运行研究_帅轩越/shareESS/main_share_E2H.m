%% �������Ӳ������۵Ĺ��������ۺ���Դ΢���Ż������о�����˧��Խ
%���� 4:���й����ܺ͵������豸

clc;clear;close all;% �����ʼ��
%% ��ȡ����
shuju=xlsread('share+EtoH����.xlsx'); %��һ�컮��Ϊ24Сʱ
load_e=shuju(2,:); %��ʼ�縺��
load_h=shuju(3,:); %��ʼ�ȸ���
P_PV=shuju(4,:);    %���Ԥ��
pe_grid_S=shuju(5,:); %�����۵��
pe_grid_B=shuju(6,:); %���������
ph_max=shuju(7,:); %�ȼ�����
ph_min=shuju(8,:); %�ȼ�����

%% ���Ӳ��Ĺ���

F = 0.5;   % ��������
CR = 0.9;  % ��������
%��������
groupSize =40;        %������Ŀ(Number of individuals)
groupDimension=48;  %Ⱦɫ�峤��
MAXGEN =80;      %����Ŵ�����(Maximum number of generations)
v=zeros(groupSize,groupDimension);    % ������Ⱥ
u=zeros(groupSize,groupDimension);    % ������Ⱥ
Unew=zeros(groupSize,groupDimension); % �߽紦������Ⱥ
%��ʼ��Ⱥ
population = smartGroupInit(groupSize,groupDimension);% ��ʼ��Ⱥ��
gen=0;                                         %��Ⱥ����������
fitness=0; %��ʼ��Ӧ��
user=0;%�û�����
while gen<MAXGEN
   gen=gen+1 
%����Ŀ�꺯��ֵ   
    [P_MT,F_user,F_share,Eload,Hload,ES,P_h,Prl,P_buy,P_sell] = computeObj(population,load_e,load_h,P_PV,pe_grid_B);
%�������
   v=mutate(population,F,MAXGEN,gen); %���������Ⱥ�ı���
%�������
   u=crossover(population,v,CR);
%�߽紦��
   Unew = boundaryprocess(u,pe_grid_S,pe_grid_B,ph_max,ph_min);
% ѡ����� (�����µ���Ӧ��)
[Newpopulation,fitbest,best] =select(Unew,population,P_MT,P_h,P_buy,pe_grid_S);
trace(gen,1)=gen; %��ֵ������
    population=Newpopulation;
    %׷��������Ӧ�Ⱥ��۵����ȼ�
    if fitness<=fitbest
    fitness = fitbest;  
    trace(gen,2)=fitbest;
    remainbest=best;
    else
    trace(gen,2)=fitness;
    end
    trace(gen,3)=F_share; %�������̵�����
%׷������Ŀ�꺯��
if user<=F_user
    user=F_user;
    trace(gen,4)=F_user;%�û���������
else
    trace(gen,4)=user;
end
end

%% ��ͼ
figure(1)
plot(trace(:,2),'c-*','linewidth',2)
hold on
xlabel('��������');
ylabel('�ۺ���ԴϵͳĿ�꺯��');
yyaxis right
plot(trace(:,4),'g-*','linewidth',2);
ylabel('�û��ۺ���Ŀ�꺯��');
title('��������');
legend('΢����Ӫ����������','�û���������')

figure(2)
bar(P_PV)
hold on
plot(load_e,'g-*','linewidth',2)
hold on
plot(load_h,'y-*','linewidth',2)
hold on
xlabel('ʱ��/h');
ylabel('����/kW');
legend('�������','�縺��','�ȸ���');

figure(3)
bar(load_e-Eload);
hold on 
ylabel('����/kW');
yyaxis right
plot(shuju(5,:),'g-*','linewidth',2)
xlabel('ʱ��/h');
ylabel('���');
title('�縺���Ż����');
legend('����ת�ƽ��','�г����');


figure(4)
bar(load_e,'b');
hold on
plot(Eload,'r-*','linewidth',2)
hold on 
xlabel('ʱ��/h');
ylabel('�縺��/kW');
title('�縺�ɱ仯');
legend('ԭʼ�縺��ֵ','�Ż��縺��ֵ');


figure(5)
bar(load_h,'b');
hold on
plot(Hload,'r-*','linewidth',2)
hold on 
xlabel('ʱ��/h');
ylabel('�ȸ���/kW');
title('�ȸ��ɱ仯');
legend('ԭʼ�ȸ���ֵ','�Ż��ȸ���ֵ');


figure(6)
xx=1:24;
stairs(pe_grid_S,'r--*','linewidth',2);
hold on
stairs(pe_grid_B,'b--*','linewidth',2);
hold on
stairs(best(1,xx),'y--','linewidth',2);
xlabel('ʱ��/h');
ylabel('���/Ԫ');
title('΢����Ӫ�̵��');
legend('�����۵��','���������','΢����Ӫ���۵��');


figure(7)
xx=1:24;
stairs(ph_min,'c--*','linewidth',2);
hold on
stairs(ph_max,'g--*','linewidth',2);
hold on
stairs(best(1,xx+24),'b--*','linewidth',2);
xlabel('ʱ��/h');
ylabel('���/Ԫ');
title('΢����Ӫ���ȼ�');
axis([1,24,0.1,0.6]);
legend('�ȼ�����','�ȼ�����','΢���ۺ������ȼ�');

figure(8)
bar(ES,'stack')
hold on
xlabel('ʱ��/h');
ylabel('����/kW');
yyaxis right
plot(shuju(5,:),'r--*','linewidth',2)
xlabel('ʱ��/h');
ylabel('���');
title('�����ܾۺ���');
legend('��������','�г����');

xx=1:24;
PP=value([P_h;Prl]);
figure(9)
bar(PP',0.5,'stack');
hold on
plot(value(P_h+Prl),'g--*','linewidth',2);
legend('�����ȹ���','�����ȳ���','�Ż�����ȸ���');
xlabel('ʱ��');ylabel('����/kW');


