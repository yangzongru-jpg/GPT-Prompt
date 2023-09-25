function [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
    RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch
%IDX_BRCH   ��branch�������������塢
%   [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
%   TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
%   ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch
F_BUS       = 1;    %% ��ʼ�ڵ����
T_BUS       = 2;    %%��ֹ�ڵ����
BR_R        = 3;    %% ����
BR_X        = 4;    %% �翹
BR_B        = 5;    %% ����
RATE_A      = 6;    %% rateA, MVA rating A (long term rating)
RATE_B      = 7;    %% rateB, MVA rating B (short term rating)
RATE_C      = 8;    %% rateC, MVA rating C (emergency rating)
TAP         = 9;    %% ratio, transformer off nominal turns ratio
SHIFT       = 10;   %% angle, transformer phase shift angle (degrees)
BR_STATUS   = 11;   %% initial branch status, 1 - in service, 0 - out of service
ANGMIN      = 12;   %% minimum angle difference, angle(Vf) - angle(Vt) (degrees)
ANGMAX      = 13;   %% maximum angle difference, angle(Vf) - angle(Vt) (degrees)


PF          = 14;   %%��ʼ�ڵ���й�����    
QF          = 15;   %% ��ʼ�ڵ���޹�����
PT          = 16;   %% ����ڵ���й�����     
QT          = 17;   %% ����ڵ���޹�����

%% included in opf solution, not necessarily in input
%% assume objective function has units, u
MU_SF       = 18;   %% Kuhn-Tucker multiplier on MVA limit at "from" bus (u/MVA)
MU_ST       = 19;   %% Kuhn-Tucker multiplier on MVA limit at "to" bus (u/MVA)
MU_ANGMIN   = 20;   %% Kuhn-Tucker multiplier lower angle difference limit (u/degree)
MU_ANGMAX   = 21;   %% Kuhn-Tucker multiplier upper angle difference limit (u/degree)