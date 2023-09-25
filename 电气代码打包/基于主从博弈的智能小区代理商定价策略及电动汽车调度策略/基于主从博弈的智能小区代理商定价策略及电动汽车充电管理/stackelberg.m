%��yalmip��kkt����
clear
clc
%����
price_day_ahead=[0.35;0.33;0.3;0.33;0.36;0.4;0.44;0.46;0.52;0.58;0.66;0.75;0.81;0.76;0.8;0.83;0.81;0.75;0.64;0.55;0.53;0.47;0.40;0.37];
price_b=1.2*price_day_ahead;
price_s=0.8*price_day_ahead;
lb=0.8*price_day_ahead;
ub=1.2*price_day_ahead;
T_1=[1;1;1;1;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1];
T_2=[1;1;1;1;1;1;1;1;0;0;0;0;1;1;1;0;0;0;0;1;1;1;1;1];
T_3=[0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0];
index1=find(T_1==0);index2=find(T_2==0);index3=find(T_3==0);
%�������
Ce=sdpvar(24,1);%���
z=binvar(24,1);%���۵�״̬
u=binvar(24,1);%����״̬
Pb=sdpvar(24,1);%��ǰ����
Pb_day=sdpvar(24,1);%ʵʱ����
Ps_day=sdpvar(24,1);%ʵʱ�۵�
Pdis=sdpvar(24,1);%���ܷŵ�
Pch=sdpvar(24,1);%���ܳ��
Pc1=sdpvar(24,1);%һ�೵��繦��
Pc2=sdpvar(24,1);%���೵��繦��
Pc3=sdpvar(24,1);%���೵��繦��
S=sdpvar(24,1);%��������
for t=2:24
    S(t)=S(t-1)+0.9*Pch(t)-Pdis(t)/0.9;
end
%�ڲ�
CI=[sum(Pc1)==50*(0.9*24-9.6),sum(Pc2)==20*(0.9*24-9.6),sum(Pc3)==10*(0.9*24-9.6),Pc1>=0,Pc2>=0,Pc3>=0,Pc1<=50*3,Pc2<=20*3,Pc3<=10*3,Pc1(index1)==0,Pc2(index2)==0,Pc3(index3)==0];%��������Լ��
OI=sum(Ce.*(Pc1+Pc2+Pc3));
ops=sdpsettings('solver','gurobi','kkt.dualbounds',0);
[K,details] = kkt(CI,OI,Ce,ops);%����KKTϵͳ��CeΪ����
%���
CO=[lb<=Ce<=ub,mean(Ce)==0.5,Pb>=0,Ps_day<=Pdis,Pb_day>=0,Pb_day<=1000*z,Ps_day>=0,Ps_day<=1000*(1-z),Pch>=0,Pch<=1000*u,Pdis>=0,Pdis<=1000*(1-u)];%�߽�Լ��
CO=[CO,Pc1+Pc2+Pc3+Pch-Pdis==Pb+Pb_day-Ps_day];%����ƽ��
CO=[CO,sum(0.9*Pch-Pdis/0.9)==0,S(24)==2500,S>=0,S<=5000];%SOCԼ��
OO=-(details.b'*details.dual+details.f'*details.dualeq)+sum(price_s.*Ps_day-price_day_ahead.*Pb-price_b.*Pb_day);%Ŀ�꺯��
optimize([K,CI,CO,boundingbox([CI,CO]),details.dual<=1],-OO)


Ce=value(Ce);%���
Pb=value(Pb);%��ǰ����
Pb_day=value(Pb_day);%ʵʱ����
Ps_day=value(Ps_day);%ʵʱ����
Pdis=value(Pdis);%���ܷŵ�
Pch=value( Pch);%���ܳ��
Pb_day=value(Pb_day);%ʵʱ����
Pb_day=value(Pb_day);%ʵʱ����
Pc1=value(Pc1);%һ�೵��繦��
Pc2=value(Pc2);%���೵��繦��
Pc3=value(Pc3);%���೵��繦��
S=value(S);%��������

figure(1)
plot(Pc1,'-*','linewidth',1.5)
grid
hold on
plot(Pc2,'-*','linewidth',1.5)
hold on
plot(Pc3,'-*','linewidth',1.5)
title('����綯������繦��')
legend('����1','����2','����3')
xlabel('ʱ��')
ylabel('����')

figure(2)
bar(Pdis,0.5,'linewidth',0.01)
grid
hold on
bar(Pch,0.5,'linewidth',0.01)
hold on
plot(S,'-*','linewidth',1.5)
axis([0.5 24.5 0 5000]);
title('���ܳ�繦��')
legend('��繦��','�ŵ繦��','�����')
xlabel('ʱ��')
ylabel('����')

figure(3)
yyaxis left;
bar(Pb_day,0.5,'linewidth',0.01)
hold on
bar(Ps_day,0.5,'linewidth',0.01)
axis([0.5 24.5 0 1200])
xlabel('ʱ��')
ylabel('����')
yyaxis right;
plot(Ce,'-*','linewidth',1.5)
% legend('��۽��')
xlabel('ʱ��')
ylabel('���')
legend('��ǰ����','��ǰ�۵�','����Ż�');

figure(4)
plot(Ce,'-*','linewidth',1.5)
grid
hold on
plot(price_b,'-*','linewidth',1.5)
hold on
plot(price_s,'-*','linewidth',1.5)
title('����Ż����')
legend('�Ż����','������','�۵���')
xlabel('ʱ��')
ylabel('���')