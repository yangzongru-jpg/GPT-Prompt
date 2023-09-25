%% [SCI���¸���]A cooperative Stackelberg game based energy management considering price discrimination and risk assessment
%[����]���ں�����Stackerlberg���ĵĿ��ǲ�𶨼ۺͷ��չ����΢�����в���
%International Journal of Electrical Power and Energy Systems,SCI����
%Highlights:������Stackerlberg����,��ʲ̸��,��𶨼�
%P2(̸�л���)������

clc
clear
close all

%% ���߱�����ʼ��
C_epay_1=sdpvar(1,10); %������1�ĸ���������ת��֧��
C_epay_2=sdpvar(1,10); %������2�ĸ���������ת��֧��
C_epay_3=sdpvar(1,10); %������3�ĸ���������ת��֧��
%% ���볣������
load P_trading.mat       %����P_trading_1  P_trading_2  P_trading_3
load C_Non.mat           %����C_Non_1  C_Non_2  C_Non_3
load C_trade.mat         %����C_trade_1  C_trade_2  C_trade_3
%������1-3��糡������
pai_1=0.1*ones(1,10);pai_2=0.1*ones(1,10);pai_3=0.1*ones(1,10);
%�������ţ�ȫ��ת��Ϊ�ɱ�����������������
C_Non_1=-C_Non_1;C_Non_2=-C_Non_2;C_Non_3=-C_Non_3;
C_trade_1=-C_trade_1;C_trade_2=-C_trade_2;C_trade_3=-C_trade_3;
%���ݹ�ʽ23���㹱�׶�
alpha_1=sum(abs(P_trading_1),2)./(sum(abs(P_trading_1),2)+sum(abs(P_trading_2),2)+sum(abs(P_trading_3),2));%������չ�ʽ23����ĸ֮�ͱ�Ϊ0���б�Ҫ�Խ�����ȡ����ֵ
alpha_2=sum(abs(P_trading_2),2)./(sum(abs(P_trading_1),2)+sum(abs(P_trading_2),2)+sum(abs(P_trading_3),2));
alpha_3=sum(abs(P_trading_3),2)./(sum(abs(P_trading_1),2)+sum(abs(P_trading_2),2)+sum(abs(P_trading_3),2));
alpha_1=alpha_1';alpha_2=alpha_2';alpha_3=alpha_3';
%% �Ż�������������ʼ��
C_epay1_save=zeros(1,10);C_epay2_save=zeros(1,10);C_epay3_save=zeros(1,10);
%% ѭ�����ÿ������
for w=1:10
    C=[];
    %��ʽ20�Զ�����
    C=[C,
       C_trade_1(w)+C_epay_1(w)<=C_Non_1(w), %��ʽ21
       C_trade_2(w)+C_epay_2(w)<=C_Non_2(w),
       C_trade_3(w)+C_epay_3(w)<=C_Non_3(w),
       C_epay_1(w)+C_epay_2(w)+C_epay_3(w)==0, %��ʽ22
      ];
   %Ŀ�꺯��
   TC_benefits=-alpha_1(w)*log(C_Non_1(w)-C_trade_1(w)-C_epay_1(w))-...
                 alpha_2(w)*log(C_Non_2(w)-C_trade_2(w)-C_epay_2(w))-...
                 alpha_3(w)*log(C_Non_3(w)-C_trade_3(w)-C_epay_3(w));    
   %������������
   ops=sdpsettings('solver','mosek','verbose',2,'usex0',0);
   %���������� 
   result=optimize(C,TC_benefits,ops);
   if result.problem == 0 
   else
     error('������');
   end
   %���������
   C_epay1_save(w)=double(C_epay_1(w));
   C_epay2_save(w)=double(C_epay_2(w));
   C_epay3_save(w)=double(C_epay_3(w));   
end  
%% ������н��
%����ת��֧�����
C_epay1_real=pai_1*C_epay1_save';
C_epay2_real=pai_2*C_epay2_save';
C_epay3_real=pai_3*C_epay3_save';
display(['Prosumer1��֧���ɱ�: ', num2str(C_epay1_real)]);
display(['Prosumer2��֧���ɱ�: ', num2str(C_epay2_real)]);
display(['Prosumer3��֧���ɱ�: ', num2str(C_epay3_real)]);