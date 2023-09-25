function [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus
%IDX_BUS   �ڵ㵼����������
%   [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
%   VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus 


%    �ڵ�����
PQ      = 1;    %    1  PQ    PQ �ڵ�
PV      = 2;    %    2  PV    PV �ڵ�
REF     = 3;    %    3  REF   �ο��ڵ�
NONE    = 4;   %     4  NONE  �����ڵ�

%% ��������
BUS_I       = 1;    %% �ڵ����
BUS_TYPE    = 2;    %% �ڵ�����
PD          = 3;    %% �й���������
QD          = 4;    %% �޹���������
GS          = 5;    %% �����絼
BS          = 6;    %% ��������
BUS_AREA    = 7;    %% area number, 1-100
VM          = 8;    %% Vm,��ѹʸ����ֵ
VA          = 9;    %% Va, ��ѹʸ�����
BASE_KV     = 10;   %% baseKV, base voltage (kV)
ZONE        = 11;   %% zone, loss zone (1-999)
VMAX        = 12;   %% maxVm, maximum voltage magnitude (p.u.)      (not in PTI format)
VMIN        = 13;   %% minVm, minimum voltage magnitude (p.u.)      (not in PTI format)

%% included in opf solution, not necessarily in input
%% assume objective function has units, u
LAM_P       = 14;   %% Lagrange multiplier on real power mismatch (u/MW)
LAM_Q       = 15;   %% Lagrange multiplier on reactive power mismatch (u/MVAr)
MU_VMAX     = 16;   %% Kuhn-Tucker multiplier on upper voltage limit (u/p.u.)
MU_VMIN     = 17;   %% Kuhn-Tucker multiplier on lower voltage limit (u/p.u.)
