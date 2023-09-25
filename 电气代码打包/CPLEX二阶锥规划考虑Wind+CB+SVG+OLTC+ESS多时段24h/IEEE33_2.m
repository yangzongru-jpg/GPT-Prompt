%多时段+SVC+CB+OLTC+DG SOCP_OPF   Sbase=1MVA,   Ubase=12.66KV
%目标函数如果只有网损，那么OLTC永远是高挡位，电压越高，网损越小，因此需进一步考虑目标函数如主网购电，或者电压平衡          

%%
%有载调压变压器的位置在那个节点

%%
clear 
clc 
tic 
warning off
%% 1.设参
mpc = IEEE33BW;
wind = mpc.wind;    
pload = mpc.pload;    
pload_prim = mpc.pload_prim/1000;  %化为标幺值
qload_prim = mpc.qload_prim/1000;
a = 3.715;   %单时段所有节点有功容量,MW
b = 2.3;     %单时段所有节点无功容量,MW
pload = pload/a;%得到各个时段与单时段容量的比例系数
qload = pload/b;%假设有功负荷曲线与无功负荷变化曲线相同
pload = pload_prim*pload;   %得到33*24的负荷值，每一个时间段每个节点的负荷
qload = qload_prim*qload;      

branch = mpc.branch;       
branch(:,3) = branch(:,3)*1/(12.66^2);%求阻抗标幺值      
R = real(branch(:,3));            
X = imag(branch(:,3));             
T = 24;%时段数为24小时             
nb = 33;%节点数            
nl = 32;%支路数           
nsvc = 3;%SVC数      静止无功补偿器 Static Var compensator
ncb = 2;%CB数        分组投切电容器组 (capacitorbanks，CB)
noltc = 1;%OLTC数    有载调压变压器 ( on—load tap changer，OLTC ）  transformer   
nwt = 2;%2个风机     
ness = 2;%ESS数      
upstream = zeros(nb,nl);
dnstream = zeros(nb,nl);
for i = 1:nl
    upstream(i,i)=1;
end
for i = [1:16,18:20,22:23,25:31]
    dnstream(i,i+1)=1;
end
dnstream(1,18) = 1;
dnstream(2,22) = 1;
dnstream(5,25) = 1;
dnstream(33,1) = 1;
Vmax = [1.06*1.06*ones(nb-1,T)
        1.06*1.06*ones(1,T)];
Vmin = [0.94*0.94*ones(nb-1,T)
        0.94*0.94*ones(1,T)];%加入变压器后，根节点前移，因此不是恒定值1.06
Pgmax = [zeros(nb-1,T)
         5*ones(1,T)];
Pgmin = [zeros(nb-1,T)
         0*ones(1,T)];
Qgmax = [zeros(nb-1,T)
         3*ones(1,T)];
Qgmin = [zeros(nb-1,T)
         -1*ones(1,T)];
QCB_step = 100/1000;       %单组CB无功,100Kvar 转标幺值     
%% 2.设变量
V = sdpvar(nb,T);%电压的平方
I = sdpvar(nl,T);%支路电流的平方
P = sdpvar(nl,T);%线路有功（是不是平方我就不清楚了，应该不是）
Q = sdpvar(nl,T);%线路无功
Pg = sdpvar(nb,T);%发电机有功
Qg = sdpvar(nb,T);%发电机无功
theta_CB = binvar(ncb,T,5); %CB档位选择，最大档为5
theta_IN = binvar(ncb,T);%CB档位增大标识位
theta_DE = binvar(ncb,T);%CB档位减小标识位   

q_SVC = sdpvar(nsvc,T);%SVC无功    
p_wt = sdpvar(nwt,T);%风机有功     


p_dch = sdpvar(ness,T);   %ESS放电功率
p_ch = sdpvar(ness,T);   %ESS充电功率
u_dch = binvar(ness,T);%ESS放电状态
u_ch = binvar(ness,T);%ESS充电状态
E_ess = sdpvar(ness,25);%ESS的电量，这个25的原因要搞懂才能理解储能一天开始结束时刻（首末）功率相等的意思   

r1 = sdpvar(noltc,T);     
theta_OLTC = binvar(noltc,T,12);%OLTC档位选择，最大档为12
theta1_IN = binvar(noltc,T);%OLTC档位增大标识位
theta1_DE = binvar(noltc,T);%OLTC档位减小标识位
%% 3.设约束
C = [];        
%% 储能装置（ESS）约束       
%充放电状态约束        
C = [C, u_dch + u_ch <= 1];%表示充电，放电，不充不放三种状态
%功率约束
C = [C, 0 <= p_dch(1,:) <= u_dch(1,:)*0.3];
C = [C, 0 <= p_dch(2,:) <= u_dch(2,:)*0.2];
C = [C, 0 <= p_ch(1,:) <= u_ch(1,:)*0.3];
C = [C, 0 <= p_ch(2,:) <= u_ch(2,:)*0.2];
%容量约束
for t = 1:24  
        C = [C, E_ess(:,t+1) == E_ess(:,t) + 0.9*p_ch(:,t) - 1.11*p_dch(:,t)];   %效率
end

C = [C, E_ess(:,1) == E_ess(:,25)];
C = [C, 0.18 <= E_ess(1,:) <= 1.8];
C = [C, 0.10 <= E_ess(2,:) <= 1.0];        
%投入节点选择（两电池充放电状态）
P_dch = [zeros(14,T);p_dch(1,:);zeros(16,T);p_dch(2,:);zeros(1,T)];   %电池放在第15节点和第32节点
P_ch = [zeros(14,T);p_ch(1,:);zeros(16,T);p_ch(2,:);zeros(1,T)];      

%% 风机（光伏)约束             
C = [C, 0 <= p_wt,   p_wt <= ones(2,1)*wind];        
P_wt = [zeros(16,24);p_wt(1,:);zeros(14,24);p_wt(2,:);zeros(1,24)];     %风机放在17和32节点

%% 有载调压变压器（OLTC）约束        
rjs = zeros(1,12);%相邻2个抽头的变比  平方之差     
for i = 1:12
    rjs(1,i) = (0.93+(i+1)*0.01)^2 -(i*0.01+0.93)^2;
end

for t = 1:24
    C = [C, r1(1,t) == 0.94^2+ sum(rjs.*theta_OLTC(1,t,:))];  %%各个档位变比dita^2 * 开关档位状态
end

for i = 1:11
    C = [C, theta_OLTC(:,:,i) >= theta_OLTC(:,:,i+1)];   %0下面不能有1
end
% theta_OLTC = value(theta_OLTC);

C = [C, V(33,:) == r1];        %%最大值是1.06^2,放在  主网到33节点   
C = [C, theta1_IN + theta1_DE <= 1];        
k = sum(theta_OLTC,3);     %有载调压变压器投切状态个数求和 （1*24）   

for t = 1:T-1
    C = [C, k(:,t+1) - k(:,t) <= theta1_IN(:,t)*12 - theta1_DE(:,t) ];  %升压不能超过12档，减压不能小于1档
    C = [C, k(:,t+1) - k(:,t) >= theta1_IN(:,t) - theta1_DE(:,t)*12 ];
end
C = [C, sum(theta1_IN + theta1_DE,2) <= 5 ];  %限制有载调压变压器日调节次数为5次
%% 连续无功补偿装置（SVC）约束      
C = [C, -0.1 <= q_SVC <= 0.3];
Q_SVC = [zeros(4,T);q_SVC(1,:);zeros(9,T);q_SVC(2,:);zeros(15,T);q_SVC(3,:);zeros(2,T)];%SVC投入节点选择5、15、31
%% 离散无功补偿装置（CB）约束     
Q_cb = sum(theta_CB,3).*QCB_step;     
Q_CB = [zeros(4,T);Q_cb(1,:);zeros(9,T);Q_cb(2,:);zeros(18,T)];%投入节点选择5、15
for i = 1:4
    C = [C, theta_CB(:,:,i) >= theta_CB(:,:,i+1)];
end

% 0
% 0
% 1
% 1
% 1

C = [C, theta_IN + theta_DE <= 1];    
kk = sum(theta_CB,3);    
for t = 1:T-1
    C = [C, kk(:,t+1) - kk(:,t) <= theta_IN(:,t)*5 - theta_DE(:,t) ];
    C = [C, kk(:,t+1) - kk(:,t) >= theta_IN(:,t) - theta_DE(:,t)*5 ];
end
C = [C, sum(theta_IN + theta_DE,2) <= 5];   %对CB的日调节次数限制为5

%% 潮流约束
%节点功率约束
Pin = -upstream*P + upstream*(I.*(R*ones(1,T))) + dnstream*P;%节点注入有功
Qin = -upstream*Q + upstream*(I.*(X*ones(1,T))) + dnstream*Q;%节点注入无功
C = [C, Pin + pload - Pg - P_wt - P_dch + P_ch == 0];
C = [C, Qin + qload - Qg - Q_SVC - Q_CB == 0];
%欧姆定律约束（支路首尾电压约束）
C = [C, V(branch(:,2),:) == V(branch(:,1),:) - 2*(R*ones(1,24)).*P - 2*(X*ones(1,24)).*Q + ((R.^2 + X.^2)*ones(1,24)).*I];
%二阶锥约束（支路功率约束）（考虑了损耗和分流）
C = [C, V(branch(:,1),:).*I >= P.^2 + Q.^2];
%% 通用约束
%节点电压约束
C = [C, Vmin <= V,V <= Vmax];
%发电机功率约束
C = [C, Pgmin <= Pg,Pg <= Pgmax,Qgmin <= Qg,Qg <= Qgmax];
%支路电流约束
C = [C, 0 <= I,I <= 10];   %随手一设（越大代表导线粗，价格贵）
%% 4.设目标函数
objective = sum(Pg(33,:))  +  0.3*sum(sum(I.*(R*ones(1,T))));   %子配电网向主网购电量 + 0.3*子配电网有功损耗
toc%建模时间
%% 5.设求解器
ops = sdpsettings('verbose', 1, 'solver', 'cplex');
ops.cplex= cplexoptimset('cplex');%这两句修改收敛间隙，使MIP问题跑的更快，酌情使用
ops.cplex.mip.tolerances.absmipgap = 0.01;

sol = optimize(C,objective,ops);

objective = value(objective)

toc%求解时间
% clear branch C dnstream upstream i kk mpc nb nl ncb ness noltc npv nwt nsvc...
%       QCB_step ops Pgmax Pgmin pload qload t T theta_DE theta_IN ...
%       Vmax Vmin R X P_ch P_dch P_pv P_wt Q_SVC Qgmax Qgmin Pin Qin...
%       Q_CB k r rjs theta1_DE theta1_IN 

%% 6.分析错误标志
if sol.problem == 0
    disp('succcessful solved');
else
    disp('error');
    yalmiperror(sol.problem)
end



% B = [1 2 3 ;
%     4 5 6 ;
%     7 8 9 ]
V = value(V);        
% for  i = 1 : 33   
%      VV(24*i - 23 : 24*i)   =  V(i,: );   
%      XX(24*i - 23 : 24*i) =   i;
%      YY(24*i - 23 : 24*i ) =  1:24;
% end  
% plot3(XX,YY,VV,'*');
figure(1)
[XX,YY] =meshgrid(1:24,1:33 );
mesh(XX,YY,V);
xlabel('时刻（h）');
ylabel('节点序号');
zlabel('电压幅值（pu）');
title('24小时节点电压图');

figure(2)
[XX,YY] =meshgrid(1:24,1:33 );
mesh(XX,YY,pload);     % pload需要进一步归算（利用pload_prim，a,b反推 ）
xlabel('时刻（h）');
ylabel('节点序号');
zlabel('有功负荷（pu）');
title('24小时有功负荷图');

figure(3)
[XX,YY] =meshgrid(1:24,1:33 );
mesh(XX,YY,qload);
xlabel('时刻（h）');
ylabel('节点序号');
zlabel('无功负荷（pu）');
title('24小时无功负荷图');


figure(4)
p_wt= value(p_wt);
plot(wind,'k-*');
hold on 
plot(p_wt',':ro');
xlabel('时刻（h）');
ylabel('风机出力（pu）');
title('24小时风机出力图');


figure(5)
k= value(k);
Q_cb= value(Q_cb);
plot(Q_cb(1,:));
hold on 
plot(Q_cb(2,:));
xlabel('时刻（h）');
ylabel('无功补偿电容器组CB出力（pu）');
title('24小时无功补偿电容器组CB出力图');


figure(6)
q_SVC = value(q_SVC);    
plot(q_SVC(1,:));
hold on 
plot(q_SVC(2,:));
hold on 
plot(q_SVC(3,:));
xlabel('时刻（h）');
ylabel('静止（连续）无功补偿电容器SVC出力（pu）');
title('24小时静止（连续）无功补偿电容器SVC出力图');


figure(7)
r1 = value(r1);    
plot(r1);
xlabel('时刻（h）');
ylabel('有载调压变压器OLTC变比（pu）');
title('24小时有载调压变压器OLTC变比图');


% p_dch = sdpvar(ness,T);   %ESS放电功率                
% p_ch = sdpvar(ness,T);   %ESS充电功率               
BA_dch = value(p_dch)*1.11;     
BA_ch = value(p_ch)*0.9;    
% BA_dch = value(p_dch);     
% BA_ch = value(p_ch);    
BA1 = BA_ch(1,:) - BA_dch(1,:);
BA2 = BA_ch(2,:) - BA_dch(2,:);
figure(8)  
plot(BA1,'-*');
hold on
plot(BA2,'-o');
xlabel('时刻（h）');
ylabel('ESS电池充放电功率（pu）');     
title('24小时ESS电池充放电功率图');       
BA1_P_Sum=sum(BA1);             
BA2_P_Sum=sum(BA2);  


E_ess=value(E_ess);
figure(9)
plot(E_ess','-o');
xlabel('时刻（h）');
ylabel('ESS电池电量Soc（pu）');     
title('24小时ESS电池电量Soc图');     





































