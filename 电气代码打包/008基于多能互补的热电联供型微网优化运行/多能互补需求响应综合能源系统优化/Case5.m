%��ʽ5
clc;
clear all;
%10���߸��ʷ�繦��
w=2*fix([38,37,27,29,23,14,21,13,43,76,59,70,49,41,51,41,28,21,18,18,33,41,45,42;
    34,38,33,29,26,13,19,13,38,40,59,78,51,38,54,43,24,21,22,22,25,39,48,30;
    30,30,27,35,27,13,18,14,39,50,58,84,58,39,47,44,25,20,22,18,28,41,36,46;
    39,32,32,34,23,14,20,14,43,50,61,73,60,41,48,43,26,21,22,20,29,40,43,30;
    32,39,28,30,21,12,22,16,37,62,53,77,60,39,50,49,25,20,21,18,30,40,38,48;
    34,43,26,30,22,18,21,12,41,56,65,78,47,37,50,45,23,21,21,20,27,40,39,40;
    40,43,32,30,24,16,21,15,41,65,62,69,55,44,53,42,27,21,20,21,28,42,41,50;
    39,40,26,28,25,14,21,18,39,70,54,68,51,38,56,43,25,17,21,17,28,36,40,35;
    41,43,30,30,22,13,20,13,46,66,55,79,55,37,48,37,28,18,22,19,27,41,41,48;
    41,38,30,27,23,15,17,14,39,61,62,78,54,39,46,45,22,20,20,20,28,35,36,52]);
Pwind=w(5,:);
% ��ǰ�ƻ� Ԥ�⸺��
load=[178 160 200 220 258 260 286 380 380 385 360 320 280 254 266 285 312 335 326 288 200 185 146 120];%���û�
Phot=[360,353,342,342,331,328,287,265,240,245,244,238,233,229,232,237,249,257,266,270,301,321,341,366];
bb=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; %������ù�
% ��ǰ�ƻ� �ɿظ���
%���ж���
L5=[19,24,24,19,24,29,64,49,64,59,59,59,49,59,59,39,39,64,64,19,44,19,44,19]; %���ж�
%ʱ��
L6=[18,8,13,13,18,13,13,18,23,33,23,18,18,18,18,18,18,18,13,13,13,8,8,8];%��ƽ��
%����ѡ����--������
L7=[17,22,22,17,22,26,58,85,88,84,84,84,65,64,74,55,35,58,58,17,40,17,40,17];
%����
for i=1:24                   
    if i>=7&&i<=12
        Cgas(i)=1.57;
    elseif  i>=19&&i<=22
        Cgas(i)=1.57;
    elseif i>=13&&i<=18
        Cgas(i)=2.05;
    else
        Cgas(i)=2.05;
    end
end
 %%һ���Ϊ24Сʱ��ʱ�䲽��ȡ1Сʱ/60min
%%%% 1̨MT����,1̨
LHV=9.75; %����ֵ
aF=[0.5869 0.3952 ]';%�������
bF=[8.6204 -0.185]';
aH=[1.377]';
bH=[20.38]';
%% PCC
Pgrid_max=[320 320]';
Pgrid_min=[0 0]';
%% Pnas ����Pess
Pnas_max=[60 60]';       
Pnas_min=[0 0]';
%%%%%%%%%%%%��¯
H_max=600;H_n=0.98%��¯����/ת����
Peh_max=60;n_Peh=0.98;%ת���豸/ת����
H_storage_max=800; h_n=0.98;h_charge=0.9;h_discharge=1;%�ȴ�������/����/����/���ȣ�
%%%%%%%%%%%%%%%%%%%%    ���� ���ϵ��
%���� 1000  ��ʼ500
SOC_max=[800]';
SOC_min=[200]';
SOC_ini=0.5;
%%   �� ƽ �� ���
buy=[1.243 0.8934  0.47];%��/�� �����
%%  ��ֵ
MT=intvar(1,24,'full');

Pgrid=intvar(1,24,'full');  %  �� �� ��

Pnas=intvar(2,24,'full'); % �䡢 ��


H=intvar(1,24,'full');%��¯
Q=intvar(1,24,'full');%���жϵ縺��
P=intvar(1,24,'full');%ת�ȸ���

Hti=intvar(1,24,'full');%����
Hto=intvar(1,24,'full');%����
xx=intvar(1,24,'full');%%%%%ʱƽ������
yy=intvar(1,24,'full');

%% 0-1��ֵ
I_Hti=binvar(1,24,'full');%����
I_Hto=binvar(1,24,'full');%����
I_MT=binvar(1,24,'full');
I_Pnas=binvar(2,24,'full');% 1���� 0ֹͣ
I_Q=binvar(1,24,'full');
I_P=binvar(1,24,'full');
%%   Ŀ�꺯��
for i=1:24%����ɱ�
    Cf(1,i)=Cgas(i)*(aF(1)*MT(1,i)+bF(1)*I_MT(1,i));
end
for i=1:24%%%%���Ȼ���
    H_cycle(1,i)=aH(1)*MT(1,i)+bH(1)*I_MT(1,i);
end
for k=1:24 %PCC�����ɱ� % 1-5��23-24 �� % 6-12��19-22 �� % 13-18 ƽ 
    if k>=1&&k<7
        Cgrid(1,k)=Pgrid(1,k).*buy(3);
    elseif k>=7&&k<13
        Cgrid(1,k)=Pgrid(1,k).*buy(1);
    elseif k>=13&&k<19
        Cgrid(1,k)=Pgrid(1,k).*buy(2);
    elseif k>=19&&k<23
        Cgrid(1,k)=Pgrid(1,k).*buy(1);
    else
        Cgrid(1,k)=Pgrid(1,k).*buy(3);
    end
end
for k=1:24 %������Ӧ��λ�ɱ�
    if k>=1&&k<7
        bu_q(1,k)=0.9*buy(1);
        bu_x(1,k)=0.5*buy(1);
        bu_p(1,k)=0.6*Cgas(1,k);
    elseif k>=7&&k<13
        bu_q(1,k)=0.9*buy(1);
        bu_x(1,k)=0.5*buy(1);
        bu_p(1,k)=0.6*Cgas(1,k);
    elseif k>=13&&k<19
        bu_q(1,k)=0.9*buy(1);
        bu_x(1,k)=0.5*buy(1);
        bu_p(1,k)=0.6*Cgas(1,k);
    elseif k>=19&&k<23
        bu_q(1,k)=0.9*buy(1);
        bu_x(1,k)=0.5*buy(1);
        bu_p(1,k)=0.6*Cgas(1,k);
    else
        bu_q(1,k)=0.8*buy(1);
        bu_x(1,k)=buy(1)/2;
        bu_p(1,k)=0.6*Cgas(k);
    end
end
for k=1:24  %% �г����ɳɱ�
        if k>=7&&k<=12
          Ck1(1,k)=(Q(1,k).*bu_q(1,k))+(P(1,k).*bu_p(1,k)+xx(1,k)*bu_x(1,k));
    elseif  k>=19&&k<=20
          Ck1(1,k)=(Q(1,k).*bu_q(1,k))+(P(1,k).*bu_p(1,k)+xx(1,k)*bu_x(1,k));
       else
          Ck1(1,k)=(Q(1,k).*bu_q(1,k))+(P(1,k).*bu_p(1,k)+xx(1,k)*bu_x(1,k));
        end
end
for i=1:24%��¯�ɱ�
    Ch(1,i)=Cgas(i)*(H(1,i)+P(1,i)*0.98)/LHV;
end
F=0;%Ŀ�꺯��
mm=3.1;
for k=1:24 %1.8
     F=F+Cf(1,k)+Cgrid(1,k)+Ch(1,k)+(Pnas(1,k)+Pnas(2,k))*0.024+Ck1(1,k);
end
for k=1:24 %SOCֵ
    SOC(k)=(500+sum(Pnas(1,1:k).*I_Pnas(1,1:k)-(Pnas(2,1:k)).*I_Pnas(2,1:k)))/1000;   
end
begin=500;
for i=1:24%%�ȴ���
    L(1,i)=begin*h_n+h_charge*Hti(1,i)-Hto(1,i);%%%�ȴ�������
    begin=L(1,i);
end

%%  Լ������
constraints=[];
%% ״̬Լ��
for k=1:24  %Pgrid״̬ %Pnas״̬
    constraints=[constraints,I_Pnas(1,k)+I_Pnas(2,k)<=1];
    constraints=[constraints,I_Hti(1,k)+I_Hto(1,k)<=1];
end
constraints=[constraints,sum(I_Pnas(1,1:24)+I_Pnas(2,1:24))<=14];
%% ������Լ��
for k=1:24     
    constraints=[constraints,25.*I_MT(1,k)<=MT(1,k)<=145.*I_MT(1,k)]; 
    
    constraints=[constraints,Pgrid_min<=Pgrid(1,k)<=Pgrid_max]; 

    constraints=[constraints,Pnas_min.*I_Pnas(1,k)<=Pnas(1,k)<=Pnas_max.*I_Pnas(1,k)]; 
    constraints=[constraints,Pnas_min.*I_Pnas(2,k)<=Pnas(2,k)<=Pnas_max.*I_Pnas(2,k)];    
    
    constraints=[constraints,0<=Q(1,k)<=0.6*L5(k).*I_Q(1,k)]; 
    constraints=[constraints,0<=P(1,k)<=0.9*L7(k).*I_P(1,k)]; 
%     constraints=[constraints,I_Q(1,k)+I_P(1,k)<=1]; 
end
    constraints=[constraints,I_Q(1,1:6)==0]; 
    constraints=[constraints,I_Q(1,22:24)==0]; 
        constraints=[constraints,I_P(1,1:6)==0]; 
    constraints=[constraints,I_P(1,22:24)==0]; 
    for k=8:12
     constraints=[constraints,0<=xx(1,k)<=L6(1,k)]; 
    end
    for k=20:21
       constraints=[constraints,0<=xx(1,k)<=L6(1,k)]; 
    end
  constraints=[constraints,xx(1,1:1:7)==0]; 
   constraints=[constraints,xx(1,13:1:19)==0]; 
  constraints=[constraints,xx(1,22:1:24)==0]; 
    for k=1:5
        constraints=[constraints,sum(yy(1,k))==sum(xx(1,k+7))]; 
    end
    for k=23:24
        constraints=[constraints,sum(yy(1,k))==sum(xx(1,k-3))]; 
    end
    constraints=[constraints,yy(1,6:1:22)==0]; 
%%% MT������
for i=1:23
    constraints=[constraints,-55<=MT(1,i+1)-MT(1,i)<=65];
end
% 	PCC�������
 for k=1:23
     constraints=[constraints,-60<=Pgrid(1,k+1)-Pgrid(1,k)<=60];
 end
 %%�ɵ�״̬
 for k=1:24
      constraints=[constraints,SOC_min<=300+sum(Pnas(1,1:k)-Pnas(2,1:k))<=SOC_max];      
 end
 %%���ܳ�ŵ��������
 for k=1:23
     constraints=[constraints,-50<=Pnas(1,k+1)-Pnas(2,k+1)-Pnas(1,k)+Pnas(2,k)<=50];
 end
     constraints=[constraints,sum(Pnas(1,1:24))==sum(Pnas(2,1:24))];
%%%��¯�����ޡ�������
for i=1:24
    constraints=[constraints,30<=H(1,i)<=H_max];
end
for i=1:23   
   constraints=[constraints,-90<=H(1,i+1)-H(1,i)<=90];
end
%%�ȴ�������Լ��������Լ��������Լ����״̬Լ��
for i=1:24
constraints=[constraints,200<=L(1,i)<=H_storage_max];
end
%�ȴ���Լ��
for i=1:24
    constraints=[constraints,0<=Hti(1,i)<=45*I_Hti(1,i)];
    constraints=[constraints,0<=Hto(1,i)<=45*I_Hto(1,i)];
end
     constraints=[constraints,sum(Hti(1,1:24))==sum(Hto(1,1:24))];
for i=1:23
    constraints=[constraints,-40<=Hti(1,i+1)-Hto(1,i+1)-(Hti(1,i)-Hto(1,i))<=60];
end
%%����ƽ��
for k=1:24
constraints=[constraints,P(1,k)+MT(1,k)-Pnas(1,k)+Pnas(2,k)+Pgrid(1,k)+Pwind(1,k)+Q(1,k)+xx(1,k)==load(k)+yy(1,k)+L5(1,k)+L6(1,k)+L7(1,k)];
end

%%��ƽ��
for i=1:24
    constraints=[constraints,Phot(1,i)+2>=H_cycle(1,i)+H(1,i)*H_n+(-Hti(1,i)+h_discharge*Hto(1,i))>=Phot(1,i)];
end

%��������
opss = sdpsettings('solver', 'cplex', 'verbose',2);
%%%%%
result=solvesdp(constraints,F,opss);
charge=double(Pnas(1,:)-Pnas(2,:));
charge_hot=double(Hti(1,:)-Hto(1,:));
Pgrid=double(Pgrid);
% Peh=double(Peh);
H=double(H);
MT=double(MT)
P=double(P);
xx=double(xx);
yy=double(yy);
Q=double(Q);
t=0:1:23;
figure()
subplot(5,1,1)
stairs(t,MT(1,:),'--or','MarkerFaceColor','r');
legend('MT');
xlabel('ʱ�䣨t/h)');
ylabel('���ʣ�P/kW��');
title('����');
subplot(5,1,2)
plot(t,charge,'--or','MarkerFaceColor','r');
hold on
plot(t,charge_hot,'--^k','MarkerFaceColor','k');
legend('Pnas','L');
xlabel('ʱ�䣨t/h)');
ylabel('���ʣ�P/kW��');
title('����')
subplot(5,1,3)
plot(t,Pgrid(1,:),'--or','MarkerFaceColor','r');
legend('Pgrid');
xlabel('ʱ�䣨t/h)');
ylabel('���ʣ�P/kW��');
title('��������')
subplot(5,1,4)
plot(t,H(1,:)+P(1,:)*n_Peh,'--or','MarkerFaceColor','r');
hold on
plot(t,L7-P(1,:),'--^k','MarkerFaceColor','k');
legend('ȼ����¯','���¯');
xlabel('ʱ�䣨t/h)');
ylabel('���ʣ�P/kW��');
title('ȼ��')
F=double(F);
%
%%%%%%%״̬����
ahead_MT=double(I_MT);
ahead_Hti=double(I_Hti);
ahead_Hto=double(I_Hto);
ahead_Pnas=double(I_Pnas);
%%%%%%%������ֵ
a_MT=double(MT);
a_Pnas=double(Pnas);
a_Pgrid=double(Pgrid);
a_H=double(H);
F=double(F);
figure()
Q=double(Q);
xx=double(xx);
yy=double(yy);
T=0:1:23;
plot(T,load+L5+L6+L7);
hold on
plot(T,load+yy+L5+L6+L7-xx-P-Q,'r');
for k=1:24
s(k)=value(sum(Pnas(1,1:k)-Pnas(2,1:k)))/800+0.4;
soc(k+1)=s(k);
end
soc(1)=0.4;
x=0:24;
figure
plot(x,soc,'r');
xlabel('ʱ��');ylabel('SOCֵ');
title('����SOC״̬');

x=1:24;
PP=[Pgrid;Pnas(2,x);MT;Pwind];
PP1=[bb;-Pnas(1,x);bb;bb];
figure
bar(PP','stack');
h=legend('��������','���س���','ȼ���ֻ�����','����������','Location','NorthWest');
set(h,'Orientation','horizon')
hold on
bar(PP1','stack');
plot(x,value(load+L5+L6+L7+yy-P-Q-xx),'r','linewidth',2);
xlabel('ʱ��');ylabel('����/kW');
hold off

x=1:24;
QQ=[Hto;H(1,x)*H_n;H_cycle];
QQ1=[-Hti];
figure
bar(QQ','stack');
h=legend('���Ȳ۳���','ȼ����¯����','���ȹ�¯����','Location','NorthWest');
set(h,'Orientation','horizon')
hold on
bar(QQ1','stack');
plot(x,value(Phot),'r','linewidth',2);
xlabel('ʱ��');ylabel('����/kW');
hold off
