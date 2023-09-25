function [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus
%IDX_BUS   节点导纳阵列索引
%   [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
%   VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus 


%    节点类型
PQ      = 1;    %    1  PQ    PQ 节点
PV      = 2;    %    2  PV    PV 节点
REF     = 3;    %    3  REF   参考节点
NONE    = 4;   %     4  NONE  孤立节点

%% 定义索引
BUS_I       = 1;    %% 节点序号
BUS_TYPE    = 2;    %% 节点类型
PD          = 3;    %% 有功功率容量
QD          = 4;    %% 无功功率容量
GS          = 5;    %% 并联电导
BS          = 6;    %% 并联电纳
BUS_AREA    = 7;    %% area number, 1-100
VM          = 8;    %% Vm,电压矢量幅值
VA          = 9;    %% Va, 电压矢量相角
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
