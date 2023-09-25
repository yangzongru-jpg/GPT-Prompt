function constraints=addC(yita,p_wt,p_pv,p_load,ee_bat_int,p_pv_int,p_wt_int,p_g_int)
%MP
% ee_bat_int=sdpvar(1);
% p_pv_int=sdpvar(1);
% p_wt_int=sdpvar(1);
% p_g_int=sdpvar(1);
%yita=sdpvar(1);
rp=0.08;
rbat=10;rPV=20;rWT=15;rG=15;
cbat=1107;cPV=100;cWT=300;cG=2000;
%增加变量
p_g_min=10;%燃气轮机出力下限
p_m_max=1000;%联络线功率上限
p_bat_int=ee_bat_int*0.21;%假设储能的功率上限和容量上限有比值关系

ee0=0.55*ee_bat_int; %储能初始电量
eta=0.95;%储能充放电效率
mm=100000;%一个极大正实数
k_suo=1/1;%缩减系数
c_bat_int=3320/3*k_suo;%缩减储能单位成本为3320/3,乘上了缩减系数

c_wt_om=0.0296;c_pv_om=0.0096;c_g_om=0.059;c_bat_om=0.009;%运维成本系数
c_fuel=0.6;%燃料成本系数

%决策变量
p_ch=sdpvar(24,4);p_dis=sdpvar(24,4);ee=sdpvar(24,4);
uu_bat=binvar(24,4);uu_m=binvar(24,4);
p_buy=sdpvar(24,4);p_sell=sdpvar(24,4);
%p_wt=sdpvar(24,1);p_pv=sdpvar(24,1);p_load=sdpvar(24,1);
p_g=sdpvar(24,4);
%wwt=sdpvar(24,1);wpv=sdpvar(24,1);wl=sdpvar(24,1);

%风光出力和电价（以春季典型日为例）
p_l=xlsread('四个典型日数据.xlsx','0%','B3:E26')*900;
max_p_wt=xlsread('四个典型日数据.xlsx','0%','H3:K26')*p_wt_int; 
max_p_pv=xlsread('四个典型日数据.xlsx','0%','N3:Q26')*p_pv_int; 
%price=xlsread('四个典型日数据.xlsx','电价','A2:A25');
price=[0.48
0.48
0.48
0.48
0.48
0.48
0.48
0.9
1.35
1.35
1.35
0.9
0.9
0.9
0.9
0.9
0.9
0.9
1.35
1.35
1.35
1.35
1.35
0.48
];
%储能损耗模型的参数和变量
% kk1=0.44268;bb1=0.43071;
% kk2=0.59493;bb2=0.41454;
% kk3=0.65646;bb3=0.40992;
% kk4=0.69405;bb4=0.40761;
% kk5=0.72954;bb5=0.40551;
% 
% ss_bat=binvar(24,1);%改设为0/1变量
% g1=binvar(24,1);g2=binvar(24,1);g3=binvar(24,1);g4=binvar(24,1);g5=binvar(24,1);
% d1=sdpvar(24,1);d2=sdpvar(24,1);d3=sdpvar(24,1);d4=sdpvar(24,1);d5=sdpvar(24,1);
% c_bat=sdpvar(1,1);
constraints=[];
%负荷响应模块
% jz_pri=0.9.*ones(1,24);%基准电价
% detapr=price'-jz_pri;%电价差
% load=DR3(p_l',detapr,price');%负荷调整
load=p_l';
%功率约束
%01变量和变量乘积的线性化
y1=sdpvar(24,4);y2=sdpvar(24,4);%01变量和普通变量乘积的线性化
 for t=1:24
 constraints=[constraints,0<=p_dis(t,:),p_dis(t)<=y1(t,:)];    
 constraints=[constraints,y1(t,:)<=p_bat_int];
 constraints=[constraints,y1(t,:)>=p_bat_int-1000*uu_bat(t,:)];
 constraints=[constraints,y1(t,:)>=20*(1-uu_bat(t,:)),y1(t)<=1000*(1-uu_bat(t,:))];
 constraints=[constraints,0<=p_ch(t,:),p_ch(t,:)<=y2(t,:)];    
 constraints=[constraints,y2(t,:)<=p_bat_int];
 constraints=[constraints,y2(t,:)>=p_bat_int-1000*(1-uu_bat(t,:))];
 constraints=[constraints,y2(t,:)>=20*uu_bat(t,:),y2(t)<=1000*uu_bat(t,:)];
 
 % constraints=[constraints,0<=p_dis(t),p_dis(t)<=(1-uu_bat(t))*p_bat_int];%由于u_bat定义不同，所以公式和原文不同，1为充电，0为放电
%  constraints=[constraints,0<=p_ch(t),p_ch(t)<=uu_bat(t)*p_bat_int];
 %constraints=[constraints,hull(p_dis(t)*test(t)<=0)];
%  for ki=1:k
%  constraints=[constraints,(1-cwwt(t,ki))*max_p_wt(t)<=p_wt(t),p_wt(t)<=(1+cwwt(t,ki))*max_p_wt(t)];
%  %constraints=[constraints,(1-0.05)*max_p_wt(t)*y3(t)+(1+0.05)*max_p_wt(t)*(1-y3(t))==p_wt(t)];%下面进行简化
% % % % % %  constraints=[constraints,1.05*max_p_wt(t)-0.1*py3(t)==p_wt(t)];
% % % % % %  constraints=[constraints,1.05*max_p_wt(t)>=py3(t)];
% % % % % %  constraints=[constraints,py3(t)>=max_p_wt(t)-100*(1-y3(t))];
% % % % % %   constraints=[constraints,py3(t)>=2*y3(t),py3(t)<=100*y3(t)];
% % % % % %   
% % % % % %    constraints=[constraints,1.05*max_p_pv(t)-0.1*py4(t)==p_pv(t)];
% % % % % %  constraints=[constraints,1.05*max_p_pv(t)>=py4(t)];
% % % % % %  constraints=[constraints,py4(t)>=max_p_pv(t)-100*(1-y4(t))];
% % % % % %   constraints=[constraints,py4(t)>=2*y4(t),py4(t)<=100*y4(t)];
% constraints=[constraints,(1-cwpv(t,ki))*max_p_pv(t)<=p_pv(t),p_pv(t)<=(1+cwpv(t,ki))*max_p_pv(t)];
% constraints=[constraints,(1-cwl(t,ki))*load(t)<=p_load(t),p_load(t)<=(1+cwl(t,ki))*load(t)];
 %end
 end
%soc约束
% for t=1:24
% constraints=[constraints,ee(t,:)==ee0+sum(eta*p_ch(1:t,:)-1/eta*p_dis(1:t,:))];
% constraints=[constraints,0.1*ee_bat_int<=ee(t,:),ee(t,:)<=0.9*ee_bat_int];
% end
% %功率平衡约束
%  for t=1:24
% constraints=[constraints, p_pv(t,:)+p_wt(t,:)+p_dis(t,:)-p_ch(t,:)+p_buy(t,:)-p_sell(t,:)+p_g(t,:)==p_load(t,:)];
%  end
%   %购售电约束
% for t=1:24
% constraints=[constraints, 0<=p_buy(t,:),p_buy(t,:)<=uu_m(t,:)*p_m_max];
% constraints=[constraints,0<=p_sell(t,:),p_sell(t,:)<=(1-uu_m(t,:))*p_m_max];%购电1，售电0
% end
%  %充放电量平衡约束
% constraints=[constraints, ee0==ee(24,:)];
% %微型燃气轮机出力约束
% for t=1:24
% constraints=[constraints,p_g_min<=p_g(t,:),p_g(t,:)<=p_g_int];
% end
lam1=sdpvar(96,1);lam11=sdpvar(96,1);lam2=sdpvar(192,1);lam21=sdpvar(192,1);lam3=sdpvar(4,1);lam4=sdpvar(192,1);lam41=sdpvar(192,1);lam5=sdpvar(96,1);
lam51=sdpvar(96,1);lam6=sdpvar(96,1);
beta1=binvar(96,1);beta11=binvar(96,1);beta2=binvar(192,1);beta21=binvar(192,1);beta3=binvar(4,1);beta4=binvar(192,1);beta41=binvar(192,1);beta5=binvar(96,1);
beta51=binvar(96,1);beta6=binvar(96,1);beta7=binvar(480,1);beta8=binvar(288,1);
x=[p_buy(:,1)' p_sell(:,1)' p_g(:,1)' p_ch(:,1)' p_dis(:,1)' p_buy(:,2)' p_sell(:,2)' p_g(:,2)' p_ch(:,2)' p_dis(:,2)' p_buy(:,3)' p_sell(:,3)' p_g(:,3)' p_ch(:,3)' p_dis(:,3)' p_buy(:,4)' p_sell(:,4)' p_g(:,4)' p_ch(:,4)' p_dis(:,4)']';
u=[p_wt(:,1)' p_pv(:,1)' p_load(:,1)' p_wt(:,2)' p_pv(:,2)' p_load(:,2)' p_wt(:,3)' p_pv(:,3)' p_load(:,3)' p_wt(:,4)' p_pv(:,4)' p_load(:,4)']';

P=[price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48) price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48) price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48) price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)]';
B=repmat([c_wt_om.*ones(1,24) c_pv_om.*ones(1,24) zeros(1,24)]',1,4);
Q1=[zeros(24,48) eye(24) zeros(24,48) zeros(24,360);zeros(24,120) zeros(24,48) eye(24) zeros(24,48) zeros(24,240);zeros(24,240) zeros(24,48) eye(24) zeros(24,48) zeros(24,120);zeros(24,360) zeros(24,48) eye(24) zeros(24,48);];
Q2=[zeros(48,72) eye(48) zeros(48,360);zeros(48,120) zeros(48,72) eye(48) zeros(48,240);zeros(48,240) zeros(48,72) eye(48) zeros(48,120);zeros(48,360) zeros(48,72) eye(48)];
Q3=[zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,360);zeros(1,120) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,240);zeros(1,240) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,120);zeros(1,360) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24)];
Q4=[eye(48) zeros(48,72) zeros(48,360);zeros(48,120) eye(48) zeros(48,72) zeros(48,240);zeros(48,240) eye(48) zeros(48,72) zeros(48,120);zeros(48,360) eye(48) zeros(48,72)];
Q5=[zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,360);zeros(24,120) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,240);zeros(24,240) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,120);zeros(24,360) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0)];
Q6=[eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,360);zeros(24,120) eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,240);zeros(24,240) eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,120);zeros(24,360) eye(24) -eye(24) eye(24) -eye(24) eye(24)];
G=[eye(24) eye(24) -eye(24) zeros(24,216);zeros(24,72) eye(24) eye(24) -eye(24) zeros(24,144);zeros(24,144) eye(24) eye(24) -eye(24) zeros(24,72);zeros(24,216) eye(24) eye(24) -eye(24)];
T2=[uu_bat(:,1);(1-uu_bat(:,1));uu_bat(:,2);(1-uu_bat(:,2));uu_bat(:,3);(1-uu_bat(:,3));uu_bat(:,4);(1-uu_bat(:,4))].*p_bat_int;
T4=[uu_m(:,1);1-uu_m(:,1);uu_m(:,2);1-uu_m(:,2);uu_m(:,3);1-uu_m(:,3);uu_m(:,4);1-uu_m(:,4)].*p_m_max;
T5=repmat(0.9*ee_bat_int-ee0,96,1);
T51=repmat(0.1*ee_bat_int-ee0,96,1);
%增加原始约束
constraints=[constraints,Q1*x<=p_g_int];
constraints=[constraints,Q1*x>=0];
% constraints=[constraints,Q2*x<=T2];
% constraints=[constraints,Q2*x>=0];
constraints=[constraints,Q3*x==0];
constraints=[constraints,Q4*x<=T4];
constraints=[constraints,Q4*x>=0];
constraints=[constraints,Q5*x<=T5];
constraints=[constraints,Q5*x>=T51];
constraints=[constraints,Q6*x+G*u==0];

constraints=[constraints,yita>=sum(sum(repmat(price,1,4).*(p_buy(:,:)-p_sell(:,:)))+c_fuel*sum(p_g(:,1))+...%购售电成本和燃料成本
     sum(c_wt_om*p_wt(:,:))+sum(c_pv_om*p_pv(:,:))+sum(c_g_om*p_g(:,:))+sum(c_bat_om*p_dis(:,:))+sum(c_bat_om*p_ch(:,:)));%+...%运维成本
];