function [p_wt,p_pv,p_load,x,UB] = SP(ee_bat_int,p_wt_int,p_pv_int,p_g_int,LB,yita)
%% 1.���
pm_max = 500;%�����߹�������
p_bat_int = ee_bat_int*0.21;%���财�ܵĹ������޺����������б�ֵ��ϵ

ee0 = 0.55*ee_bat_int; %���ܳ�ʼ����
eta = 0.95;%���ܳ�ŵ�Ч��
M = 100000;%һ��������ʵ��
c_wt_om = 0.0296;c_pv_om = 0.0096;c_g_om = 0.059;c_bat_om = 0.009;%��ά�ɱ�ϵ��
c_fuel = 0.6;%ȼ�ϳɱ�ϵ��
%% 2.����߱���
p_ch = sdpvar(24,4);%���ܳ��
p_dis = sdpvar(24,4);%���ܷŵ�
uu_bat = binvar(24,4);%��ŵ��ʶ

uu_m = binvar(24,4);%�������ʶ
p_buy = sdpvar(24,4);%��������
p_sell = sdpvar(24,4);%�����۵�

p_wt = sdpvar(24,4);
p_pv = sdpvar(24,4);
p_load = sdpvar(24,4);

p_g = sdpvar(24,4);%΢��ȼ���ֻ�

%�������͵�ۣ��Դ���������Ϊ����
p_l = xlsread('�ĸ�����������.xlsx','0%','B3:E26')*900;
max_p_wt = xlsread('�ĸ�����������.xlsx','0%','H3:K26')*p_wt_int; 
max_p_pv = xlsread('�ĸ�����������.xlsx','0%','N3:Q26')*p_pv_int; 
%price=xlsread('�ĸ�����������.xlsx','���','A2:A25');
price = [0.48;0.48;0.48;0.48;0.48;0.48;0.48;0.9;1.35;1.35;1.35;0.9;0.9;0.9;0.9;0.9;0.9;0.9;1.35;1.35;1.35;1.35;1.35;0.48];
%% 3.��Լ��
C = [];
load = p_l';
%���ܹ���Լ��
wwt = 0.05;wpv = 0.1;wl = 0.15;%��ȷ����
C = [C, (1 - wwt)*max_p_wt <= p_wt,p_wt <= (1 + wwt)*max_p_wt];%��ȷ���Է�
C = [C, (1 - wpv)*max_p_pv <= p_pv,p_pv <= (1 + wpv)*max_p_pv];%��ȷ���Թ�
C = [C, (1 - wl)*load' <= p_load,p_load <= (1 + wl)*load'];%��ȷ���Ը���
%�趨��ż����
lam1 = sdpvar(96,1);lam11 = sdpvar(96,1);
lam2 = sdpvar(192,1);lam21 = sdpvar(192,1);lam3 = sdpvar(4,1);
lam4 = sdpvar(192,1);lam41 = sdpvar(192,1);lam5 = sdpvar(96,1);
lam51 = sdpvar(96,1);lam6 = sdpvar(96,1);
%��m�����е�01����
beta1 = binvar(96,1);beta11 = binvar(96,1);
beta2 = binvar(192,1);beta21 = binvar(192,1);beta3 = binvar(4,1);
beta4 = binvar(192,1);beta41 = binvar(192,1);beta5 = binvar(96,1);
beta51 = binvar(96,1);beta6 = binvar(96,1);beta7 = binvar(480,1);beta8 = binvar(288,1);

x = [p_buy(:,1)' p_sell(:,1)' p_g(:,1)' p_ch(:,1)' p_dis(:,1)' p_buy(:,2)' p_sell(:,2)' p_g(:,2)' p_ch(:,2)' p_dis(:,2)' p_buy(:,3)' p_sell(:,3)' p_g(:,3)' p_ch(:,3)' p_dis(:,3)' p_buy(:,4)' p_sell(:,4)' p_g(:,4)' p_ch(:,4)' p_dis(:,4)']';
u = [p_wt(:,1)' p_pv(:,1)' p_load(:,1)' p_wt(:,2)' p_pv(:,2)' p_load(:,2)' p_wt(:,3)' p_pv(:,3)' p_load(:,3)' p_wt(:,4)' p_pv(:,4)' p_load(:,4)']';
%xΪ������uΪ��ȷ����
P = [price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)...
     price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)...
     price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)... 
     price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)]';
%������صļ�������Ͳο�����һ��
Q1 = [              zeros(24,48) eye(24)      zeros(24,48) zeros(24,360);
      zeros(24,120) zeros(24,48) eye(24)      zeros(24,48) zeros(24,240);
      zeros(24,240) zeros(24,48) eye(24)      zeros(24,48) zeros(24,120);
      zeros(24,360) zeros(24,48) eye(24)      zeros(24,48)];
Q2 = [zeros(48,72) eye(48) zeros(48,360);
      zeros(48,120) zeros(48,72) eye(48) zeros(48,240);
      zeros(48,240) zeros(48,72) eye(48) zeros(48,120);
      zeros(48,360) zeros(48,72) eye(48)];
Q3 = [zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,360);
      zeros(1,120) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,240);
      zeros(1,240) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,120);
      zeros(1,360) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24)];
Q4 = [eye(48) zeros(48,72) zeros(48,360);
      zeros(48,120) eye(48) zeros(48,72) zeros(48,240);
      zeros(48,240) eye(48) zeros(48,72) zeros(48,120);
      zeros(48,360) eye(48) zeros(48,72)];
Q5 = [zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,360);
      zeros(24,120) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,240);
      zeros(24,240) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,120);
      zeros(24,360) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0)];
Q6 = [eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,360);
      zeros(24,120) eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,240);
      zeros(24,240) eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,120);
      zeros(24,360) eye(24) -eye(24) eye(24) -eye(24) eye(24)];
Q10=[eye(48) zeros(48,72) zeros(48,360);
      zeros(48,120) eye(48) zeros(48,72) zeros(48,240);
      zeros(48,240) eye(48) zeros(48,72) zeros(48,120);
      zeros(48,360) eye(48) zeros(48,72)];

G = [eye(24) eye(24) -eye(24) zeros(24,216);
     zeros(24,72) eye(24) eye(24) -eye(24) zeros(24,144);
     zeros(24,144) eye(24) eye(24) -eye(24) zeros(24,72);
     zeros(24,216) eye(24) eye(24) -eye(24)];
T2 = [uu_bat(:,1);(1-uu_bat(:,1));uu_bat(:,2);(1-uu_bat(:,2));uu_bat(:,3);(1-uu_bat(:,3));uu_bat(:,4);(1-uu_bat(:,4))].*p_bat_int;
T4 = [uu_m(:,1);1-uu_m(:,1);uu_m(:,2);1-uu_m(:,2);uu_m(:,3);1-uu_m(:,3);uu_m(:,4);1-uu_m(:,4)].*pm_max;
T5 = repmat(0.9*ee_bat_int-ee0,96,1);
T51 = repmat(0.1*ee_bat_int-ee0,96,1);

%% ����ԭʼԼ��
%΢��ȼ���ֻ�������Լ��
C = [C, Q1*x <= p_g_int];
C = [C, Q1*x >= 0];
C = [C, Q2*x <= T2];
C = [C, Q2*x >= 0];
%��ŵ���ƽ��Լ��
C = [C, Q3*x == 0];
%���������Լ��
C = [C, Q4*x <= T4];
C = [C, Q4*x >= 0];
%SOCԼ��
C = [C, Q5*x <= T5];
C = [C, Q5*x >= T51];
%����ƽ��
C = [C, Q6*x + G*u == 0];%�����u�Ƕ�ֵ

%kkt
C = [C, Q1'*lam1-Q1'*lam11+Q2'*lam2-Q2'*lam21+Q3'*lam3+Q4'*lam4-Q4'*lam41+Q5'*lam5-Q5'*lam51+Q6'*lam6>=-P];
 
C = [C, Q1*x-p_g_int>=-(1-beta1).*M,lam1<=beta1.*M];
C = [C, Q1*x<=beta11.*M,lam11>=-(1-beta11).*M];

C = [C, Q2*x-T2>=-(1-beta2).*M,lam2<=beta2.*M];
C = [C, Q2*x<=beta21.*M,lam21>=-(1-beta21).*M];

C = [C, Q4*x-T4>=-(1-beta4).*M,lam4<=beta4.*M];
C = [C, Q4*x<=beta41.*M,lam41>=-(1-beta41).*M];

C = [C, Q5*x-T5>=-(1-beta5).*M,lam5<=beta5.*M];
C = [C, Q5*x-T51<=beta51.*M,lam51>=-(1-beta51).*M]; 

C = [C, lam1>=0,lam11<=0,lam2>=0,lam21<=0,lam4>=0,lam41<=0,lam5>=0,lam51<=0];
C = [C, P+Q1'*lam1-Q1'*lam11+Q2'*lam2-Q2'*lam21+Q3'*lam3+Q4'*lam4-Q4'*lam41+Q5'*lam5-Q5'*lam51+Q6'*lam6<=M.*beta7,x<=M.*(1-beta7)];

 %����������
obj_o = sum(sum(repmat(price,1,4).*(p_buy(:,:)-p_sell(:,:)))+c_fuel*sum(p_g(:,1))+...%���۵�ɱ���ȼ�ϳɱ�
        sum(c_wt_om*p_wt(:,:))+sum(c_pv_om*p_pv(:,:))+sum(c_g_om*p_g(:,:))+sum(c_bat_om*p_dis(:,:))+sum(c_bat_om*p_ch(:,:)));%+...%��ά�ɱ�
        %c_bat(1,1)/3*ee_bat_int*k_suo;%����������ĳɱ� 
Cj = -obj_o;
ops = sdpsettings('solver','cplex');
reuslt = optimize(C,Cj,ops);
ops.cplex.exportmodel='abcd.lp';
Q=value(Cj);
UB=LB-yita-Q;
%wwt=value(wwt);wpv=value(wpv);wl=value(wl);
p_wt=value(p_wt);p_pv=value(p_pv);p_load=value(p_load);
x=value(x);

% figure(6)
% % [ss,gg]=meshgrid(1:4,1:24 );
% % mesh(gg,ss,pload);
% plot(pload)
% xlabel('΢�����');
% ylabel('ʱ��');
% % zlabel('���ɵ��Ƚ��');
% title('���ɵ��Ƚ��ͼ');

