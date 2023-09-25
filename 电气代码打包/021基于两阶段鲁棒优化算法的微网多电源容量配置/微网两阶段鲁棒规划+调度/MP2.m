function [yita,LB,ee_bat_int,p_wt_int,p_pv_int,p_g_int]=MP2(p_wt,p_pv,p_load)
%% 1.���
%Ͷ�ʳɱ�����
rp = 0.08;%������
rbat = 10;rPV = 20;rWT = 15;rG = 15;%��������
cbat = 1107;cPV = 100;cWT = 300;cG = 2000;%��λ����Ͷ�ʳɱ�

p_m_max = 500;%�����߹�������
eta = 0.95;%���ܳ�ŵ�Ч��
c_wt_om = 0.0296;c_pv_om = 0.0096;c_g_om = 0.059;c_bat_om = 0.009;%��ά�ɱ�ϵ��
c_fuel = 0.6;%ȼ�ϳɱ�ϵ��
%% 2.����߱���
p_ch = sdpvar(24,4);%���ܳ��
p_dis = sdpvar(24,4);%���ܷŵ�
uu_bat = binvar(24,4);%��ŵ��ʶ

uu_m = binvar(24,4);%������ʶ
p_buy = sdpvar(24,4);%��������
p_sell = sdpvar(24,4);%�����۵�

p_g = sdpvar(24,4);%΢��ȼ���ֻ�
%% 3.�����
ee_bat_int = sdpvar(1);%������������
p_pv_int = sdpvar(1);
p_wt_int = sdpvar(1);
p_g_int = sdpvar(1);

yita = sdpvar(1);
p_bat_int = ee_bat_int*0.21;%���财�ܵĹ������޺����������б�ֵ��ϵ
ee0 = 0.55*ee_bat_int;%���ܳ�ʼ����

%�������͵�ۣ��Դ���������Ϊ����
p_l = xlsread('�ĸ�����������.xlsx','0%','B3:E26')*900;
max_p_wt=xlsread('�ĸ�����������.xlsx','0%','H3:K26')*p_wt_int; 
max_p_pv=xlsread('�ĸ�����������.xlsx','0%','N3:Q26')*p_pv_int; 
%price=xlsread('�ĸ�����������.xlsx','���','A2:A25');
price = [0.48;0.48;0.48;0.48;0.48;0.48;0.48;0.9;1.35;1.35;1.35;0.9;0.9;0.9;0.9;0.9;0.9;0.9;1.35;1.35;1.35;1.35;1.35;0.48];

%% 4.��Լ��
C = [];
load = p_l';
wwt = 0.05;wpv = 0.1;wl = 0.15;%��ȷ���ȣ����ű���
%  for t=1:24
%  constraints=[constraints,(1-wwt)*max_p_wt(t,:)<=p_wt(t,:),p_wt(t,:)<=(1+wwt)*max_p_wt(t,:)];
%  constraints=[constraints,(1-wpv)*max_p_pv(t,:)<=p_pv(t,:),p_pv(t,:)<=(1+wpv)*max_p_pv(t,:)];
%  constraints=[constraints,(1-wl)*load(:,t)'<=p_load(t,:),p_load(t,:)<=(1+wl)*load(:,t)'];
%  end
%����Լ��
%      constraints=[constraints,p_bat_int==ee_bat_int*0.21];
%01�����ͱ����˻������Ի�
y1 = sdpvar(24,4);y2 = sdpvar(24,4);
for t = 1:24
    C = [C ,0<=p_dis(t,:),p_dis(t)<=y1(t,:)];    
    C = [C ,y1(t,:)<=p_bat_int];%���ܵĹ�������
    C = [C ,y1(t,:)>=p_bat_int-1000*uu_bat(t,:)];
    C = [C ,y1(t,:)>=20*(1-uu_bat(t,:)),y1(t)<=1000*(1-uu_bat(t,:))];
 
    C = [C, 0<=p_ch(t,:),p_ch(t,:)<=y2(t,:)];    
    C = [C, y2(t,:)<=p_bat_int];
    C = [C, y2(t,:)>=p_bat_int-1000*(1-uu_bat(t,:))];
    C = [C, y2(t,:)>=20*uu_bat(t,:),y2(t)<=1000*uu_bat(t,:)];
end
%% ��������
x = [p_buy(:,1)' p_sell(:,1)' p_g(:,1)' p_ch(:,1)' p_dis(:,1)' p_buy(:,2)' p_sell(:,2)' p_g(:,2)' p_ch(:,2)' p_dis(:,2)' p_buy(:,3)' p_sell(:,3)' p_g(:,3)' p_ch(:,3)' p_dis(:,3)' p_buy(:,4)' p_sell(:,4)' p_g(:,4)' p_ch(:,4)' p_dis(:,4)']';
u = [p_wt(:,1)' p_pv(:,1)' p_load(:,1)' p_wt(:,2)' p_pv(:,2)' p_load(:,2)' p_wt(:,3)' p_pv(:,3)' p_load(:,3)' p_wt(:,4)' p_pv(:,4)' p_load(:,4)']';

P = [price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48) price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48) price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48) price' -price' (c_g_om+c_fuel).*ones(1,24) c_bat_om.*ones(1,48)]';
B = repmat([c_wt_om.*ones(1,24) c_pv_om.*ones(1,24) zeros(1,24)]',1,4);
Q1 = [              zeros(24,48) eye(24) zeros(24,48) zeros(24,360);
      zeros(24,120) zeros(24,48) eye(24) zeros(24,48) zeros(24,240);
      zeros(24,240) zeros(24,48) eye(24) zeros(24,48) zeros(24,120);
      zeros(24,360) zeros(24,48) eye(24) zeros(24,48)];
Q2 = [              zeros(48,72) eye(48) zeros(48,360);
      zeros(48,120) zeros(48,72) eye(48) zeros(48,240);
      zeros(48,240) zeros(48,72) eye(48) zeros(48,120);
      zeros(48,360) zeros(48,72) eye(48)];
Q3 = [             zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,360);
      zeros(1,120) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,240);
      zeros(1,240) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24) zeros(1,120);
      zeros(1,360) zeros(1,72) eta.*ones(1,24) -1/eta.*ones(1,24)];
Q4 = [              eye(48) zeros(48,72) zeros(48,360);
      zeros(48,120) eye(48) zeros(48,72) zeros(48,240);
      zeros(48,240) eye(48) zeros(48,72) zeros(48,120);
      zeros(48,360) eye(48) zeros(48,72)];
Q5 = [              zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,360);
      zeros(24,120) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,240);
      zeros(24,240) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0) zeros(24,120);
      zeros(24,360) zeros(24,72) eta.*tril(ones(24,24),0) -1/eta.*tril(ones(24,24),0)];
Q6 = [              eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,360);
      zeros(24,120) eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,240);
      zeros(24,240) eye(24) -eye(24) eye(24) -eye(24) eye(24) zeros(24,120);
      zeros(24,360) eye(24) -eye(24) eye(24) -eye(24) eye(24)];
G = [              eye(24) eye(24) -eye(24) zeros(24,216);
     zeros(24,72)  eye(24) eye(24) -eye(24) zeros(24,144);
     zeros(24,144) eye(24) eye(24) -eye(24) zeros(24,72);
     zeros(24,216) eye(24) eye(24) -eye(24)];
T2 = [uu_bat(:,1);(1-uu_bat(:,1));uu_bat(:,2);(1-uu_bat(:,2));uu_bat(:,3);(1-uu_bat(:,3));uu_bat(:,4);(1-uu_bat(:,4))].*p_bat_int;
T4 = [uu_m(:,1);1-uu_m(:,1);uu_m(:,2);1-uu_m(:,2);uu_m(:,3);1-uu_m(:,3);uu_m(:,4);1-uu_m(:,4)].*p_m_max;
T5 = repmat(0.9*ee_bat_int-ee0,96,1);
T51 = repmat(0.1*ee_bat_int-ee0,96,1);
%% ����ԭʼԼ��
%΢��ȼ���ֻ�������Լ��
C = [C, Q1*x <= p_g_int];
C = [C, Q1*x >= 0];
% constraints=[constraints,Q2*x<=T2];
% constraints=[constraints,Q2*x>=0];
%��ŵ���ƽ��Լ��
C = [C, Q3*x == 0];
%���������Լ��
C = [C, Q4*x <= T4];
C = [C, Q4*x >= 0];
%SOCԼ��
C = [C, Q5*x <= T5];
C = [C, Q5*x >= T51];
%����ƽ��
C = [C, Q6*x + G*u == 0];

C = [C, yita >= sum(sum(repmat(price,1,4).*(p_buy(:,:)-p_sell(:,:)))+c_fuel*sum(p_g(:,1))+...%���۵�ɱ���ȼ�ϳɱ�
        sum(c_wt_om*p_wt(:,:))+sum(c_pv_om*p_pv(:,:))+sum(c_g_om*p_g(:,:))+sum(c_bat_om*p_dis(:,:))+sum(c_bat_om*p_ch(:,:)));%+...%��ά�ɱ�
];
%Լ��
F=[];
F=[F,ee_bat_int>=20,p_pv_int>=max(max(p_pv)),p_wt_int>=max(max(p_wt)),p_g_int>=20,yita>=0];
Fj=rp*(rp+1)^rbat/((rp+1)^rbat-1)*cbat*ee_bat_int+rp*(rp+1)^rPV/((rp+1)^rPV-1)*cPV*p_pv_int+rp*(rp+1)^rWT/((rp+1)^rWT-1)*cWT*p_wt_int+...
    rp*(rp+1)^rG/((rp+1)^rG-1)*cG*p_g_int+yita;
ops=sdpsettings('solver','cplex');
result=optimize(F+C,Fj,ops);
ee_bat_int=value(ee_bat_int);%��ش��ܵ�����
p_wt_int=value(p_wt_int);%���
p_pv_int=value(p_pv_int);%���
p_g_int=value(p_g_int);%
LB=value(Fj);
yita=value(yita);
value(p_ch);
