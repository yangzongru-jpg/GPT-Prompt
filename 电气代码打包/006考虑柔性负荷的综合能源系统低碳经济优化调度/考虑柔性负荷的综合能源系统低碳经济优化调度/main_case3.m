
%����CPIEX���ĳ΢���������Ż�������²��Ż��ó���΢���������������۵繦�ʣ��Լ�������ĳ���
%������Դ��������������������Ը��ɵĿ�ƽ�ơ���ת�ơ����������ԣ������˺���ⴢ��ȼ���ֻ������Ը��ɵ�
%���ڵ� IES ģ�͡� �ۺϿ�����ϵͳ���гɱ���̼���׳ɱ������������ܳɱ����Ϊ�Ż�Ŀ��� IES ��̼����
%����ģ�ͣ�����cplex�����������������⡣
%����3 ���������Ը��ɲ���ϵͳ�Ż����ȵ����
clc;clear;close all;
%��ȡ���� 
%�縺�ɡ��ȸ��ɡ���������������ۡ��۵��
e_load=[160	150	140	140	130	135	150	180	215	250	275	320	335	290	260	275	270	280	320	360	345	310	220	160];%�縺��
h_load=[135	140 150 135 140 120 115 100 115 115 160 180 190 170 140 130 145 200 220 230 160 150 140 130];%�ȸ���
ppv=[0 0 0	0 0	10 15 25 45 75 90 100 80 100 50  40 30 15 10 0 0 0 0 0  ];%���Ԥ������
pwt=[60 65  70 75 80 85 90 100 125 150 130 110 100 120 125 130 140 160 180 200 175 160 155 150];%���Ԥ������
buy_price=[0.25	0.25 0.25 0.25 0.25 0.25 0.25 0.53 0.53 0.53 0.82 0.82 0.82 0.82 0.8 0.53 0.53 0.53 0.82 0.82 0.82 0.53 0.53 0.53];%�����
sell_price=[0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.42 0.42 0.42 0.65 0.65 0.65 0.65 0.65 0.42 0.42 0.42 0.65 0.65 0.65 0.42 0.42 0.42];%�۵��
%������Ӧ����
Pcut=[10 10 10 10 10 10 15 15 25 50 50 50 50 50 50 50 50 50 50 50 40 40 15 10];%�������縺��
Temp_Pcut=binvar(1,24,'full'); % �縺��������־
PPcut=sdpvar(1,24,'full');%�縺��������
n1=zeros(1,1);%��������
Hcut=[25 25 25 25 25 25 25 25 30 40 40 40 40 40 40 40 40 40 50 50 30 30 20 15];%�������ȸ���
Temp_Hcut=binvar(1,24,'full'); % �ȸ���������־
HHcut=sdpvar(1,24,'full');%�ȸ���������
n2=zeros(1,1);%��������

Ptran=[0 0 0 0 0 0 0 0 0 0 0 0 25 25 25 25 0 0 0 0 0 0 0 0 ];%��ת�Ƶ縺��
Temp_Ptran=binvar(1,24,'full'); % ��ת�Ƶ縺�� ת�Ʊ�־
PPtran=sdpvar(1,24,'full');%�縺��ת����

Pshift1=[0 0 0 0 0 0 0 0 0 0 0 25 25 0 0 0 0 0 0 0 0 0 0 0 ];%��ƽ�Ƶ縺��1
Temp_Pshift1=binvar(1,24,'full'); % ��ƽ�Ƶ縺��1 ƽ�Ʊ�־
PPshift1=sdpvar(1,24,'full');%��ƽ�Ƶ縺��1��
Pshift2=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  25 25 25 0 0 ];%��ƽ�Ƶ縺��2
Temp_Pshift2=binvar(1,24,'full'); % ��ƽ�Ƶ縺��2 ƽ�Ʊ�־
PPshift2=sdpvar(1,24,'full');%��ƽ�Ƶ縺��2��
Hshift=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 45 45 45 0 0 0 0 ];%��ƽ���ȸ���
Temp_Hshift=binvar(1,24,'full'); % ��ƽ���ȸ��� ƽ�Ʊ�־
HHshift=sdpvar(1,24,'full');%��ƽ���ȸ�����

for i=1:24
    Pfix(i)=e_load(i)-Pshift1(i)-Pshift2(i)-Ptran(i)-Pcut(i);%�����縺��
end
for i=1:24
    Hfix(i)=h_load(i)-Hshift(i)-Hcut(i);%�����ȸ���
end


%����������
P_pv=sdpvar(1,24,'full');%������������
P_wt=sdpvar(1,24,'full');%������������
P_mt=sdpvar(1,24,'full');%ȼ���ֻ����������
P_GB=sdpvar(1,24,'full');%ȼ����¯����ȹ���

Pbuy=sdpvar(1,24,'full');%�ӵ����������
Psell=sdpvar(1,24,'full');%������۵����
Pnet=sdpvar(1,24,'full');%�������������
Temp_net=binvar(1,24,'full'); % ��|�۵��־

Pcharge=sdpvar(1,24,'full');%��繦��
UPcharge=binvar(1,24,'full');%����־  
Pdischarge=sdpvar(1,24,'full');%�ŵ繦��
UPdischarge=binvar(1,24,'full');%�ŵ��־  
B=sdpvar(1,24,'full');%�索������

Hcharge=sdpvar(1,24,'full');%����ϵͳ����
Hdischarge=sdpvar(1,24,'full');%����ϵͳ����
UHcharge=binvar(1,24,'full'); %����ϵͳ���ȱ�־
UHdischarge=binvar(1,24,'full'); %����ϵͳ���ȱ�־
H=sdpvar(1,24,'full'); %�ȴ�������


%���ܲ���
%�索�ܲ���
E_storage_max=0.95*100;E_storage_min=0.4*100;e_loss=0.001;e_charge=0.9;e_discharge=0.9;%�索������/����/���/�ŵ�
%�ȴ��ܲ���
H_storage_max=0.95*100;H_storage_min=0.4*100;h_loss=0.001;h_charge=0.9;h_discharge=0.9;%�ȴ�������//����/����/����
%Լ������
Constraints =[];
 %% �索������Լ����SOCԼ�������Լ�����ŵ�Լ������ŵ�״̬Լ��������Լ��
B(1,1)=E_storage_min;%�索�ܳ�ʼ
 for t=2:25  %��һ�������ڵĳ�ŵ繦��
    Constraints=[Constraints,(B(mod(t-1,24)+1)==(B(mod(t-2,24)+1)*(1-e_loss)+(e_charge*Pcharge(mod(t-2,24)+1)-(1/e_discharge)*Pdischarge(mod(t-2,24)+1))))];
 end
% % %   %ȫ���ھ���������Ϊ��
%     Constraints=[Constraints,B(1,24)==E_storage_min];%��ʼ������ȼ���
for i=1:24
Constraints=[Constraints,E_storage_min<=B(1,i)<=E_storage_max];%����Լ������
end
 for i=1:24
     Constraints=[Constraints,30*UPcharge(1,i)<=Pcharge(1,i)<=40*UPcharge(1,i)];%�索�ܳ��Լ��
     Constraints=[Constraints,30*UPdischarge(1,i)<=Pdischarge(1,i)<=40*UPdischarge(1,i)];%�索�ܷŵ�Լ��
 end
 %���س�ŵ�Լ��
 for i=1:24
     Constraints=[Constraints,UPcharge(1,i)+UPdischarge(1,i)<=1];   %��ͬʱ��ŵ� 
 end
   Constraints=[Constraints,sum(UPcharge(1,1:24))+sum(UPdischarge(1,1:24))==16];%ʹ������С��24

 %% �ȴ�������Լ����SOCԼ��������Լ��������Լ���������״̬Լ��
H(1,1)=H_storage_min;%�ȴ��ܳ�ʼ
 for t=2:25  %��һ�������ڵĳ���ȹ���
    Constraints=[Constraints,(H(mod(t-1,24)+1)==(H(mod(t-2,24)+1)*(1-h_loss)+(h_charge*Hcharge(mod(t-2,24)+1)-(1/h_discharge)*Hdischarge(mod(t-2,24)+1))))];
 end
% %  %ȫ���ھ���������Ϊ��
%    Constraints=[Constraints,H(1,24)==H_storage_min];%��ʼ������ȼ���
for i=1:24
Constraints=[Constraints,H_storage_min<=H(1,i)<=H_storage_max];%����Լ������
end
 for i=1:24
     Constraints=[Constraints,5*UHcharge(1,i)<=Hcharge(1,i)<=30*UHcharge(1,i)];%�ȴ��ܳ��Լ��
     Constraints=[Constraints,5*UHdischarge(1,i)<=Hdischarge(1,i)<=30*UHdischarge(1,i)];%�ȴ��ܷŵ�Լ��
 end
 %���ȳس�ŵ�Լ��
 for i=1:24
     Constraints=[Constraints,UHcharge(1,i)+UHdischarge(1,i)<=1];   %��ͬʱ����� 
 end
   Constraints=[Constraints,sum(UHcharge(1,1:24))+sum(UHdischarge(1,1:24))==16];%ʹ������С��24

%% ����Լ��
for i=1:24
   Constraints = [Constraints,0<=P_pv(i)<=ppv(i)];%���������Լ��
    Constraints = [Constraints,0<=P_wt(i)<=pwt(i)];%���������Լ��
   Constraints = [Constraints,0<=P_mt(i)<=65];%ȼ���ֻ�������Լ��
   Constraints = [Constraints,0<=P_GB(i)<=160];%ȼ����¯������Լ��
   Constraints = [Constraints, -160<=Pnet(i)<=160,0<=Pbuy(i)<=160, -160<=Psell(i)<=0]; %�������ʽ���Լ��
   Constraints = [Constraints, implies(Temp_net(i),[Pnet(i)>=0,Pbuy(i)==Pnet(i),Psell(i)==0])]; %�������Լ��
   Constraints = [Constraints, implies(1-Temp_net(i),[Pnet(i)<=0,Psell(i)==Pnet(i),Pbuy(i)==0])]; %�۵����Լ�� 
end 
 
%% ������ӦԼ��
% %% ��ƽ�Ƶ縺��1��
%     Constraints= [Constraints,sum(Temp_Pshift1(1,1:24)) == 2,sum(Temp_Pshift1(1,5:21)) == 2];%��ƽ�Ƶ縺��1 ƽ�Ʊ�־
%     for i=5:20 %ʱ������Ϊ5~21-2+1
%    Constraints = [Constraints,sum(Temp_Pshift1(1,i:i+1)) >= 2*(Temp_Pshift1(1,i)-Temp_Pshift1(1,i-1))];%����2��ʱ��
%     end
%     for i=1:24
%        Constraints = [Constraints,PPshift1(1,i)== 25*Temp_Pshift1(1,i)];%��ƽ�Ƶ縺��1��
%     end
% %% ��ƽ�Ƶ縺��2��
%         Constraints = [Constraints,sum(Temp_Pshift2(1,1:24)) == 3,sum(Temp_Pshift2(1,7:23)) == 3];%��ƽ�Ƶ縺��2 ƽ�Ʊ�־
%     for i=7:21 %ʱ������Ϊ7~23-3+1
%     Constraints = [Constraints,sum(Temp_Pshift2(1,i:i+2)) >= 3*(Temp_Pshift2(1,i)-Temp_Pshift2(1,i-1)-Temp_Pshift2(1,i-2))];%����3��ʱ��
%     end
%        for i=1:24
%        Constraints = [Constraints,PPshift2(1,i)== 25*Temp_Pshift2(1,i)];%��ƽ�Ƶ縺��2��
%        end
% %% ��ƽ���ȸ�����
%         Constraints = [Constraints,sum(Temp_Hshift(1,1:24)) == 3,sum(Temp_Hshift(1,5:21)) == 3];%��ƽ���ȸ��� ƽ�Ʊ�־
% 
%     for i=5:19%ʱ������Ϊ5~21-3+1
%     Constraints = [Constraints,sum(Temp_Hshift(1,i:i+2)) >= 3*(Temp_Hshift(1,i)-Temp_Hshift(1,i-1))];%����3��ʱ��
%     end
%     for i=1:24
%        Constraints = [Constraints,HHshift(1,i)== 45*Temp_Hshift(1,i)];%��ƽ�Ƶ縺��2��
%     end 
%     
%   %% ��ת�Ƶ縺��(����5��Ȼ�����2)
%   for i=1:24
%       Constraints = [Constraints,Temp_Ptran(i)*8<=PPtran(i)<=Temp_Ptran(i)*26.7 ];%��ת�Ƶ縺��
%   end
%       Constraints = [Constraints,sum(Temp_Ptran(1,1:24)) == 5,sum(Temp_Ptran(1,4:22)) ==5];%��ת�Ƶ縺��
%             Constraints = [Constraints,sum(Temp_Ptran(1,1:24)) ==5];%��ת�Ƶ縺��
%     for i=4:18 %ʱ������Ϊ4~22-5+1
%     Constraints = [Constraints,sum(Temp_Ptran(1,i:i+4)) >= 5*(Temp_Ptran(1,i)-Temp_Ptran(1,i-1))];
%     end
% 
% 
% %% �������縺��
% 
% Constraints=[Constraints,sum(Temp_Pcut)==8,sum(Temp_Pcut(1,5:22))==8];
% Constraints=[Constraints,2<=n1<=5];
%     for i=5:22-n1+1 %ʱ������Ϊ5~22-n1+1
%     Constraints = [Constraints,sum(Temp_Pcut(1,i:i+n1-1)) >= n1*(Temp_Pcut(1,i)-Temp_Pcut(1,i-1))];
%     end
% for i=1:24
%        Constraints = [Constraints,0<=PPcut(1,i)<=Temp_Pcut(1,i)*0.9*Pcut(i)];%�������縺��
% end
% %% �������ȸ���
% Constraints=[Constraints,sum(Temp_Hcut(1,1:24))==8,sum(Temp_Hcut(1,11:19))==8];
% Constraints=[Constraints,2<=n2<=5];
%     for i=11:19-n2+1 %ʱ������Ϊ11~19-n2+1
%     Constraints = [Constraints,sum(Temp_Hcut(1,i:i+n1-1)) >= n1*(Temp_Hcut(1,i)-Temp_Hcut(1,i-1))];
%     end
% for i=1:24
%        Constraints = [Constraints,Temp_Hcut(1,i)*0<=HHcut(1,i)<=Temp_Hcut(1,i)*0.9*Hcut(i)];%�������ȸ���
% end
%% ��ƽ��
   for i=1:24       
   Constraints = [Constraints,P_mt(i)+P_pv(i)+P_wt(i)+Pnet(i)-Pcharge(1,i)+Pdischarge(1,i)==e_load(i)]; %��ƽ��Լ��
   Constraints = [Constraints,P_GB(i)+0.83*P_mt(i)/0.45-Hcharge(1,i)+Hdischarge(1,i)==h_load(i)]; %��ƽ��Լ��
   end
      
%% Ŀ�꺯��
%% �Ӵ�����Ĺ���ɱ�
C_gridbuy=0;
for i=1:24
    C_gridbuy=C_gridbuy+Pbuy(i)*buy_price(i);
end
%% ���������۵�ɱ�
C_gridsell=0;
for i=1:24
    C_gridsell=C_gridsell+Psell(i)*sell_price(i);
end
%���гɱ�
C_OM=0;
for i=1:24
 C_OM=C_OM+0.72*P_pv(i)+0.52*P_wt(i);%��������ά�ɱ�
end

%% ȼ�ϳɱ�
C_fuel=0;
for i=1:24
 C_fuel=C_fuel+2.5*P_GB(i)/9.7+2.5*P_mt(i)/0.45/9.7;%�����ɱ�
end
%% �������гɱ�
C_storge=0;
for i=1:24
 C_storge=C_storge+0.5*(Pcharge(i)+Pdischarge(i)+Hcharge(i)+Hdischarge(i));%�������гɱ�
end

%% �����ɱ�
C_L=0;
% for i=1:24
%     C_L=C_L+0.2*(PPshift1(i)+PPshift2(i))+0.1*HHshift(i)+0.3*PPtran(i)+0.4*PPcut(i)+0.2*HHcut(i);
% end
%% ̼���׳ɱ�

Q_carbon=0;%̼�ŷ���-̼�����(��)
for i=1:24
    Q_carbon=Q_carbon+(((1303-798)*(Pbuy(i)+abs(Psell(i)))+(564.7-424)*(P_GB(i)/9.7+P_mt(i)/0.45/9.7)+...
        (43-78)*P_wt(i)+(154.5-78)*P_pv(i)+91.3*(Pcharge(i)+Pdischarge(i))));
end

E_v=sdpvar(1,5);%ÿ�������ڵĳ���,��Ϊ5��,ÿ�γ�����2000
lamda=0.15*10^(-3);%̼���׻���
Constraints=[Constraints,
   Q_carbon==sum(E_v),%�ܳ��ȵ���Q_carbon
   0<=E_v(1:4)<=120000,%�������һ�Σ�ÿ�����䳤��С�ڵ���120000g
   0<=E_v(5),
  ];
%̼���׳ɱ�
C_CO2=0;
for v=1:5
    C_CO2=C_CO2+(lamda+(v-1)*0.25*lamda)*E_v(v);
end


F= C_OM+C_fuel+C_gridbuy+C_gridsell+C_storge+C_L+C_CO2;
ops = sdpsettings('solver','cplex', 'verbose', 2);%����ָ��������cplex�����
optimize(Constraints,F,ops)
% ops=sdpsettings('solver','cplex');%������ⷽʽ
% [model,recoveryalmip,diagnostic,internalmodel]=export(Constraints,F,ops);%תΪcplexģ��
% milpt=Cplex('milp for htc');
% milpt.Model.sense='minimize';
% milpt.Model.obj=model.f;
% milpt.Model.lb=model.lb;
% milpt.Model.ub=model.ub;
% milpt.Model.A=[model.Aineq;model.Aeq];
% milpt.Model.lhs=[-inf*ones(size(model.bineq,1),1);model.beq];
% milpt.Model.rhs=[model.bineq;model.beq];
% milpt.Model.ctype=model.ctype;
% milpt.writeModel('ab.lp');%���cplexģ�ͣ�ע���Сд��
% milpt.solve();%ģ�����

F=value(F)%�ɱ�
P_pv=value(P_pv);
P_wt=value(P_wt);
P_mt=value(P_mt);
P_GB=value(P_GB);
Pcharge=value(Pcharge);
Pdischarge=value(Pdischarge);
Hcharge=value(Hcharge);
Hdischarge=value(Hdischarge);
Pbuy=value(Pbuy);
Psell=value(Psell);
PPshift1=value(PPshift1);
PPshift2=value(PPshift2);
PPtran=value(PPtran);
PPcut=value(PPcut);
HHshift=value(HHshift);
HHcut=value(HHcut);

%% ��ͼ

figure
ee=value([Pfix;Pcut;Pshift1;Pshift2;Ptran]);
bar(ee','stack');
legend('�����縺��','�������縺��','��ƽ�Ƶ縺��1','��ƽ�Ƶ縺��2','��ת�Ƶ縺��');
xlabel('ʱ��/h');
ylabel('�縺�ɹ���/kW');
title('�Ż�ǰ�û������Ե縺�ɷֲ�');


figure
hh=value([Hfix;Hcut;Hshift]);
bar(hh','stack');
legend('�����ȸ���','�������ȸ���','��ƽ���ȸ���');
xlabel('ʱ��/h');
ylabel('�ȸ��ɹ���/kW');
title('�Ż�ǰ�û��������ȸ��ɷֲ�');

% for i=1:24
%     op_e_load(i)=Pfix(i)+Pcut(i)+PPshift1(i)+PPshift2(i)+PPtran(i)-PPcut(i);
% end
x=1:24;
figure
plot(x,e_load,'-rs',x,e_load,'-bo');
xlabel('ʱ��/h');
ylabel('�縺��/kW');
title('������Ӧǰ��縺������');
legend('�Ż�ǰ�縺��','�Ż���縺��');

% for i=1:24
%     op_h_load(i)=Hfix(i)+Hcut(i)+HHshift(i)-HHcut(i);
% end
x=1:24;
figure
plot(x,h_load,'-rs',x,h_load,'-bo');
xlabel('ʱ��/h');
ylabel('�ȸ���/kW');
title('������Ӧǰ���ȸ�������');
legend('�Ż�ǰ�ȸ���','�Ż����ȸ���');


figure
stairs(x,buy_price,'-r')
hold on
stairs(x,sell_price,'-b')
hold on
title('�۸�����');
legend('�����','�۵��');

figure
plot(x,e_load,'-o')
hold on
plot(x,h_load,'-s')
hold on
plot(x,ppv,'-^')
hold on
plot(x,pwt,'-p')
title('�۸�����');
legend('�縺��','�ȸ���','�������','������');


b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
eee=value([Pbuy;Pdischarge;P_pv; P_mt;P_wt]);
eee1=value([Psell;-Pcharge;b;b;b]);
figure
bar(eee','stack');
hold on
plot(x,e_load,'-gs');
legend('������������','���س�ŵ�','�������','ȼ���ֻ�����','������','�縺������');
bar(eee1','stack');
title('�縺��ƽ��');
xlabel('ʱ��');ylabel('����/kW');

b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
hhh=value([P_GB;Hdischarge;0.83*P_mt/0.45]);
hhh1=value([b;-Hcharge;b]);
figure
bar(hhh','stack');
hold on
plot(x,h_load,'-rs');
legend('ȼ����¯����','�ȴ��ܳ����','ȼ���ֻ�����','�ȸ�������');
bar(hhh1','stack');
title('�ȸ���ƽ��');
xlabel('ʱ��');ylabel('����/kW');


for i=1:24
    PPPcut(i)=Pcut(i)-0; %��ʣ�Ŀ������縺��
end
figure
ee=value([Pfix;PPPcut;Pshift1;Pshift2;Ptran]);
bar(ee','stack');
legend('�����縺��','�������縺��','��ƽ�Ƶ縺��1','��ƽ�Ƶ縺��2','��ת�Ƶ縺��');
xlabel('ʱ��/h');
ylabel('�縺�ɹ���/kW');
title('�Ż����û������Ե縺�ɷֲ�');

for i=1:24
    HHHcut(i)=Hcut(i)-0; %��ʣ�Ŀ������ȸ���
end
figure
hh=value([Hfix;HHHcut;Hshift]);
bar(hh','stack');
legend('�����ȸ���','�������ȸ���','��ƽ���ȸ���');
xlabel('ʱ��/h');
ylabel('�ȸ��ɹ���/kW');
title('�Ż����û��������ȸ��ɷֲ�');
