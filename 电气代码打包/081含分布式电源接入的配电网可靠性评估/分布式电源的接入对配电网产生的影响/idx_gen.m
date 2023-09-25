function [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen
%IDX_GEN   Defines constants for named column indices to gen matrix.
%   [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
%   MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
%   QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
%% define the indices
GEN_BUS     = 1;    %% 节点编号
PG          = 2;    %% 有功输出
QG          = 3;    %% 无功输出
QMAX        = 4;    %% Qmax, maximum reactive power output at Pmin (MVAr)
QMIN        = 5;    %% Qmin, minimum reactive power output at Pmin (MVAr)
VG          = 6;    %% Vg, voltage magnitude setpoint (p.u.)
MBASE       = 7;    %% mBase, total MVA base of this machine, defaults to baseMVA
GEN_STATUS  = 8;    %% status, 1 - machine in service, 0 - machine out of service
PMAX        = 9;    %% Pmax, maximum real power output (MW)
PMIN        = 10;   %% Pmin, minimum real power output (MW)
PC1         = 11;   %% Pc1, lower real power output of PQ capability curve (MW)
PC2         = 12;   %% Pc2, upper real power output of PQ capability curve (MW)
QC1MIN      = 13;   %% Qc1min, minimum reactive power output at Pc1 (MVAr)
QC1MAX      = 14;   %% Qc1max, maximum reactive power output at Pc1 (MVAr)
QC2MIN      = 15;   %% Qc2min, minimum reactive power output at Pc2 (MVAr)
QC2MAX      = 16;   %% Qc2max, maximum reactive power output at Pc2 (MVAr)
RAMP_AGC    = 17;   %% ramp rate for load following/AGC (MW/min)
RAMP_10     = 18;   %% ramp rate for 10 minute reserves (MW)
RAMP_30     = 19;   %% ramp rate for 30 minute reserves (MW)
RAMP_Q      = 20;   %% ramp rate for reactive power (2 sec timescale) (MVAr/min)
APF         = 21;   %% area participation factor

%% included in opf solution, not necessarily in input
%% assume objective function has units, u
MU_PMAX     = 22;   %% Kuhn-Tucker multiplier on upper Pg limit (u/MW)
MU_PMIN     = 23;   %% Kuhn-Tucker multiplier on lower Pg limit (u/MW)
MU_QMAX     = 24;   %% Kuhn-Tucker multiplier on upper Qg limit (u/MVAr)
MU_QMIN     = 25;   %% Kuhn-Tucker multiplier on lower Qg limit (u/MVAr)