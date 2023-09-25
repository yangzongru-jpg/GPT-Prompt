%% [SCI���¸���]A cooperative Stackelberg game based energy management considering price discrimination and risk assessment
%[����]���ں�����Stackerlberg���ĵĿ��ǲ�𶨼ۺͷ��չ����΢�����в���
%International Journal of Electrical Power and Energy Systems,SCI����
%Highlights:������Stackerlberg����,��ʲ̸��,��𶨼�
%P1(��С�����гɱ�)������

clc
clear
close all

%% ���߱�����ʼ��
zeta=sdpvar(1,3); %���ڼ��������CVaR�ĸ�������
eta_1=sdpvar(10,1); %������1��ÿ�������еķ��յ��ȸ�������
eta_2=sdpvar(10,1); %������2��ÿ�������еķ��յ��ȸ�������
eta_3=sdpvar(10,1); %������3��ÿ�������еķ��յ��ȸ�������
P_Ps_1=sdpvar(10,24); %�������������1������
P_Ps_2=sdpvar(10,24); %�������������2������
P_Ps_3=sdpvar(10,24); %�������������3������
P_Pb_1=sdpvar(10,24); %�����̴Ӳ�����1������
P_Pb_2=sdpvar(10,24); %�����̴Ӳ�����2������
P_Pb_3=sdpvar(10,24); %�����̴Ӳ�����3������
u_Ps=sdpvar(3,24); %������������߹��ܼ۸�
u_Pb=sdpvar(3,24); %�����̴Ӳ����߹��ܼ۸�
P_trading_1=sdpvar(10,24); %������1�������Ľ�����
P_trading_2=sdpvar(10,24); %������2�������Ľ�����
P_trading_3=sdpvar(10,24); %������3�������Ľ�����
SOC_1=sdpvar(10,24); %������1��������״̬,��λ%
SOC_2=sdpvar(10,24); %������2��������״̬,��λ%
SOC_3=sdpvar(10,24); %������3��������״̬,��λ%
P_Ec_1=sdpvar(10,24); %������1�Ĵ����豸�����
P_Ec_2=sdpvar(10,24); %������2�Ĵ����豸�����
P_Ec_3=sdpvar(10,24); %������3�Ĵ����豸�����
P_Ed_1=sdpvar(10,24); %������1�Ĵ����豸�ŵ���
P_Ed_2=sdpvar(10,24); %������2�Ĵ����豸�ŵ���
P_Ed_3=sdpvar(10,24); %������3�Ĵ����豸�ŵ���
Uabs_1=binvar(10,24); %���ܳ�ŵ�״̬
Uabs_2=binvar(10,24); %���ܳ�ŵ�״̬
Uabs_3=binvar(10,24); %���ܳ�ŵ�״̬
Urelea_1=binvar(10,24); %���ܳ�ŵ�״̬
Urelea_2=binvar(10,24); %���ܳ�ŵ�״̬
Urelea_3=binvar(10,24); %���ܳ�ŵ�״̬
%��Ӧ���²�Լ�������Ķ�ż����
lamda_pro_1=sdpvar(10,24); %ʽ(10)�Ķ�ż����
lamda_pro_2=sdpvar(10,24);
lamda_pro_3=sdpvar(10,24);
lamda_trading=sdpvar(10,24); %ʽ(11)�Ķ�ż����
lamda_Pb_1=sdpvar(10,24); %ʽ(12)�Ķ�ż����
lamda_Pb_2=sdpvar(10,24);
lamda_Pb_3=sdpvar(10,24);
lamda_Ps_1=sdpvar(10,24); %ʽ(13)�Ķ�ż����
lamda_Ps_2=sdpvar(10,24);
lamda_Ps_3=sdpvar(10,24);
lamda_Ec_1=sdpvar(10,24); %ʽ(14)�Ķ�ż����
lamda_Ec_2=sdpvar(10,24);
lamda_Ec_3=sdpvar(10,24);
lamda_Ed_1=sdpvar(10,24); %ʽ(15)�Ķ�ż����
lamda_Ed_2=sdpvar(10,24);
lamda_Ed_3=sdpvar(10,24);
lamda_SOCmin_1=sdpvar(10,24); %ʽ(16)�����޶�Ӧ�Ķ�ż����
lamda_SOCmin_2=sdpvar(10,24);
lamda_SOCmin_3=sdpvar(10,24);
lamda_SOCmax_1=sdpvar(10,24); %ʽ(16)�����޶�Ӧ�Ķ�ż����
lamda_SOCmax_2=sdpvar(10,24);
lamda_SOCmax_3=sdpvar(10,24);
lamda_SOC1_1=sdpvar(10,24); %ʽ(17-18)�Ķ�ż����
lamda_SOC1_2=sdpvar(10,24);
lamda_SOC1_3=sdpvar(10,24);
lamda_SOC2_1=sdpvar(10,1); %ʽ(19)�Ķ�ż����
lamda_SOC2_2=sdpvar(10,1);
lamda_SOC2_3=sdpvar(10,1);
%% ���볣������
%������/�����̴���������۸�(Ԫ/MW)
u_Db=1e3*[0.4,0.4,0.4,0.4,0.4,0.4,0.79,0.79,0.79,1.2,1.2,1.2,1.2,1.2,0.79,0.79,0.79,1.2,1.2,1.2,0.79,0.79,0.4,0.4];
%������/�������������۵�۸�(Ԫ/MW)
u_Ds=1e3*[0.35,0.35,0.35,0.35,0.35,0.35,0.68,0.68,0.68,1.12,1.12,1.12,1.12,1.12,0.68,0.68,0.68,1.12,1.12,1.12,0.79,0.79,0.35,0.35];
%������������ߵĽ��׼۸�������
u_Pbmax=1e3*[0.7,0.7,0.7,0.7,0.7,0.7,1.1,1.1,1.1,1.5,1.5,1.5,1.5,1.5,1,1,1,1.5,1.5,1.5,1.1,1.1,0.7,0.7]; %��������
u_Pbmin=u_Pbmax-0.5*1e3*ones(1,24); %��������
u_Psmax=u_Ds; %�ۼ�����
u_Psmin=u_Psmax-0.35*1e3*ones(1,24); %�ۼ�����
%������1-3�ĵ縺��(MW)
P_load_1=[6.62295082,5.770491803,5.442622951,5.31147541,5.37704918,5.573770492,6.295081967,6.491803279,7.213114754,7.803278689,8.131147541,8.131147541,7.93442623,7.278688525,7.016393443,7.016393443,7.147540984,8.262295082,9.442622951,9.37704918,9.37704918,7.93442623,6.819672131,5.901639344];
P_load_2=[3.344262295,3.016393443,2.754098361,2.754098361,2.754098361,2.885245902,3.147540984,3.344262295,3.639344262,3.93442623,4,4.131147541,4,3.737704918,3.475409836,3.606557377,3.606557377,4.131147541,4.721311475,4.655737705,4.721311475,4,3.409836066,3.016393443];
P_load_3=[11.60655738,10.16393443,9.442622951,9.245901639,9.114754098,9.639344262,10.75409836,11.3442623,12.45901639,13.50819672,14.10772834,14.16393443,13.63934426,12.72131148,12.19672131,12.32786885,12.59016393,14.29508197,16.59016393,16.45901639,16.26229508,13.7704918,12.13114754,10.55737705];
%������1-3  ����10�������ĳ����͸���
Sw=10; %��������
load P_Gen.mat  %������1������    P_Gen_1  ά�ȣ�10*24     P_Gen_2    P_Gen_3 
%������1-3��糡������
pai_1=0.1*ones(1,10);pai_2=0.1*ones(1,10);pai_3=0.1*ones(1,10); %(ԭ���߻�Ӧ���и��ʾ�Ϊ0.1)
%�����̶�����
C_E=80; %���ܳ�ųɱ�
P_Pbmax=15; %��󹺵���
P_Psmax=15; %����۵���
Cap=10; %���������MW
P_Ecmax=3; %����ܹ�������
P_Edmax=3; %����ܹ�������
SOCmin=0.2; %��С�洢���ٷֱ� ��λ%
SOCmax=0.85; %��������ٷֱ�
SOCini=0.33; %��ʼ�����ٷֱ�
SOCexp=0.85; %ĩ�������ٷֱ�
beta=0.1; %������ϵ��
M=1E8; %Big-M��M
%% ����Լ������
C=[];
%������(�����쵼��)��Լ������(��ʽ2-6)
u_Ps_ave=0.85*1e3;%���ƽ���۵��
u_Pb_ave=1.20*1e3;%���ƽ�������
C=[C,
   u_Pbmin<=u_Pb(1,:)<=u_Pbmax, %�������������̹���۸��������Լ��
   u_Pbmin<=u_Pb(2,:)<=u_Pbmax,
   u_Pbmin<=u_Pb(3,:)<=u_Pbmax,
   u_Psmin<=u_Ps(1,:)<=u_Psmax, %���������������۵�۸��������Լ��
   u_Psmin<=u_Ps(2,:)<=u_Psmax,
   u_Psmin<=u_Ps(3,:)<=u_Psmax,
   sum(u_Pb(1,:))/24<=u_Pb_ave, %�������������̹���۸񲻳����վ�����������
   sum(u_Pb(2,:))/24<=u_Pb_ave,
   sum(u_Pb(3,:))/24<=u_Pb_ave,
   sum(u_Ps(1,:))/24<=u_Ps_ave, %���������������۵�۸񲻳����վ�������۵��
   sum(u_Ps(2,:))/24<=u_Ps_ave,    
   sum(u_Ps(3,:))/24<=u_Ps_ave,
  ];
%CVaR����
biliner_eq1=0;biliner_eq2=0;biliner_eq3=0;
%���㹫ʽ(6)�еķ��������Ч��
for w=1:Sw   
    biliner_eq1=biliner_eq1+sum(lamda_pro_1(w,:).*(P_load_1(1,:)-P_Gen_1(w,:)))+sum(lamda_Pb_1(w,:)*P_Pbmax)+sum(lamda_Ps_1(w,:)*P_Psmax)+...
                sum(lamda_Ec_1(w,:)*P_Ecmax)+sum(lamda_Ed_1(w,:)*P_Edmax)+sum(lamda_SOCmax_1(w,:)*SOCmax)+sum(lamda_SOCmin_1(w,:)*SOCmin);
    biliner_eq2=biliner_eq2+sum(lamda_pro_2(w,:).*(P_load_2(1,:)-P_Gen_2(w,:)))+sum(lamda_Pb_2(w,:)*P_Pbmax)+sum(lamda_Ps_2(w,:)*P_Psmax)+...
                sum(lamda_Ec_2(w,:)*P_Ecmax)+sum(lamda_Ed_2(w,:)*P_Edmax)+sum(lamda_SOCmax_2(w,:)*SOCmax)+sum(lamda_SOCmin_2(w,:)*SOCmin);
    biliner_eq3=biliner_eq3+sum(lamda_pro_3(w,:).*(P_load_3(1,:)-P_Gen_3(w,:)))+sum(lamda_Pb_3(w,:)*P_Pbmax)+sum(lamda_Ps_3(w,:)*P_Psmax)+...
                sum(lamda_Ec_3(w,:)*P_Ecmax)+sum(lamda_Ed_3(w,:)*P_Edmax)+sum(lamda_SOCmax_3(w,:)*SOCmax)+sum(lamda_SOCmin_3(w,:)*SOCmin);            
end
%CVaRԼ��
for w=1:Sw   
    C=[C,
       zeta(1)-(u_Ds*P_Ps_1(w,:)'-u_Db*P_Pb_1(w,:)'+biliner_eq1)<=eta_1(w),
       zeta(2)-(u_Ds*P_Ps_2(w,:)'-u_Db*P_Pb_2(w,:)'+biliner_eq2)<=eta_2(w),
       zeta(3)-(u_Ds*P_Ps_3(w,:)'-u_Db*P_Pb_3(w,:)'+biliner_eq3)<=eta_3(w),
       0<=eta_1(w),
       0<=eta_2(w),
       0<=eta_3(w),
      ];
end
%������(���ĸ�����)��Լ������(��ʽ10-19)
%�����ߵĵ繦��ƽ��Լ��
for w=1:Sw
    C=[C,
       P_Pb_1(w,:)+P_Gen_1(w,:)+P_Ed_1(w,:)+P_trading_1(w,:)==P_Ps_1(w,:)+P_load_1(1,:)+P_Ec_1(w,:), 
       P_Pb_2(w,:)+P_Gen_2(w,:)+P_Ed_2(w,:)+P_trading_2(w,:)==P_Ps_2(w,:)+P_load_2(1,:)+P_Ec_2(w,:), 
       P_Pb_3(w,:)+P_Gen_3(w,:)+P_Ed_3(w,:)+P_trading_3(w,:)==P_Ps_3(w,:)+P_load_3(1,:)+P_Ec_3(w,:), 
      ];    
end
P_trading_max=5.5;%�����������
for w=1:Sw
   for t=1:24
       C=[C,
          P_trading_1(w,t)+P_trading_2(w,t)+P_trading_3(w,t)==0, %����ʱ���ܽ�����֮��Ϊ��
          -P_trading_max<=P_trading_1(w,t)<=P_trading_max, %������������
          -P_trading_max<=P_trading_2(w,t)<=P_trading_max,
          -P_trading_max<=P_trading_3(w,t)<=P_trading_max,
         ];
   end
end
C=[C,
   0<=P_Pb_1(1:Sw,:)<=P_Pbmax, %�����ߵĹ�����������Լ��
   0<=P_Pb_2(1:Sw,:)<=P_Pbmax,
   0<=P_Pb_3(1:Sw,:)<=P_Pbmax,
   0<=P_Ps_1(1:Sw,:)<=P_Psmax, %�����ߵ��۵���������Լ��
   0<=P_Ps_2(1:Sw,:)<=P_Psmax,
   0<=P_Ps_3(1:Sw,:)<=P_Psmax,
   0<=P_Ec_1(1:Sw,:)<=P_Ecmax, %�����ߵĴ����豸�����������Լ��
   0<=P_Ec_2(1:Sw,:)<=P_Ecmax,
   0<=P_Ec_3(1:Sw,:)<=P_Ecmax,
   0<=P_Ed_1(1:Sw,:)<=P_Edmax, %�����ߵĴ����豸�ŵ���������Լ��
   0<=P_Ed_2(1:Sw,:)<=P_Edmax,
   0<=P_Ed_3(1:Sw,:)<=P_Edmax,
   SOCmin<=SOC_1(1:Sw,:)<=SOCmax, %�����ߵĴ����豸�ĺɵ�״̬��������Լ��
   SOCmin<=SOC_2(1:Sw,:)<=SOCmax,
   SOCmin<=SOC_2(1:Sw,:)<=SOCmax,
   SOC_1(:,1)*Cap==(SOCini*Cap+(0.95*P_Ec_1(:,1)-1/1.05*P_Ed_1(:,1))), %�����ߵĴ����豸��0-1ʱ�εĺɵ�״̬Լ��
   SOC_2(:,1)*Cap==(SOCini*Cap+(0.95*P_Ec_2(:,1)-1/1.05*P_Ed_2(:,1))),
   SOC_3(:,1)*Cap==(SOCini*Cap+(0.95*P_Ec_3(:,1)-1/1.05*P_Ed_3(:,1))),
   SOC_1(:,24)==SOCexp, %�����ߵĴ����豸��ĩ̬�ɵ�״̬Ӧ���������ɵ�״̬��ͬ
   SOC_2(:,24)==SOCexp,
   SOC_3(:,24)==SOCexp,
  ];
%�����ߵĴ����豸��1-24ʱ�εĺɵ�״̬Լ��
for t=2:24
    C=[C,
       SOC_1(:,t)*Cap==(SOC_1(:,t-1)*Cap+(0.95*P_Ec_1(:,t)-1/1.05*P_Ed_1(:,t))),
       SOC_2(:,t)*Cap==(SOC_2(:,t-1)*Cap+(0.95*P_Ec_2(:,t)-1/1.05*P_Ed_2(:,t))),
       SOC_3(:,t)*Cap==(SOC_3(:,t-1)*Cap+(0.95*P_Ec_3(:,t)-1/1.05*P_Ed_3(:,t))),
      ];
end
for t=1:24
    C=[C,
       0<=P_Ec_1(:,t)<=P_Ecmax,
       0<=P_Ec_1(:,t)<=Uabs_1(:,t)*M,
       0<=P_Ed_1(:,t)<=P_Edmax,
       0<=P_Ed_1(:,t)<=Urelea_1(:,t)*M,
       Uabs_1(:,t)+Urelea_1(:,t)<=1,   %ȷ����ŵ�״̬������ͬʱ����
       0<=P_Ec_2(:,t)<=P_Ecmax,
       0<=P_Ec_2(:,t)<=Uabs_2(:,t)*M,
       0<=P_Ed_2(:,t)<=P_Edmax,
       0<=P_Ed_2(:,t)<=Urelea_2(:,t)*M,
       Uabs_2(:,t)+Urelea_2(:,t)<=1,   %ȷ����ŵ�״̬������ͬʱ����
       0<=P_Ec_3(:,t)<=P_Ecmax,
       0<=P_Ec_3(:,t)<=Uabs_3(:,t)*M,
       0<=P_Ed_3(:,t)<=P_Edmax,
       0<=P_Ed_3(:,t)<=Urelea_3(:,t)*M,
       Uabs_3(:,t)+Urelea_3(:,t)<=1,   %ȷ����ŵ�״̬������ͬʱ����
      ];
end
%�²��Ӧ�ĸ�ƽ��Լ��(��ʽ27-��ʽ33)
for w=1:Sw
   C=[C,
      lamda_pro_1(w,:)+lamda_Pb_1(w,:)<=u_Pb(1,:), %��ʽ27
      lamda_pro_2(w,:)+lamda_Pb_2(w,:)<=u_Pb(2,:), 
      lamda_pro_3(w,:)+lamda_Pb_3(w,:)<=u_Pb(3,:), 
      -lamda_pro_1(w,:)+lamda_Ps_1(w,:)<=-u_Ps(1,:), %��ʽ28
      -lamda_pro_2(w,:)+lamda_Ps_2(w,:)<=-u_Ps(2,:), 
      -lamda_pro_3(w,:)+lamda_Ps_3(w,:)<=-u_Ps(3,:), 
      lamda_pro_1(w,:)+lamda_trading(w,:)==0, %��ʽ29
      lamda_pro_2(w,:)+lamda_trading(w,:)==0,
      lamda_pro_3(w,:)+lamda_trading(w,:)==0,
      -lamda_pro_1(w,:)+lamda_Ec_1(w,:)-0.95*lamda_SOC1_1(w,:)<=C_E*ones(1,24), %��ʽ30
      -lamda_pro_2(w,:)+lamda_Ec_2(w,:)-0.95*lamda_SOC1_2(w,:)<=C_E*ones(1,24),
      -lamda_pro_3(w,:)+lamda_Ec_3(w,:)-0.95*lamda_SOC1_3(w,:)<=C_E*ones(1,24),
      lamda_pro_1(w,:)+lamda_Ed_1(w,:)+1/1.05*lamda_SOC1_1(w,:)<=C_E*ones(1,24), %��ʽ31
      lamda_pro_2(w,:)+lamda_Ed_2(w,:)+1/1.05*lamda_SOC1_2(w,:)<=C_E*ones(1,24),
      lamda_pro_3(w,:)+lamda_Ed_3(w,:)+1/1.05*lamda_SOC1_3(w,:)<=C_E*ones(1,24),     
      lamda_SOCmax_1(w,24)+lamda_SOCmin_1(w,24)+Cap*lamda_SOC1_1(w,24)+lamda_SOC2_1(w)==0, %��ʽ33
      lamda_SOCmax_2(w,24)+lamda_SOCmin_2(w,24)+Cap*lamda_SOC1_2(w,24)+lamda_SOC2_2(w)==0, %��ʽ33
      lamda_SOCmax_3(w,24)+lamda_SOCmin_3(w,24)+Cap*lamda_SOC1_3(w,24)+lamda_SOC2_3(w)==0, %��ʽ33
     ]; 
end
for w=1:Sw
   for t=1:23
       C=[C,
          lamda_SOCmax_1(w,t)+lamda_SOCmin_1(w,t)+Cap*lamda_SOC1_1(w,t)-Cap*lamda_SOC1_1(w,t+1)==0, %��ʽ32
          lamda_SOCmax_2(w,t)+lamda_SOCmin_2(w,t)+Cap*lamda_SOC1_2(w,t)-Cap*lamda_SOC1_2(w,t+1)==0,
          lamda_SOCmax_3(w,t)+lamda_SOCmin_3(w,t)+Cap*lamda_SOC1_3(w,t)-Cap*lamda_SOC1_3(w,t+1)==0,
         ];
   end
end
%����Big-M������Ĳ�������(����Ϊʽ34-43�Ĳ�������)
v34_1=binvar(Sw,24);v34_2=binvar(Sw,24);v34_3=binvar(Sw,24); 
v35_1=binvar(Sw,24);v35_2=binvar(Sw,24);v35_3=binvar(Sw,24);
v36_1=binvar(Sw,24);v36_2=binvar(Sw,24);v36_3=binvar(Sw,24);
v37_1=binvar(Sw,24);v37_2=binvar(Sw,24);v37_3=binvar(Sw,24);
v38_1=binvar(Sw,24);v38_2=binvar(Sw,24);v38_3=binvar(Sw,24);
v39_1=binvar(Sw,24);v39_2=binvar(Sw,24);v39_3=binvar(Sw,24);
v40_1=binvar(Sw,24);v40_2=binvar(Sw,24);v40_3=binvar(Sw,24);
v41_1=binvar(Sw,24);v41_2=binvar(Sw,24);v41_3=binvar(Sw,24);
v42_1=binvar(Sw,24);v42_2=binvar(Sw,24);v42_3=binvar(Sw,24);
v43_1=binvar(Sw,24);v43_2=binvar(Sw,24);v43_3=binvar(Sw,24);
for w=1:Sw
   for t=1:24
       C=[C,
          0>=lamda_Pb_1(w,t)>=-M*v34_1(w,t), %��ʽ34
          0>=P_Pb_1(w,t)-P_Pbmax>=-M*(1-v34_1(w,t)),
          0>=lamda_Pb_2(w,t)>=-M*v34_2(w,t),
          0>=P_Pb_2(w,t)-P_Pbmax>=-M*(1-v34_2(w,t)),
          0>=lamda_Pb_3(w,t)>=-M*v34_3(w,t),
          0>=P_Pb_3(w,t)-P_Pbmax>=-M*(1-v34_3(w,t)),            
          0>=lamda_Ps_1(w,t)>=-M*v35_1(w,t), %��ʽ35
          0>=P_Ps_1(w,t)-P_Psmax>=-M*(1-v35_1(w,t)),
          0>=lamda_Ps_2(w,t)>=-M*v35_2(w,t),
          0>=P_Ps_2(w,t)-P_Psmax>=-M*(1-v35_2(w,t)),
          0>=lamda_Ps_3(w,t)>=-M*v35_3(w,t),
          0>=P_Ps_3(w,t)-P_Psmax>=-M*(1-v35_3(w,t)),            
          0>=lamda_Ec_1(w,t)>=-M*v36_1(w,t), %��ʽ36
          0>=P_Ec_1(w,t)-P_Ecmax>=-M*(1-v36_1(w,t)),            
          0>=lamda_Ec_2(w,t)>=-M*v36_2(w,t),
          0>=P_Ec_2(w,t)-P_Ecmax>=-M*(1-v36_2(w,t)),              
          0>=lamda_Ec_3(w,t)>=-M*v36_3(w,t),
          0>=P_Ec_3(w,t)-P_Ecmax>=-M*(1-v36_3(w,t)),            
          0>=lamda_Ed_1(w,t)>=-M*v37_1(w,t), %��ʽ37
          0>=P_Ed_1(w,t)-P_Edmax>=-M*(1-v37_1(w,t)),            
          0>=lamda_Ed_2(w,t)>=-M*v37_2(w,t),
          0>=P_Ed_2(w,t)-P_Edmax>=-M*(1-v37_2(w,t)),              
          0>=lamda_Ed_3(w,t)>=-M*v37_3(w,t),
          0>=P_Ed_3(w,t)-P_Edmax>=-M*(1-v37_3(w,t)),              
          0>=lamda_SOCmax_1(w,t)>=-M*v38_1(w,t), %��ʽ38
          0>=SOC_1(w,t)-SOCmax>=-M*(1-v38_1(w,t)),    
          0>=lamda_SOCmax_2(w,t)>=-M*v38_2(w,t),
          0>=SOC_2(w,t)-SOCmax>=-M*(1-v38_2(w,t)),  
          0>=lamda_SOCmax_3(w,t)>=-M*v38_3(w,t),
          0>=SOC_3(w,t)-SOCmax>=-M*(1-v38_3(w,t)),            
          0<=lamda_SOCmin_1(w,t)<=M*v39_1(w,t), %��ʽ39
          0<=SOC_1(w,t)-SOCmin<=M*(1-v39_1(w,t)),    
          0<=lamda_SOCmin_2(w,t)<=M*v39_2(w,t),
          0<=SOC_2(w,t)-SOCmin<=M*(1-v39_2(w,t)),  
          0<=lamda_SOCmin_3(w,t)<=M*v39_3(w,t),
          0<=SOC_3(w,t)-SOCmin<=M*(1-v39_3(w,t)),             
          0<=P_Pb_1(w,t)<=M*v40_1(w,t), %��ʽ40
          0<=u_Pb(1,t)-lamda_pro_1(w,t)-lamda_Pb_1(w,t)<=M*(1-v40_1(w,t)),             
          0<=P_Pb_2(w,t)<=M*v40_2(w,t),
          0<=u_Pb(2,t)-lamda_pro_2(w,t)-lamda_Pb_2(w,t)<=M*(1-v40_2(w,t)),    
          0<=P_Pb_3(w,t)<=M*v40_3(w,t),
          0<=u_Pb(3,t)-lamda_pro_3(w,t)-lamda_Pb_3(w,t)<=M*(1-v40_3(w,t)),           
          0<=P_Ps_1(w,t)<=M*v41_1(w,t), %��ʽ41
          0<=-u_Ps(1,t)+lamda_pro_1(w,t)-lamda_Ps_1(w,t)<=M*(1-v41_1(w,t)),              
          0<=P_Ps_2(w,t)<=M*v41_2(w,t),
          0<=-u_Ps(2,t)+lamda_pro_2(w,t)-lamda_Ps_2(w,t)<=M*(1-v41_2(w,t)), 
          0<=P_Ps_3(w,t)<=M*v41_3(w,t),
          0<=-u_Ps(3,t)+lamda_pro_3(w,t)-lamda_Ps_3(w,t)<=M*(1-v41_3(w,t)),             
          0<=P_Ec_1(w,t)<=M*v42_1(w,t), %��ʽ42
          0<=C_E+lamda_pro_1(w,t)-lamda_Ec_1(w,t)+0.95*lamda_SOC1_1(w,t)<=M*(1-v42_1(w,t)),              
          0<=P_Ec_2(w,t)<=M*v42_2(w,t),
          0<=C_E+lamda_pro_2(w,t)-lamda_Ec_2(w,t)+0.95*lamda_SOC1_2(w,t)<=M*(1-v42_2(w,t)),                 
          0<=P_Ec_3(w,t)<=M*v42_3(w,t),
          0<=C_E+lamda_pro_3(w,t)-lamda_Ec_3(w,t)+0.95*lamda_SOC1_3(w,t)<=M*(1-v42_3(w,t)),              
          0<=P_Ed_1(w,t)<=M*v43_1(w,t), %��ʽ43
          0<=C_E-lamda_pro_1(w,t)-lamda_Ed_1(w,t)-1/1.05*lamda_SOC1_1(w,t)<=M*(1-v43_1(w,t)),               
          0<=P_Ed_2(w,t)<=M*v43_2(w,t),
          0<=C_E-lamda_pro_2(w,t)-lamda_Ed_2(w,t)-1/1.05*lamda_SOC1_2(w,t)<=M*(1-v43_2(w,t)),   
          0<=P_Ed_3(w,t)<=M*v43_3(w,t),
          0<=C_E-lamda_pro_3(w,t)-lamda_Ed_3(w,t)-1/1.05*lamda_SOC1_3(w,t)<=M*(1-v43_3(w,t)),                                   
         ];
   end
end
%% ����Ŀ�꺯��
%ͨ��ǿ��ż������ȥ˫������
obj_single=0;
for w=1:Sw
 obj_single=obj_single+...
   pai_1(w)*(u_Ds*P_Ps_1(w,:)'-u_Db*P_Pb_1(w,:)'-C_E*sum(P_Ec_1(w,:)+P_Ed_1(w,:))+sum(lamda_pro_1(w,:).*(P_load_1(1,:)-P_Gen_1(w,:)))+...
            sum(lamda_Pb_1(w,:)*P_Pbmax)+sum(lamda_Ps_1(w,:)*P_Psmax)+sum(lamda_Ec_1(w,:)*P_Ecmax)+sum(lamda_Ed_1(w,:)*P_Edmax)+...
            sum(lamda_SOCmax_1(w,:)*SOCmax)+sum(lamda_SOCmin_1(w,:)*SOCmin))+...
   pai_2(w)*(u_Ds*P_Ps_2(w,:)'-u_Db*P_Pb_2(w,:)'-C_E*sum(P_Ec_2(w,:)+P_Ed_2(w,:))+sum(lamda_pro_2(w,:).*(P_load_2(1,:)-P_Gen_2(w,:)))+...
            sum(lamda_Pb_2(w,:)*P_Pbmax)+sum(lamda_Ps_2(w,:)*P_Psmax)+sum(lamda_Ec_2(w,:)*P_Ecmax)+sum(lamda_Ed_2(w,:)*P_Edmax)+...
            sum(lamda_SOCmax_2(w,:)*SOCmax)+sum(lamda_SOCmin_2(w,:)*SOCmin))+...
   pai_3(w)*(u_Ds*P_Ps_3(w,:)'-u_Db*P_Pb_3(w,:)'-C_E*sum(P_Ec_3(w,:)+P_Ed_3(w,:))+sum(lamda_pro_3(w,:).*(P_load_3(1,:)-P_Gen_3(w,:)))+...
            sum(lamda_Pb_3(w,:)*P_Pbmax)+sum(lamda_Ps_3(w,:)*P_Psmax)+sum(lamda_Ec_3(w,:)*P_Ecmax)+sum(lamda_Ed_3(w,:)*P_Edmax)+...
            sum(lamda_SOCmax_3(w,:)*SOCmax)+sum(lamda_SOCmin_3(w,:)*SOCmin));
end
obj_single=obj_single+beta*(zeta(1)-pai_1*eta_1/(1-0.95))+beta*(zeta(2)-pai_2*eta_2/(1-0.95))+beta*(zeta(3)-pai_3*eta_3/(1-0.95));%��ӷ��յ��ȳɱ�
%% ������������
ops=sdpsettings('solver','cplex','verbose',2,'usex0',0);
ops.cplex.mip.tolerances.mipgap=0.1;
%% ����������         
result=optimize(C,-obj_single,ops);
if result.problem==0 
    % problem =0 �������ɹ� 
    % do nothing!
else
    error('������');
end  
%% ����������н��
P_trading_1=double(P_trading_1);P_trading_2=double(P_trading_2);P_trading_3=double(P_trading_3);
%��������ߺ����ɱ�C_trade
C_trade_1=zeros(1,10);C_trade_2=zeros(1,10);C_trade_3=zeros(1,10);
for w=1:Sw
    C_trade_1(w)=biliner_eq1+C_E*sum(P_Ec_1(w,:)+P_Ed_1(w,:));
    C_trade_2(w)=biliner_eq2+C_E*sum(P_Ec_2(w,:)+P_Ed_2(w,:));
    C_trade_3(w)=biliner_eq3+C_E*sum(P_Ec_3(w,:)+P_Ed_3(w,:));
end
save C_trade C_trade_1 C_trade_2 C_trade_3
save P_trading P_trading_1 P_trading_2 P_trading_3
%% ���ݷ����뻭ͼ
P_Ps_1=double(P_Ps_1);P_Ps_2=double(P_Ps_2);P_Ps_3=double(P_Ps_3);
P_Pb_1=double(P_Pb_1);P_Pb_2=double(P_Pb_2);P_Pb_3=double(P_Pb_3);
u_Ps=double(u_Ps);
u_Pb=double(u_Pb);
%Prosumer֮��ĺ���������
figure
plot([(pai_1*P_trading_1)',(pai_2*P_trading_2)',(pai_3*P_trading_3)'],'-p')
xlabel('ʱ��/h');
ylabel('���׹���/MW');
legend('prosumer1','prosumer2','prosumer3')
title('prosumer����������')
%Prosumer�������̵Ľ��׼۸�
figure
plot(1:24,-u_Ps(1,:)','-r','LineWidth',1.5)
hold on
plot(1:24,-u_Ps(2,:)','-g','LineWidth',1.5)
hold on
plot(1:24,-u_Ps(3,:)','-b','LineWidth',1.5)
hold on
plot(1:24,-u_Psmax','--','LineWidth',1.5)
hold on
plot(1:24,-u_Psmin','--','LineWidth',1.5)
hold on
plot(1:24,u_Pb(1,:)','-r','LineWidth',1.5)
hold on
plot(1:24,u_Pb(2,:)','-g','LineWidth',1.5)
hold on
plot(1:24,u_Pb(3,:)','-b','LineWidth',1.5)
hold on
plot(1:24,u_Pbmax','--','LineWidth',1.5)
hold on
plot(1:24,u_Pbmin','--','LineWidth',1.5)
xlabel('ʱ��/h');
ylabel('���׼۸�/��Ԫ/MW��');
legend('prosumer1','prosumer2','prosumer3')
title('prosumer�������̽��׼۸�')