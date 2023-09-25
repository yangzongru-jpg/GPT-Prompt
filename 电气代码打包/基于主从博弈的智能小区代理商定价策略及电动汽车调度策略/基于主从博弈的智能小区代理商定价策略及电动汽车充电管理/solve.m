%三层博弈，电网-充电站-用户
%电网-充电站，合作博弈，Pareto均衡
%充电站-用户，主从博弈，KKT条件
clear
clc
%%%%主从博弈%%%
PL=[1733.66666666000;1857.50000000000;2105.16666657000;2352.83333343000;2476.66666657000;2724.33333343000;2848.16666657000;2972;3219.66666657000;3467.33333343000;3591.16666657000;3715.00000000000;3467.33333343000;3219.66666657000;2972;2600.50000000000;2476.66666657000;2724.33333343000;2972;3467.33333343000;3219.66666657000;2724.33333343000;2229;1981.33333343000];
a=0.55*PL/mean(PL);
b=0.55/mean(PL)*ones(24,1);
%b=zeros(24,1);
lb=0.2;
ub=1;
T_1=[1;1;1;1;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1];%%%早出晚归型
T_2=[1;1;1;1;1;1;1;1;0;0;0;0;1;1;1;0;0;0;0;1;1;1;1;1];%%%上班族
T_3=[0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0];%%%夜班型
Ce=sdpvar(24,1);%电价
Pb=sdpvar(24,1);%购电
Pc1=sdpvar(24,1);%一类车充电功率
Pc2=sdpvar(24,1);%二类车充电功率
Pc3=sdpvar(24,1);%三类车充电功率
C=[lb<=Ce<=ub,mean(Ce)==0.7,Pb>=0];%边界约束
C=[C,Pc1+Pc2+Pc3==Pb];%能量平衡
L_u=sdpvar(1,3);%电量需求等式约束的拉格朗日函数
L_lb=sdpvar(24,3);%充电功率下限约束的拉格朗日函数
L_ub=sdpvar(24,3);%充电功率上限约束的拉格朗日函数
L_T=sdpvar(24,3);%充电可用时间约束的拉格朗日函数
f=200*L_u(1)*(0.9*42-9.6)+150*L_u(2)*(0.9*42-9.6)+50*L_u(3)*(0.9*42-9.6)+sum(sum(L_ub).*[32*30,32*30,16*30])-sum(a.*Pb+b.*Pb.^2);%目标函数
C=[C,Ce-L_u(1)*ones(24,1)-L_lb(:,1)-L_ub(:,1)-L_T(:,1)==0,Ce-L_u(2)*ones(24,1)-L_lb(:,2)-L_ub(:,2)-L_T(:,2)==0,Ce-L_u(3)*ones(24,1)-L_lb(:,3)-L_ub(:,3)-L_T(:,3)==0];%KKT条件
C=[C,sum(Pc1)==200*(0.9*42-9.6),sum(Pc2)==150*(0.9*42-9.6),sum(Pc3)==50*(0.9*42-9.6)];%电量需求约束
for t=1:24
    if T_1(t)==0
        C=[C,Pc1(t)==0];
    else
        C=[C,L_T(t,1)==0];
    end
    if T_2(t)==0
        C=[C,Pc2(t)==0];
    else
        C=[C,L_T(t,2)==0];
    end
    if T_3(t)==0
        C=[C,Pc3(t)==0];
    else
        C=[C,L_T(t,3)==0];
    end
end
b_lb=binvar(24,3);%充电功率下限约束的松弛变量
b_ub=binvar(24,3);%充电功率上限约束的松弛变量
M=1000000;
for t=1:24
    if T_1(t)==0
        C=[C,L_ub(t,1)==0,b_ub(t,1)==1,b_lb(t,1)==1];
    else
        C=[C,L_lb(t,1)>=0,L_lb(t,1)<=M*b_lb(t,1),Pc1(t)>=0,Pc1(t)<=M*(1-b_lb(t,1)),Pc1(t)<=32*30,32*30-Pc1(t)<=M*b_ub(t,1),L_ub(t,1)<=0,L_ub(t,1)>=M*(b_ub(t,1)-1)];
    end
    if T_2(t)==0
        C=[C,L_ub(t,2)==0,b_ub(t,2)==1,b_lb(t,2)==1];
    else
        C=[C,L_lb(t,2)>=0,L_lb(t,2)<=M*b_lb(t,2),Pc2(t)>=0,Pc2(t)<=M*(1-b_lb(t,2)),Pc2(t)<=32*30,32*30-Pc2(t)<=M*b_ub(t,2),L_ub(t,2)<=0,L_ub(t,2)>=M*(b_ub(t,2)-1)];
    end
    if T_3(t)==0
        C=[C,L_ub(t,3)==0,b_ub(t,3)==1,b_lb(t,3)==1];
    else
        C=[C,L_lb(t,3)>=0,L_lb(t,3)<=M*b_lb(t,3),Pc3(t)>=0,Pc3(t)<=M*(1-b_lb(t,3)),Pc3(t)<=16*30,16*30-Pc3(t)<=M*b_ub(t,3),L_ub(t,3)<=0,L_ub(t,3)>=M*(b_ub(t,3)-1)];
    end
end
f2=1/24*sum((PL+Pb-mean(PL+Pb)).^2);
%C=[C,f2<=274^2];
ops=sdpsettings('solver','cplex');
solvesdp(C,-f,ops);
Pc=[double(Pc1),double(Pc2),double(Pc3)];
Pb=double(Pb);
Cost_total=double(f)
Price_Charge=double(Ce);

Ce=value(Ce);%电价
Pb=value(Pb);%日前购电
% Pb_day=value(Pb_day);%实时购电
% Ps_day=value(Ps_day);%实时购电
% Pdis=value(Pdis);%储能放电
% Pch=value( Pch);%储能充电
% Pb_day=value(Pb_day);%实时购电
% Pb_day=value(Pb_day);%实时购电
Pc1=value(Pc1);%一类车充电功率
Pc2=value(Pc2);%二类车充电功率
Pc3=value(Pc3);%三类车充电功率
% S=value(S);%储荷容量

figure(1)
bar(Pc1,0.4,'linewidth',0.01)
grid
hold on
bar(Pc2,0.4,'linewidth',0.01)
hold on
bar(Pc3,0.4,'linewidth',0.01)
title('三类电动汽车充电功率')
legend('EV类型1','EV类型2','EV类型3')
xlabel('时间')
ylabel('功率')

% figure(2)
% bar(Pdis,0.5,'linewidth',0.01)
% grid
% hold on
% bar(Pch,0.5,'linewidth',0.01)
% hold on
% plot(S,'-*','linewidth',1.5)
% axis([0.5 24.5 0 5000]);
% title('储能充电功率')
% legend('充电功率','放电功率','蓄电量')
% xlabel('时间')
% ylabel('功率')

figure(3)
yyaxis left;
bar(Pb,0.5,'linewidth',0.01)
% hold on
% bar(Ps_day,0.5,'linewidth',0.01)
axis([0.5 24.5 0 1200])
xlabel('时间')
ylabel('功率')
yyaxis right;
plot(Ce,'-*','linewidth',1.5)
% legend('电价结果')
xlabel('时间')
ylabel('电价')
legend('日前购电','电价优化');

% figure(4)
% plot(Ce,'-*','linewidth',1.5)
% grid
% hold on
% plot(price_b,'-*','linewidth',1.5)
% hold on
% plot(price_s,'-*','linewidth',1.5)
% title('电价优化结果')
% legend('优化电价','购电电价','售电电价')
% xlabel('时间')
% ylabel('电价')

% clear ans b_lb b_ub C Ce f L_lb L_ub L_T L_u lb M ops Pc1 Pc2 Pc3 price_b price_day_ahead price_s t T_1 T_2 T_3 u ub z
% plot(PL)
% hold on
% plot(PL+Pb,'r')