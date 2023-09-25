clc;
clear;
close all;
clear all class;

profile on

addpath('./example');
addpath('./functions');
addpath('./HeatGasPowerCombination');

%%
% ����
% casename = input('Please enter case name : ', 's');
% casename = 'case14mod_SCUC_parallel';
casename = 'HeatGasPowerSystem';
% casename = 'IEEE118_new';

% ��ȫϵ����������һ����ԣ�ȣ���Գ�����ȫԼ��
k_safe = 0.95;         

% ��ʼ���ļ�
initial;

%%
%���ɾ������
% [Ybus, Yf, Yt] = makeYbus(baseMVA, bus, M_branch);   % build admitance matrix
[Bbus, Bf, Pbusinj, Pfinj] = makeBdc(baseMVA, bus, branch);       %ֱ������
%%
% �������߱���
%%
% ����
% ��緢������� 
gen_P = sdpvar(n_gen, n_T);
gen_P_upper = sdpvar(n_gen, n_T);

% ������״̬
u_state = binvar(n_gen, n_T);    

% ����ϵͳ��֧·����
PF_D  = sdpvar(n_branch, n_T);
% ����ϵͳ���ڵ����
Va = sdpvar(n_bus,n_T);
%%
% ����
GasFlow = sdpvar(n_GasBranch, n_T);         %���ܵ�������
GasPressure2 = sdpvar(n_GasBus, n_T);       %���ڵ���ѹƽ��
GasSourceOutput = sdpvar(n_GasSource, n_T); %����Ȼ��Դ�ڵ����
GasGenNeed = sdpvar(n_GasGen, n_T);         %����Ȼ�����������

%%
% ����
TmprtrFromDir = sdpvar(n_HeatBranch, n_T);  %������֧·ͷ����¶�
TmprtrToDir = sdpvar(n_HeatBranch, n_T);    %������֧·β����¶�
TmprtrFromRev = sdpvar(n_HeatBranch, n_T);  %�淽��֧·ͷ����¶�
TmprtrToRev = sdpvar(n_HeatBranch, n_T);    %�淽��֧·β����¶�

TmprtrBusDir = sdpvar(n_HeatBus,n_T);       %������ϵͳ���ڵ���ˮ���¶�
TmprtrBusRev = sdpvar(n_HeatBus,n_T);       %�淽��ϵͳ���ڵ���ˮ���¶�

HeatSource = sdpvar(n_HeatBus, n_T);        %��Դ���ȣ���Ϊ��¯��CHP����ͬһ���ڵ��д����ô����
HeatCHP = sdpvar(n_CHPgen,n_T);             %chp�����ȳ���
HeatEBoiler = sdpvar(n_EBoiler,n_T);        %���¯�ȳ���
PowerEBoiler = sdpvar(n_EBoiler,n_T);       %���¯�ĵ�

C = [];     %Լ��
% C = sdpvar(C)>=0;
SCUC_value = 0;

%%
%���Լ��
%%
%�����鿪������
% Add_Huodian_Startup;
%%
%����ƽ��
% Add_PowerBalance;
Add_PowerFlow;
%%
%����Լ��
Add_Ramp;
%%
%��С��ͣʱ������
Add_MinUpDownTime;
%%
%���������
Add_Huodian_UnitOutput;

%%
%��Ȼ����Լ��
Add_GasConstraints;
%%
%����Լ��
Add_HeatConstraints;
%%
%�����η��ú���
Add_Huodian_GenCost;
%%
%��Ȼ������
Add_Gas_Cost;
%%     
%���� 
ops = sdpsettings('solver','cplex','verbose',2,'usex0',0);      
ops.gurobi.MIPGap = 1e-6;
ops.cplex.mip.tolerances.mipgap = 1e-6;

profile viewer

%%
%���         
result = optimize(C, SCUC_value, ops);

if result.problem == 0 % problem =0 �������ɹ�   
else
    error('������');
end  
% plot([1: n_T], [sum(value(gen_P(:,:)))]);
plot([1: n_T], [value(gen_P(:,:))]);        %���������
%%
%һЩֵ�Ļ�ȡ
gen_P = value(gen_P(:,:));
gen_P_upper = value(gen_P_upper);
PF_D = value(PF_D);
u_state = value(u_state(:,:));
gen_P_nl = value(gen_P_nl);
Va = value(Va);
obj_value = value(SCUC_value);
GasFlow = value(GasFlow);
GasPressure = sqrt(value(GasPressure2));
GasPressure2 = value(GasPressure2);
GasSourceOutput=value(GasSourceOutput);
GasGenNeed = value(GasGenNeed);

PowerEBoiler = value(PowerEBoiler);
TmprtrFromDir = value(TmprtrFromDir);  
TmprtrToDir = value(TmprtrToDir);    
TmprtrFromRev = value(TmprtrFromRev);  
TmprtrToRev = value(TmprtrToRev);    
TmprtrBusDir = value(TmprtrBusDir);       
TmprtrBusRev = value(TmprtrBusRev);       
HeatSource = value(HeatSource); 
HeatCHP = value(HeatCHP);             
HeatEBoiler = value(HeatEBoiler);     
GasCost = value(GasCost);
GasFlow2 = value(GasFlow2);
GasFlow2_nl = value(GasFlow2_nl);
GasFlowSymbol = value(GasFlowSymbol);
%����
% MPC = mpc;
% MPC.gen(:, GEN_PG) = gen_P(: ,1)*baseMVA;
% MPC.bus(:, BUS_PD) = PD(:, 1)*baseMVA;
% test_result = rundcpf(MPC);
