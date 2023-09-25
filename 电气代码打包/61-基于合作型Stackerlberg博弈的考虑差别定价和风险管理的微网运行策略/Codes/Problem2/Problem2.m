%% [SCI文章复现]A cooperative Stackelberg game based energy management considering price discrimination and risk assessment
%[中译]基于合作型Stackerlberg博弈的考虑差别定价和风险管理的微网运行策略
%International Journal of Electrical Power and Energy Systems,SCI二区
%Highlights:合作型Stackerlberg博弈,纳什谈判,差别定价
%P2(谈判环节)求解程序

clc
clear
close all

%% 决策变量初始化
C_epay_1=sdpvar(1,10); %产消者1的各个场景的转移支付
C_epay_2=sdpvar(1,10); %产消者2的各个场景的转移支付
C_epay_3=sdpvar(1,10); %产消者3的各个场景的转移支付
%% 导入常数变量
load P_trading.mat       %导入P_trading_1  P_trading_2  P_trading_3
load C_Non.mat           %导入C_Non_1  C_Non_2  C_Non_3
load C_trade.mat         %导入C_trade_1  C_trade_2  C_trade_3
%产消者1-3风电场景概率
pai_1=0.1*ones(1,10);pai_2=0.1*ones(1,10);pai_3=0.1*ones(1,10);
%消除负号，全部转换为成本，负数代表获得收益
C_Non_1=-C_Non_1;C_Non_2=-C_Non_2;C_Non_3=-C_Non_3;
C_trade_1=-C_trade_1;C_trade_2=-C_trade_2;C_trade_3=-C_trade_3;
%根据公式23计算贡献度
alpha_1=sum(abs(P_trading_1),2)./(sum(abs(P_trading_1),2)+sum(abs(P_trading_2),2)+sum(abs(P_trading_3),2));%如果按照公式23，分母之和必为0，有必要对交易量取绝对值
alpha_2=sum(abs(P_trading_2),2)./(sum(abs(P_trading_1),2)+sum(abs(P_trading_2),2)+sum(abs(P_trading_3),2));
alpha_3=sum(abs(P_trading_3),2)./(sum(abs(P_trading_1),2)+sum(abs(P_trading_2),2)+sum(abs(P_trading_3),2));
alpha_1=alpha_1';alpha_2=alpha_2';alpha_3=alpha_3';
%% 优化结果保存初矩阵始化
C_epay1_save=zeros(1,10);C_epay2_save=zeros(1,10);C_epay3_save=zeros(1,10);
%% 循环求解每个场景
for w=1:10
    C=[];
    %公式20自动满足
    C=[C,
       C_trade_1(w)+C_epay_1(w)<=C_Non_1(w), %公式21
       C_trade_2(w)+C_epay_2(w)<=C_Non_2(w),
       C_trade_3(w)+C_epay_3(w)<=C_Non_3(w),
       C_epay_1(w)+C_epay_2(w)+C_epay_3(w)==0, %公式22
      ];
   %目标函数
   TC_benefits=-alpha_1(w)*log(C_Non_1(w)-C_trade_1(w)-C_epay_1(w))-...
                 alpha_2(w)*log(C_Non_2(w)-C_trade_2(w)-C_epay_2(w))-...
                 alpha_3(w)*log(C_Non_3(w)-C_trade_3(w)-C_epay_3(w));    
   %求解器相关配置
   ops=sdpsettings('solver','mosek','verbose',2,'usex0',0);
   %进行求解计算 
   result=optimize(C,TC_benefits,ops);
   if result.problem == 0 
   else
     error('求解出错');
   end
   %求解结果保存
   C_epay1_save(w)=double(C_epay_1(w));
   C_epay2_save(w)=double(C_epay_2(w));
   C_epay3_save(w)=double(C_epay_3(w));   
end  
%% 输出运行结果
%最终转移支付结果
C_epay1_real=pai_1*C_epay1_save';
C_epay2_real=pai_2*C_epay2_save';
C_epay3_real=pai_3*C_epay3_save';
display(['Prosumer1的支付成本: ', num2str(C_epay1_real)]);
display(['Prosumer2的支付成本: ', num2str(C_epay2_real)]);
display(['Prosumer3的支付成本: ', num2str(C_epay3_real)]);