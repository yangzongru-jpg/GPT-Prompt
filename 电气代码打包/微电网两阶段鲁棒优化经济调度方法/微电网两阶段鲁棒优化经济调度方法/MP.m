function [x, LB, y] = MP(u)
%% ���ò���
pm_max=1500;%�����߹�������
eta=0.95;%���ܳ�ŵ�Ч��
p_g_max=800;%ȼ���ֻ����������
p_g_min=80;%ȼ���ֻ���С��������
ps_max=500;%������������ŵ������
ES_max=1800;%���ص��ȹ�������������ʣ������
ES_min=400; %���ص��ȹ������������Сʣ������
ES0=1000; %���ȹ����г�ʼ����
DDR=2940;%������Ӧ���õ�����

DR_max=200;%������Ӧ�õ��������ֵ
DR_min=50; %������Ӧ�õ�������Сֵ

a=0.67;
b=0;
KS=0.38;
KDR=0.32; %������Ӧ���ɵ�λ���ȳɱ�
price = [0.48;0.48;0.48;0.48;0.48;0.48;0.48;0.9;1.35;1.35;1.35;0.9;0.9;0.9;0.9;0.9;0.9;0.9;1.35;1.35;1.35;1.35;1.35;0.48];
%���Ǹ����������������ǰ���׵�ۣ�

PW_=[0.6564    0.6399    0.6079    0.5594    0.5869    0.5794    0.6138    0.6192   0.6811    0.6400    0.7855    0.7615    0.6861    0.8780    0.6715    0.7023    0.6464    0.6321    0.6819    0.6943    0.7405    0.6727    0.6822    0.6878];
%p_pv=1500*[     0         0         0         0         0    0.0465    0.1466    0.3135     0.4756    0.5213    0.6563    1.0000    0.7422    0.6817    0.4972    0.4629    0.2808    0.0948    0.0109         0         0         0         0         0];
%PL=1500*[ 0.4658    0.4601    0.5574    0.5325    0.5744    0.6061    0.6106    0.6636    0.7410    0.7080    0.7598    0.8766    0.7646    0.7511    0.6721    0.5869    0.6159    0.6378    0.6142    0.6752    0.6397    0.5974    0.5432    0.4803];
%�������Ǻ�������p_pv�ǹ�����磬PL�ǹ̶��ո��ɣ�    
%MP����û����p_pv��PL
P_DR=1*[110 100 90 80 100 100 130 100 120 160 175 200 140 100 100 120 140 150 190 200 200 190 80 60];
%���Ǹ�������(��ת�Ƹ�����)

%%����߱���
p_ch=sdpvar(1,24,'full');%���ܳ��
p_dis=sdpvar(1,24,'full');%���ܷŵ�
us=binvar(1,24,'full');%��ŵ��ʶ

p_buy=sdpvar(1,24,'full');%��������
p_sell=sdpvar(1,24,'full');%�����۵�
um=binvar(1,24,'full');%���۵��ʶ

%p_pv=sdpvar(1,24,'full');%������� 
%pL=sdpvar(1,24,'full');%�̶��ո���


p_g=sdpvar(1,24,'full');%�ֲ�ʽ��Դ
PDR=sdpvar(1,24,'full');%��ת�Ƹ���
PDR1=sdpvar(1,24,'full');%��ת�Ƹ��ɸ�������
PDR2=sdpvar(1,24,'full');%��ת�Ƹ��ɸ�������

afa=sdpvar(1,1,'full');%ʽ25�Ħ�


%% ��������
x=[us,um]';%��һ�׶α���
y=[p_g,p_ch,p_dis,PDR,PDR1,PDR2,p_buy,p_sell]';%�ڶ��׶α��� ����û�п�����������
%u=[p_pv,PL]';%��ȷ����������Ϊȷ����Ϊ����ӳ�����������Ľ⣩
%MPû�п���u=[p_pv,PL]'
Q01=[eye(24),zeros(24,24)];%us ����eye��24��ָ����24*24�ĵ�λ����
Q02=[zeros(24,24),eye(24)];%um

Q1=[eye(24),zeros(24,168)];%�ֲ�ʽ��ԴԼ����ϵ������
Q2=[zeros(1,24),eta.*ones(1,24),-1/eta.*ones(1,24),zeros(1,120)];

Q31=[zeros(24,24),eye(24),zeros(24,144)];%p_ch9c 
Q32=[zeros(24,48),eye(24),zeros(24,120)];%p_dis

Q4=[zeros(24,24),eta.*tril(ones(24,24),0),-1/eta.*tril(ones(24,24),0),zeros(24,120)];
Q51=[zeros(24,144),eye(24),zeros(24,24)];%p_buy
Q52=[zeros(24,168),eye(24)];%p_sell

Q6=[eye(24),-eye(24),eye(24),-eye(24),zeros(24,24),zeros(24,24),eye(24),-eye(24)];

%Q7=[zeros(24,72),eye(24),-eye(24)];

Q8=[zeros(1,72),ones(1,24),zeros(1,96)];
Q9=[zeros(24,72),eye(24),zeros(24,96)];

Q101=[zeros(24,96),eye(24),zeros(24,72)];
Q102=[zeros(24,120),eye(24),zeros(24,48)];
Q103=[zeros(24,72),eye(24),eye(24),-eye(24),zeros(24,48)];

QCS=[zeros(24,24),KS*eta.*eye(24),KS*1/eta.*eye(24),zeros(24,120)];
QCDR=[zeros(24,96),KDR*eye(24),KDR*eye(24),zeros(24,48)];
QCM=[zeros(24,144),eye(24),-eye(24)];
QC=[a*ones(1,24),KS*eta.*ones(1,24),KS*1/eta.*ones(1,24),zeros(1,24),KDR*ones(1,24),KDR*ones(1,24),price'.*ones(1,24),-price'.*ones(1,24)];


G1=[eye(24),-eye(24)];

%T1=ps_max*[(1-us),us]';
%T2=pm_max*[(1-um),um]';


%% ����ԭʼԼ��
C=[-Q1*y>=-p_g_max];%�ֲ�ʽ��ԴԼ��
C=C+[Q1*y>=p_g_min];

C=C+[-Q31*y-ps_max*Q01*x>=-ps_max];%����Լ��
C=C+[-Q32*y>=-Q01*x*ps_max];
C=C+[Q31*y>=0];
C=C+[Q32*y>=0];
C=C+[Q2*y==0];%��֤�����ڵ���ǰ��������ͬ
C=C+[-Q4*y>=-(ES_max-ES0)];
C=C+[Q4*y>=(ES_min-ES0)];

C=C+[-Q52*y-pm_max*Q02*x>=-pm_max];%���������Լ��
C=C+[-Q51*y>=-Q02*x*pm_max];
C=C+[Q51*y>=0];
C=C+[Q52*y>=0];
C=C+[Q6*y+G1*u==0];

C=C+[Q8*y==DDR];%��ת�Ƹ���Լ��
C=C+[-Q9*y>=-DR_max];
C=C+[Q9*y>=DR_min];
C=C+[Q101*y>=0];
C=C+[Q102*y>=0];
%C=C+[Q9*y+Q101*y-Q102*y=P_DR];
C=C+[Q103*y==P_DR'];


%% ���׶�³���Ż�ģ��
%cy
%Dy>=d
%Ky=g
%Fx+Gy>=h
%Ly+Yu=0

D=[-Q1;Q1;Q31;Q32;-Q4;Q4;Q51;Q52;-Q9;Q9;Q101;Q102];%D��K��F��G �� Iu Ϊ��ӦԼ���±�����ϵ������d��h Ϊ����������
d=[-p_g_max*ones(24,1);p_g_min*ones(24,1);0*ones(24,1);0*ones(24,1);-(ES_max-ES0)*ones(24,1);(ES_min-ES0)*ones(24,1);0*ones(24,1);0*ones(24,1);-DR_max*ones(24,1);DR_min*ones(24,1);0*ones(24,1);0*ones(24,1)];

K=[Q2;Q8;Q103];
g=[0;DDR;P_DR'.*ones(24,1)];

F=[-ps_max*Q01;ps_max*Q01;-pm_max*Q02;pm_max*Q02];
G=[-Q31;-Q32;-Q52;-Q51];
h=[-ps_max*ones(24,1);0*ones(24,1);-pm_max*ones(24,1);0*ones(24,1)];

L=[Q6];
Y=[G1];

%CG=a*p_g+b;
%CS=KS*(p_ch+p_dis);
%CM=price.*(p_buy-p_sell);
%CDR=KDR*abs(PDR-P_DR);

CG=a*Q1*y;
%CS=KS*(1/eta.*Q32*y+eta.*Q31*y);
CS=QCS*y;
%CM=price.*(Q51*y-Q52*y);
% CM=price.*QCM*y;
%CDR=KDR*(Q101*y+Q102*y);
CDR=QCDR*y;

c=QC;%���պ��Ŀ�꺯��

C=C+[D*y>=d];%���պ��Լ������
C=C+[K*y==g];
C=C+[F*x+G*y>=h];
C=C+[L*y+Y*u==0];
C=C+[afa>=c*y];%�����afaָ����ʽ25�Ħ�
%% �������,

Fj=afa;
%Fj=sum(CG)+sum(CM)+sum(CS)+sum(CDR);
ops = sdpsettings('solver','cplex');
result = optimize(C,Fj,ops);

%x_1=value(x);
result_p_ch=value(p_ch);
result_p_dis=value(-p_dis);
result_p_g=value(p_g);
result_p_buy=value(p_buy);
result_p_sell=value(-p_sell);
result_PDR=value(PDR);

result_us=value(us);
result_um=value(um);
x=value(x);
y=value(y);
LB=value(afa);
%PL1=PL+result_p_ch-result_p_dis-result_p_g;

figure(2)
bar(result_p_g,0.7,'b')
axis([1,24 0 1000])
legend('ȼ���ֻ�����');
xlabel('ʱ��/h')
ylabel('����/kw')

figure(3)
plot(-result_p_buy,'-d')
xlim([1 24])
grid
hold on
plot(-result_p_sell,'-d')
legend('�г��۵���','�г�������');
xlabel('ʱ��/h')
ylabel('����/kw')

% stairs(-result_p_buy,'b','linewidth',2)
% hold on
% stairs(-result_p_sell,'g','linewidth',2)
% hold off

figure(4)
bar(-result_p_ch,0.75,'b')
hold on
bar(-result_p_dis,0.75,'g')
legend('��繦��','�ŵ繦��');
xlabel('ʱ��/h')
ylabel('����/kw')


figure(5)
xlim([1 24])
grid
plot(P_DR,'-d')
hold on
plot(result_PDR,'-d')
legend('��ת�Ƹ���','ʵ���õ�ƻ�');
xlabel('ʱ��/h')
ylabel('����/kw')