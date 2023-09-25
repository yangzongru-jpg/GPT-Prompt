%��ʱ��+SVC+CB+OLTC+DG SOCP_OPF   Sbase=1MVA,   Ubase=12.66KV
%Ŀ�꺯�����ֻ��������ôOLTC��Զ�Ǹߵ�λ����ѹԽ�ߣ�����ԽС��������һ������Ŀ�꺯�����������磬���ߵ�ѹƽ��          

%%
%���ص�ѹ��ѹ����λ�����Ǹ��ڵ�

%%
clear 
clc 
tic 
warning off
%% 1.���
mpc = IEEE33BW;
wind = mpc.wind;    
pload = mpc.pload;    
pload_prim = mpc.pload_prim/1000;  %��Ϊ����ֵ
qload_prim = mpc.qload_prim/1000;
a = 3.715;   %��ʱ�����нڵ��й�����,MW
b = 2.3;     %��ʱ�����нڵ��޹�����,MW
pload = pload/a;%�õ�����ʱ���뵥ʱ�������ı���ϵ��
qload = pload/b;%�����й������������޹����ɱ仯������ͬ
pload = pload_prim*pload;   %�õ�33*24�ĸ���ֵ��ÿһ��ʱ���ÿ���ڵ�ĸ���
qload = qload_prim*qload;      

branch = mpc.branch;       
branch(:,3) = branch(:,3)*1/(12.66^2);%���迹����ֵ      
R = real(branch(:,3));            
X = imag(branch(:,3));             
T = 24;%ʱ����Ϊ24Сʱ             
nb = 33;%�ڵ���            
nl = 32;%֧·��           
nsvc = 3;%SVC��      ��ֹ�޹������� Static Var compensator
ncb = 2;%CB��        ����Ͷ�е������� (capacitorbanks��CB)
noltc = 1;%OLTC��    ���ص�ѹ��ѹ�� ( on��load tap changer��OLTC ��  transformer   
nwt = 2;%2�����     
ness = 2;%ESS��      
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
        0.94*0.94*ones(1,T)];%�����ѹ���󣬸��ڵ�ǰ�ƣ���˲��Ǻ㶨ֵ1.06
Pgmax = [zeros(nb-1,T)
         5*ones(1,T)];
Pgmin = [zeros(nb-1,T)
         0*ones(1,T)];
Qgmax = [zeros(nb-1,T)
         3*ones(1,T)];
Qgmin = [zeros(nb-1,T)
         -1*ones(1,T)];
QCB_step = 100/1000;       %����CB�޹�,100Kvar ת����ֵ     
%% 2.�����
V = sdpvar(nb,T);%��ѹ��ƽ��
I = sdpvar(nl,T);%֧·������ƽ��
P = sdpvar(nl,T);%��·�й����ǲ���ƽ���ҾͲ�����ˣ�Ӧ�ò��ǣ�
Q = sdpvar(nl,T);%��·�޹�
Pg = sdpvar(nb,T);%������й�
Qg = sdpvar(nb,T);%������޹�
theta_CB = binvar(ncb,T,5); %CB��λѡ�����Ϊ5
theta_IN = binvar(ncb,T);%CB��λ�����ʶλ
theta_DE = binvar(ncb,T);%CB��λ��С��ʶλ   

q_SVC = sdpvar(nsvc,T);%SVC�޹�    
p_wt = sdpvar(nwt,T);%����й�     


p_dch = sdpvar(ness,T);   %ESS�ŵ繦��
p_ch = sdpvar(ness,T);   %ESS��繦��
u_dch = binvar(ness,T);%ESS�ŵ�״̬
u_ch = binvar(ness,T);%ESS���״̬
E_ess = sdpvar(ness,25);%ESS�ĵ��������25��ԭ��Ҫ�㶮������ⴢ��һ�쿪ʼ����ʱ�̣���ĩ��������ȵ���˼   

r1 = sdpvar(noltc,T);     
theta_OLTC = binvar(noltc,T,12);%OLTC��λѡ�����Ϊ12
theta1_IN = binvar(noltc,T);%OLTC��λ�����ʶλ
theta1_DE = binvar(noltc,T);%OLTC��λ��С��ʶλ
%% 3.��Լ��
C = [];        
%% ����װ�ã�ESS��Լ��       
%��ŵ�״̬Լ��        
C = [C, u_dch + u_ch <= 1];%��ʾ��磬�ŵ磬���䲻������״̬
%����Լ��
C = [C, 0 <= p_dch(1,:) <= u_dch(1,:)*0.3];
C = [C, 0 <= p_dch(2,:) <= u_dch(2,:)*0.2];
C = [C, 0 <= p_ch(1,:) <= u_ch(1,:)*0.3];
C = [C, 0 <= p_ch(2,:) <= u_ch(2,:)*0.2];
%����Լ��
for t = 1:24  
        C = [C, E_ess(:,t+1) == E_ess(:,t) + 0.9*p_ch(:,t) - 1.11*p_dch(:,t)];   %Ч��
end

C = [C, E_ess(:,1) == E_ess(:,25)];
C = [C, 0.18 <= E_ess(1,:) <= 1.8];
C = [C, 0.10 <= E_ess(2,:) <= 1.0];        
%Ͷ��ڵ�ѡ������س�ŵ�״̬��
P_dch = [zeros(14,T);p_dch(1,:);zeros(16,T);p_dch(2,:);zeros(1,T)];   %��ط��ڵ�15�ڵ�͵�32�ڵ�
P_ch = [zeros(14,T);p_ch(1,:);zeros(16,T);p_ch(2,:);zeros(1,T)];      

%% ��������)Լ��             
C = [C, 0 <= p_wt,   p_wt <= ones(2,1)*wind];        
P_wt = [zeros(16,24);p_wt(1,:);zeros(14,24);p_wt(2,:);zeros(1,24)];     %�������17��32�ڵ�

%% ���ص�ѹ��ѹ����OLTC��Լ��        
rjs = zeros(1,12);%����2����ͷ�ı��  ƽ��֮��     
for i = 1:12
    rjs(1,i) = (0.93+(i+1)*0.01)^2 -(i*0.01+0.93)^2;
end

for t = 1:24
    C = [C, r1(1,t) == 0.94^2+ sum(rjs.*theta_OLTC(1,t,:))];  %%������λ���dita^2 * ���ص�λ״̬
end

for i = 1:11
    C = [C, theta_OLTC(:,:,i) >= theta_OLTC(:,:,i+1)];   %0���治����1
end
% theta_OLTC = value(theta_OLTC);

C = [C, V(33,:) == r1];        %%���ֵ��1.06^2,����  ������33�ڵ�   
C = [C, theta1_IN + theta1_DE <= 1];        
k = sum(theta_OLTC,3);     %���ص�ѹ��ѹ��Ͷ��״̬������� ��1*24��   

for t = 1:T-1
    C = [C, k(:,t+1) - k(:,t) <= theta1_IN(:,t)*12 - theta1_DE(:,t) ];  %��ѹ���ܳ���12������ѹ����С��1��
    C = [C, k(:,t+1) - k(:,t) >= theta1_IN(:,t) - theta1_DE(:,t)*12 ];
end
C = [C, sum(theta1_IN + theta1_DE,2) <= 5 ];  %�������ص�ѹ��ѹ���յ��ڴ���Ϊ5��
%% �����޹�����װ�ã�SVC��Լ��      
C = [C, -0.1 <= q_SVC <= 0.3];
Q_SVC = [zeros(4,T);q_SVC(1,:);zeros(9,T);q_SVC(2,:);zeros(15,T);q_SVC(3,:);zeros(2,T)];%SVCͶ��ڵ�ѡ��5��15��31
%% ��ɢ�޹�����װ�ã�CB��Լ��     
Q_cb = sum(theta_CB,3).*QCB_step;     
Q_CB = [zeros(4,T);Q_cb(1,:);zeros(9,T);Q_cb(2,:);zeros(18,T)];%Ͷ��ڵ�ѡ��5��15
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
C = [C, sum(theta_IN + theta_DE,2) <= 5];   %��CB���յ��ڴ�������Ϊ5

%% ����Լ��
%�ڵ㹦��Լ��
Pin = -upstream*P + upstream*(I.*(R*ones(1,T))) + dnstream*P;%�ڵ�ע���й�
Qin = -upstream*Q + upstream*(I.*(X*ones(1,T))) + dnstream*Q;%�ڵ�ע���޹�
C = [C, Pin + pload - Pg - P_wt - P_dch + P_ch == 0];
C = [C, Qin + qload - Qg - Q_SVC - Q_CB == 0];
%ŷķ����Լ����֧·��β��ѹԼ����
C = [C, V(branch(:,2),:) == V(branch(:,1),:) - 2*(R*ones(1,24)).*P - 2*(X*ones(1,24)).*Q + ((R.^2 + X.^2)*ones(1,24)).*I];
%����׶Լ����֧·����Լ��������������ĺͷ�����
C = [C, V(branch(:,1),:).*I >= P.^2 + Q.^2];
%% ͨ��Լ��
%�ڵ��ѹԼ��
C = [C, Vmin <= V,V <= Vmax];
%���������Լ��
C = [C, Pgmin <= Pg,Pg <= Pgmax,Qgmin <= Qg,Qg <= Qgmax];
%֧·����Լ��
C = [C, 0 <= I,I <= 10];   %����һ�裨Խ������ߴ֣��۸��
%% 4.��Ŀ�꺯��
objective = sum(Pg(33,:))  +  0.3*sum(sum(I.*(R*ones(1,T))));   %������������������� + 0.3*��������й����
toc%��ģʱ��
%% 5.�������
ops = sdpsettings('verbose', 1, 'solver', 'cplex');
ops.cplex= cplexoptimset('cplex');%�������޸�������϶��ʹMIP�����ܵĸ��죬����ʹ��
ops.cplex.mip.tolerances.absmipgap = 0.01;

sol = optimize(C,objective,ops);

objective = value(objective)

toc%���ʱ��
% clear branch C dnstream upstream i kk mpc nb nl ncb ness noltc npv nwt nsvc...
%       QCB_step ops Pgmax Pgmin pload qload t T theta_DE theta_IN ...
%       Vmax Vmin R X P_ch P_dch P_pv P_wt Q_SVC Qgmax Qgmin Pin Qin...
%       Q_CB k r rjs theta1_DE theta1_IN 

%% 6.���������־
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
xlabel('ʱ�̣�h��');
ylabel('�ڵ����');
zlabel('��ѹ��ֵ��pu��');
title('24Сʱ�ڵ��ѹͼ');

figure(2)
[XX,YY] =meshgrid(1:24,1:33 );
mesh(XX,YY,pload);     % pload��Ҫ��һ�����㣨����pload_prim��a,b���� ��
xlabel('ʱ�̣�h��');
ylabel('�ڵ����');
zlabel('�й����ɣ�pu��');
title('24Сʱ�й�����ͼ');

figure(3)
[XX,YY] =meshgrid(1:24,1:33 );
mesh(XX,YY,qload);
xlabel('ʱ�̣�h��');
ylabel('�ڵ����');
zlabel('�޹����ɣ�pu��');
title('24Сʱ�޹�����ͼ');


figure(4)
p_wt= value(p_wt);
plot(wind,'k-*');
hold on 
plot(p_wt',':ro');
xlabel('ʱ�̣�h��');
ylabel('���������pu��');
title('24Сʱ�������ͼ');


figure(5)
k= value(k);
Q_cb= value(Q_cb);
plot(Q_cb(1,:));
hold on 
plot(Q_cb(2,:));
xlabel('ʱ�̣�h��');
ylabel('�޹�������������CB������pu��');
title('24Сʱ�޹�������������CB����ͼ');


figure(6)
q_SVC = value(q_SVC);    
plot(q_SVC(1,:));
hold on 
plot(q_SVC(2,:));
hold on 
plot(q_SVC(3,:));
xlabel('ʱ�̣�h��');
ylabel('��ֹ���������޹�����������SVC������pu��');
title('24Сʱ��ֹ���������޹�����������SVC����ͼ');


figure(7)
r1 = value(r1);    
plot(r1);
xlabel('ʱ�̣�h��');
ylabel('���ص�ѹ��ѹ��OLTC��ȣ�pu��');
title('24Сʱ���ص�ѹ��ѹ��OLTC���ͼ');


% p_dch = sdpvar(ness,T);   %ESS�ŵ繦��                
% p_ch = sdpvar(ness,T);   %ESS��繦��               
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
xlabel('ʱ�̣�h��');
ylabel('ESS��س�ŵ繦�ʣ�pu��');     
title('24СʱESS��س�ŵ繦��ͼ');       
BA1_P_Sum=sum(BA1);             
BA2_P_Sum=sum(BA2);  


E_ess=value(E_ess);
figure(9)
plot(E_ess','-o');
xlabel('ʱ�̣�h��');
ylabel('ESS��ص���Soc��pu��');     
title('24СʱESS��ص���Socͼ');     





































