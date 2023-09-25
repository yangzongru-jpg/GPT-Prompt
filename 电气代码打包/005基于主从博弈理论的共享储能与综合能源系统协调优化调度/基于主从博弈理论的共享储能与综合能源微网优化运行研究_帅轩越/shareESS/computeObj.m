%用户侧收益作为目标函数
function [P_MT,F_user,F_share,Eload,Hload,ES,P_h,Prl,P_buy,P_sell] = computeObj(x,load_e,load_h,P_PV,pe_grid_B)
P_MT=sdpvar(1,24,'full');%微燃轮机输出电功率
P_buy=sdpvar(1,24,'full');%用户向运营商买电电量
P_sell=sdpvar(1,24,'full');%用户向电网卖电电量
ES=sdpvar(1,24,'full');%储能余量
%% 需求侧定义变量
%电负荷：固定、可平移、可消减负荷、电替热
%热负荷：固定、可消减、热被电替
Pfl=sdpvar(1,24,'full');%可平移电负荷量
eload=0.8*(load_e); %消减之后的电负荷量
Pcl_h=sdpvar(1,24,'full');%可消减热负荷量
Prl=sdpvar(1,24,'full');%电制热设备供热量
P_h=sdpvar(1,24,'full');%微网运营商供热量
char=sdpvar(1,24,'full'); %充电功率
char_sign=binvar(1,24,'full');%充电标志 
dischar=sdpvar(1,24,'full'); %放电功率
dischar_sign=binvar(1,24,'full');%放电标志
%a 、b 、c为用户聚合商的用电效用函数的参数
a=-0.05;b=4;
%微燃电机系数
MT_e=0.4; %发电效率
MT_h=0.8;   %制热效率
MT_hh=0.05;%散热损失率

%约束条件
C =[];
%% 共享储能服务商
ESS_max=1350;ESS_char=0.95;ESS_dischar=0.95;%电储能容量/充电/放电
SOC0=0.5;
ES(1,1)=SOC0*ESS_max;%%初始电量
 for t=2:25  %在一个周期内的充放电功率为零
     C=[C,(ES(mod(t-1,24)+1)==(ES(mod(t-2,24)+1)+(ESS_char*char(mod(t-2,24)+1)-(1/ESS_dischar)*dischar(mod(t-2,24)+1))))];
     C=[C,ES(1,1)==SOC0*ESS_max];
 end
for i=1:24
     C=[C,300<=ES(1,i)<=1350]; %储能容量约束
     C=[C,0<=char(1,i)<=50*char_sign(1,i)]; %充放电约束
     C=[C,0<=dischar(1,i)<=50*dischar_sign(1,i)];  
end
%蓄电池充放电约束
 for i=1:24
     C=[C,char_sign(1,i)+dischar_sign(1,i)<=1];    
 end
  C=[C,10<=sum(char_sign(1,1:24)+dischar_sign(1,1:24))<=20];%考虑寿命
%% 综合能源运营商、储能运营商、用户。三者的能量流
for i=1:24
    C = [C,0<=P_MT(i)<=500];%微燃轮机上下限约束
    C = [C,0<=Pfl(i)<=80];%可平移电负荷限制 
    C = [C,0<=Pcl_h(i)<=25];%热负荷消减限制 
    C = [C,5<=Prl(i)<=60];%电制热设备输出量限制 
    C = [C,0<=P_h(i)];%向微网买热限制 
    C = [C,0<=P_sell(i)<=100];%用户向电网卖电
    C = [C,0<=P_buy(i)<=250];%用户向运营商买电
end
% for i=1:24
%     C = [C, 0<=Pbuy(i)<=Temp_net(1,i)*300]; %运营商购电约束约束
%     C = [C, 0<=Psell(i)<=(1-Temp_net(1,i))*300]; %运营商售电约束约束
%     C = [C, 0<=Pbuy(i)<=Temp_net(1,i)*300]; %运营商购电约束约束
% end

C = [C,sum(Pfl(1:i))==0.2*sum(load_e(1:i))];%可平移负荷总量不变约束
C = [C,sum(Pcl_h(1:i))==0.15*sum(load_h(1:i))];%可消减负荷约束
 
  
for i=1:24       
C = [C,P_MT(i)+P_buy(i)-P_sell(i)==-char(1,i)+dischar(1,i)+eload(i)+Pfl(i)+Prl(i)/0.9-P_PV(i)]; %电平衡约束
C = [C,P_MT(i)/MT_e*(1-MT_e-MT_hh)*MT_h==P_h(i)];%微燃机热约束
C = [C,P_h(i)+Prl(i)==load_h(i)-Pcl_h(i)];%热平衡约束(与文章不同，因为不想和文章一样)
end

%共享储能服务商利润
F_share=0;
%% 用户侧目标函数
F_e=0;F_g=0;

for i=1:24
   F_e=F_e-x(i).*(P_MT(i)+P_buy(i))+P_sell(i)*pe_grid_B(i)-0.1*(char(1,i)+dischar(1,i))-0.1*(Pcl_h(i))^2+a*(0.8*load_e(i)+Pfl(i)+Prl(i)/0.9)^2/4+b*(0.8*load_e(i)+Pfl(i)+Prl(i)/0.9);
   %; %各成本
   F_share=F_share+(0.1-0.05)*(char(1,i)+dischar(1,i))+700;%服务商利润,700为共享费
   F_g=F_g-x(i+24).*P_h(i);%购热成本
end

F=F_e+F_g;
ops = sdpsettings('solver','cplex', 'verbose', 2);%参数指定程序用cplex求解器
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

    



