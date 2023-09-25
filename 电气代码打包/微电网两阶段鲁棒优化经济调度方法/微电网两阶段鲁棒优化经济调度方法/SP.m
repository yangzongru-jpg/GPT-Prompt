function [u,UB] = SP(x)

%% 1.��������
%ȼ���ֻ���������
pg_max=800;         %ȼ���ֻ����������
pg_min=80;          %ȼ���ֻ���С��������
a=0.67;             %ȼ���ֻ��ɱ�ϵ��a,b����
b=0;

%���ز�������
ps_max=500;         %������������ŵ������
Es_max=1800;        %���ص��ȹ�������������ʣ������
Es_min=400;         %���ص��ȹ������������Сʣ������
Es_0=1000;          %���ȹ����г�ʼ����
Ks=0.38;            %������ŵ�ɱ�
yita=0.95;          %��ŵ�Ч��

%������Ӧ���ɲ�������
K_DR=0.32;          %������Ӧ���ɵ�λ���ȳɱ�
D_DR=2940;          %������Ӧ���õ�����
D_DR_min=50;        %������Ӧ�õ��������ֵ
D_DR_max=200;       %������Ӧ�õ�������Сֵ

%������������ʲ�������
pm_max=1500;        %΢����������������������ֵ

%�������ǰ���׵�ۣ�Ϊ24*1����
price = [0.48;0.48;0.48;0.48;0.48;0.48;0.48;0.9;1.35;1.35;1.35;0.9;0.9;0.9;0.9;0.9;0.9;0.9;1.35;1.35;1.35;1.35;1.35;0.48];

%�����ǰԤ�⣬Ϊ24*1����
p_pv_forecast_0=1500*[  0         0         0         0         0    0.0465    0.1466    0.3135     0.4756    0.5213    0.6563    1.0000    0.7422    0.6817    0.4972    0.4629    0.2808    0.0948    0.0109         0         0         0         0         0]';
%p_pv_forecast=[0; 0; 0; 0; 0; 0; 40; 200; 425; 731; 884; 1180; 900; 830; 600; 510; 340; 50; 0; 0; 0; 0; 0; 0];      %��ʼ�����
%������ǰԤ�⣬Ϊ24*1����
p_l_forecast_0=1500*[ 0.4658    0.4601    0.5574    0.5325    0.5744    0.6061    0.6106    0.6636    0.7410    0.7080    0.7598    0.8766    0.7646    0.7511    0.6721    0.5869    0.6159    0.6378    0.6142    0.6752    0.6397    0.5974    0.5432    0.4803]';
%p_l_forecast=[400; 350; 320; 300; 300; 310; 451; 561; 605; 748; 720; 810; 891; 836; 770; 726; 775.5; 730; 790; 810; 850; 800; 505; 410];        %��ʼ�����
%
C=[];
c=[a*ones(1,24)     Ks*yita*ones(1,24)      (Ks/yita)*ones(1,24)        zeros(1,24)     K_DR*ones(1,48)     price'  -price'   zeros(1,48)];%�������һ��Լ����ʽ�ұߵ�c
%% 2.��������
%��ż�������ã������κ�����
gamma=sdpvar(192,1);     
lamda=sdpvar(50,1);      
miu=sdpvar(192,1);        
pai=sdpvar(48,1);       

%��Ԫ����B����
%B=binvar(48,1);           %BΪ�������ʼ��Ԫ������ȡ��1��Ϊ���� 

%% 3.1 ���������һ��Լ��(��Ӧʽ29��һ�еı���)
%���У�DΪ192*240����dΪ192*1����
D=[eye(24)  zeros(24,216);
  -eye(24)  zeros(24,216);
  zeros(24,24)   yita.*tril(ones(24,24),0)  -1/yita.*tril(ones(24,24),0) zeros(24,168);
  zeros(24,24)   -yita.*tril(ones(24,24),0)  1/yita.*tril(ones(24,24),0) zeros(24,168);
  zeros(24,72)   eye(24)   zeros(24,144);
  zeros(24,72)   -eye(24)  zeros(24,144);
  zeros(24,96)   eye(24)   zeros(24,120);
  zeros(24,120)   eye(24)   zeros(24,96);];

d=[pg_min.*ones(24,1);
   -pg_max.*ones(24,1);
   (Es_min-Es_0).*ones(24,1);
   -(Es_max-Es_0).*ones(24,1);
   D_DR_min.*ones(24,1);
   -D_DR_max.*ones(24,1);
   zeros(48,1)];

%���У�KΪ50*240����sΪ50*1����
K=[zeros(1,24)   yita.*ones(1,24)  -1/yita.*ones(1,24) zeros(1,168);
   zeros(1,72)  ones(1,24)  zeros(1,144);
   zeros(24,72) eye(24)     eye(24)     -eye(24)    zeros(24,96);
   eye(24)     -eye(24)    eye(24)     -eye(24)    zeros(24,48)    eye(24) -eye(24)    eye(24) -eye(24)];
s=[0;
   2940;       %�ܵ�������Ӧ
    110
   100
    90
    80
   100
   100
   130
   100
   120
   160
   175
   200
   140
   100
   100
   120
   140
   150
   190
   200
   200
   190
    80
    60
     %ÿ������ʱ�̵�����������Ӧ
   zeros(24,1)];

%���У�GΪ192*240����hΪ192*1������FΪ192*48����
G=[zeros(24,48)     eye(24)    zeros(24,168);
   zeros(24,48)     -eye(24)   zeros(24,168);
   zeros(24)        eye(24)    zeros(24,192);
   zeros(24)        -eye(24)   zeros(24,192);
   zeros(24,144)    eye(24)    zeros(24,72);
   zeros(24,144)    -eye(24)   zeros(24,72);
   zeros(24,168)    eye(24)    zeros(24,48);
   zeros(24,168)    -eye(24)   zeros(24,48)];
h=[zeros(72,1);
   -ps_max.*ones(24,1);
   zeros(72,1);
   -pm_max.*ones(24,1)];
F=[zeros(24,48);
   ps_max.*eye(24)  zeros(24,24);
   zeros(24,48);
   -ps_max.*eye(24) zeros(24,24);
   zeros(24,48);
   zeros(24,24)     pm_max*eye(24);
   zeros(24,48);
   zeros(24,24)     -pm_max*eye(24);];


%IΪ48*240����uΪ48*1����
I=[zeros(24,192)    eye(24)     zeros(24);
   zeros(24,216)    eye(24)];

u0=[p_pv_forecast_0;p_l_forecast_0];
C = [C, D'*gamma+K'*lamda+G'*miu+I'*pai<=c'];     %�������һ��Լ��

%% 
Dp_pv_max=0.15*1500*[     0         0         0         0         0    0.0465    0.1466    0.3135     0.4756    0.5213    0.6563    1.0000    0.7422    0.6817    0.4972    0.4629    0.2808    0.0948    0.0109         0         0         0         0         0]';
DPL_max=0.1*1500*[ 0.4658    0.4601    0.5574    0.5325    0.5744    0.6061    0.6106    0.6636    0.7410    0.7080    0.7598    0.8766    0.7646    0.7511    0.6721    0.5869    0.6159    0.6378    0.6142    0.6752    0.6397    0.5974    0.5432    0.4803]';
delta_u=[Dp_pv_max;DPL_max];%ʽ29��������Ħ�u

BPV=binvar(24,1,'full');
BL=binvar(24,1,'full');

B=[BPV;BL];                 %ʽ29���������B'    
BB=sdpvar(48,1);%����ĸ�������B������ΪBB

C = [C, gamma>=0];
C = [C, miu>=0];
%C = [C, lamda>=0];
%C = [C, pai>=0];
C = [C, BB>=0];
C = [C,BB<=1000000*B];
%C = [C, BB>=pai-10*(ones(48,1)-B)];
C = [C, pai-1000000*(1-B)<=BB,BB<=pai];
C = [C, sum(B(1:24,:))<=6];
C = [C, sum(B(25:48,:))<=12];

%L1=[ones(1,24) zeros(1,24)];
%L2=[zeros(1,24) ones(1,24)];
%C = [C, L1*B<=12];
%C = [C, L2*B<=12];

%% 4.Ŀ�꺯��

Z=-(d'*gamma+s'*lamda+(h-F*x)'*miu+u0'*B+delta_u'*BB)+6200;
% Z=-(d'*gamma+s'*lamda+(h-F*x)'*miu+u0'*pai+delta_u'*BB);
%% 5.���

ops = sdpsettings('solver','cplex');  
result = optimize(C,Z,ops);

BBB=value(B);
BBBB=value(BB);
GAMMA=value(gamma);
LAMDA=value(lamda);
MIU=value(miu);
PAI=value(pai);
UB=value(Z);

for k=1:24
    p_pv(k,1)=p_pv_forecast_0(k,1)-BBB(k,1)*delta_u(k,1);
    PL(k,1)=p_l_forecast_0(k,1)+BBB(k+24,1)*delta_u(k+24,1);
end

u=[p_pv;PL];

%% ��ͼ
% figure(6)
% plot(BBB(1:24),'r','linewidth',2)
% hold on
% plot(BBB(25:48),'b','linewidth',2)
% %hold on
% %plot(BBBB,'k','linewidth',3)

figure(6)
plot(p_pv,'k','linewidth',1)
hold on
plot(p_pv_forecast_0,'r.--','linewidth',1)
hold on
plot(p_pv_forecast_0+Dp_pv_max,'g.--','linewidth',1)
hold on
plot(p_pv_forecast_0-Dp_pv_max,'g.--','linewidth',1)
legend('���ʵ�ʳ���','���Ԥ�����','��������������','��������������');
xlabel('ʱ��/h')
ylabel('����/kw')