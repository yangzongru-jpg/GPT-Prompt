%�û���������ΪĿ�꺯��
function [P_MT,F_user,F_share,Eload,Hload,ES,P_h,Prl,P_buy,P_sell] = computeObj(x,load_e,load_h,P_PV,pe_grid_B)
P_MT=sdpvar(1,24,'full');%΢ȼ�ֻ�����繦��
P_buy=sdpvar(1,24,'full');%�û�����Ӫ��������
P_sell=sdpvar(1,24,'full');%�û�������������
ES=sdpvar(1,24,'full');%��������
%% ����ඨ�����
%�縺�ɣ��̶�����ƽ�ơ����������ɡ�������
%�ȸ��ɣ��̶������������ȱ�����
Pfl=sdpvar(1,24,'full');%��ƽ�Ƶ縺����
eload=0.8*(load_e); %����֮��ĵ縺����
Pcl_h=sdpvar(1,24,'full');%�������ȸ�����
Prl=sdpvar(1,24,'full');%�������豸������
P_h=sdpvar(1,24,'full');%΢����Ӫ�̹�����
char=sdpvar(1,24,'full'); %��繦��
char_sign=binvar(1,24,'full');%����־ 
dischar=sdpvar(1,24,'full'); %�ŵ繦��
dischar_sign=binvar(1,24,'full');%�ŵ��־
%a ��b ��cΪ�û��ۺ��̵��õ�Ч�ú����Ĳ���
a=-0.05;b=4;
%΢ȼ���ϵ��
MT_e=0.4; %����Ч��
MT_h=0.8;   %����Ч��
MT_hh=0.05;%ɢ����ʧ��

%Լ������
C =[];
%% �����ܷ�����
ESS_max=1350;ESS_char=0.95;ESS_dischar=0.95;%�索������/���/�ŵ�
SOC0=0.5;
ES(1,1)=SOC0*ESS_max;%%��ʼ����
 for t=2:25  %��һ�������ڵĳ�ŵ繦��Ϊ��
     C=[C,(ES(mod(t-1,24)+1)==(ES(mod(t-2,24)+1)+(ESS_char*char(mod(t-2,24)+1)-(1/ESS_dischar)*dischar(mod(t-2,24)+1))))];
     C=[C,ES(1,1)==SOC0*ESS_max];
 end
for i=1:24
     C=[C,300<=ES(1,i)<=1350]; %��������Լ��
     C=[C,0<=char(1,i)<=50*char_sign(1,i)]; %��ŵ�Լ��
     C=[C,0<=dischar(1,i)<=50*dischar_sign(1,i)];  
end
%���س�ŵ�Լ��
 for i=1:24
     C=[C,char_sign(1,i)+dischar_sign(1,i)<=1];    
 end
  C=[C,10<=sum(char_sign(1,1:24)+dischar_sign(1,1:24))<=20];%��������
%% �ۺ���Դ��Ӫ�̡�������Ӫ�̡��û������ߵ�������
for i=1:24
    C = [C,0<=P_MT(i)<=500];%΢ȼ�ֻ�������Լ��
    C = [C,0<=Pfl(i)<=80];%��ƽ�Ƶ縺������ 
    C = [C,0<=Pcl_h(i)<=25];%�ȸ����������� 
    C = [C,5<=Prl(i)<=60];%�������豸��������� 
    C = [C,0<=P_h(i)];%��΢���������� 
    C = [C,0<=P_sell(i)<=100];%�û����������
    C = [C,0<=P_buy(i)<=250];%�û�����Ӫ�����
end
% for i=1:24
%     C = [C, 0<=Pbuy(i)<=Temp_net(1,i)*300]; %��Ӫ�̹���Լ��Լ��
%     C = [C, 0<=Psell(i)<=(1-Temp_net(1,i))*300]; %��Ӫ���۵�Լ��Լ��
%     C = [C, 0<=Pbuy(i)<=Temp_net(1,i)*300]; %��Ӫ�̹���Լ��Լ��
% end

C = [C,sum(Pfl(1:i))==0.2*sum(load_e(1:i))];%��ƽ�Ƹ�����������Լ��
C = [C,sum(Pcl_h(1:i))==0.15*sum(load_h(1:i))];%����������Լ��
 
  
for i=1:24       
C = [C,P_MT(i)+P_buy(i)-P_sell(i)==-char(1,i)+dischar(1,i)+eload(i)+Pfl(i)+Prl(i)/0.9-P_PV(i)]; %��ƽ��Լ��
C = [C,P_MT(i)/MT_e*(1-MT_e-MT_hh)*MT_h==P_h(i)];%΢ȼ����Լ��
C = [C,P_h(i)+Prl(i)==load_h(i)-Pcl_h(i)];%��ƽ��Լ��(�����²�ͬ����Ϊ���������һ��)
end

%�����ܷ���������
F_share=0;
%% �û���Ŀ�꺯��
F_e=0;F_g=0;

for i=1:24
   F_e=F_e-x(i).*(P_MT(i)+P_buy(i))+P_sell(i)*pe_grid_B(i)-0.1*(char(1,i)+dischar(1,i))-0.1*(Pcl_h(i))^2+a*(0.8*load_e(i)+Pfl(i)+Prl(i)/0.9)^2/4+b*(0.8*load_e(i)+Pfl(i)+Prl(i)/0.9);
   %; %���ɱ�
   F_share=F_share+(0.1-0.05)*(char(1,i)+dischar(1,i))+700;%����������,700Ϊ�����
   F_g=F_g-x(i+24).*P_h(i);%���ȳɱ�
end

F=F_e+F_g;
ops = sdpsettings('solver','cplex', 'verbose', 2);%����ָ��������cplex�����
optimize(C,-F,ops)
P_MT=value(P_MT);
F_user=value(F);
F_share=value(F_share);
Eload=value(eload+Pfl+Prl/0.9);
Hload=value(load_h-Pcl_h);
ES=value(ES);
P_h=value(P_h);
Prl=value(Prl);
P_buy=value(P_buy);
% Psell=value(Psell);
P_sell=value(P_sell);
end

    



