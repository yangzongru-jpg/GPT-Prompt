function [options, names] = mpoption(varargin)
%进行选项的选择
%输入格式为opt = mpoption(变量名1, 数值1, 变量名2, 数值2, ...)
%      ---   -------------          -------------------------------------
% 潮流选项
%       1  - PF_ALG, 1               潮流算法
%           [   1 牛顿法    2 快速解耦法 (XB 变换)   3 快速解耦法 (BX变换)  4高斯赛德尔法 ]
%       2  - PF_TOL, 1e-8           每一个单元（节点）的有功－无功最大的允许偏差。
%       3  - PF_MAX_IT, 10          牛顿法的最大迭代次数
%       4 - VERBOSE, 1             打印进程信息的数量
%           [   0.不打印进程信息 1.打印一点进程信息  2.打印大量的进程信息 3.打印所有的进程信息]
%       5 - OUT_ALL, -1            结果的打印控制
%           [ 1.用分散的标志来控制哪些需要输出  0.什么也不打印  1.全部打印 ]

i = 1;
if rem(nargin, 2)       %% odd number of arguments
    options = varargin{1};  %% base options vector passed in
    i = 2;                  %% start processing parameters with 2nd one
else                    %% even number of parameters
    options = [             %% use defaults for base options vector
    
        %% power flow options
        1;      %% 1  - PF_ALG
        1e-8;   %% 2  - PF_TOL
        10;     %% 3  - PF_MAX_IT
        30;     %% 4  - PF_MAX_IT_FD
        1000;   %% 5  - PF_MAX_IT_GS
        0;      %% 6  - ENFORCE_Q_LIMS
        0;      %% 7  - RESERVED7
        0;      %% 8  - RESERVED8
        0;      %% 9  - RESERVED9
        0;      %% 10 - PF_DC
        
        %% OPF options
        0;      %% 11 - OPF_ALG
        100;    %% 12 - OPF_ALG_POLY, deprecated
        200;    %% 13 - OPF_ALG_PWL, deprecated
        10;     %% 14 - OPF_POLY2PWL_PTS, deprecated
        0;      %% 15 - OPF_NEQ, not a user option (number of eq constraints for
                %%          copf, lpopf and dcopf algorithms, set by program)
        5e-6;   %% 16 - OPF_VIOLATION
        1e-4;   %% 17 - CONSTR_TOL_X
        1e-4;   %% 18 - CONSTR_TOL_F
        0;      %% 19 - CONSTR_MAX_IT
        3e-3;   %% 20 - LPC_TOL_GRAD
        1e-4;   %% 21 - LPC_TOL_X
        400;    %% 22 - LPC_MAX_IT
        5;      %% 23 - LPC_MAX_RESTART
        0;      %% 24 - OPF_FLOW_LIM
        0;      %% 25 - OPF_IGNORE_ANG_LIM
        0;      %% 26 - OPF_ALG_DC
        0;      %% 27 - RESERVED27
        0;      %% 28 - RESERVED28
        0;      %% 29 - RESERVED29
        0;      %% 30 - RESERVED30
        
        %% output options
        1;      %% 31 - VERBOSE
        -1;     %% 32 - OUT_ALL
        1;      %% 33 - OUT_SYS_SUM
        0;      %% 34 - OUT_AREA_SUM
        1;      %% 35 - OUT_BUS
        1;      %% 36 - OUT_BRANCH
        0;      %% 37 - OUT_GEN
        -1;     %% 38 - OUT_ALL_LIM
        1;      %% 39 - OUT_V_LIM
        1;      %% 40 - OUT_LINE_LIM
        1;      %% 41 - OUT_PG_LIM
        1;      %% 42 - OUT_QG_LIM
        0;      %% 43 - OUT_RAW
        0;      %% 44 - RESERVED44
        0;      %% 45 - RESERVED45
        0;      %% 46 - RESERVED46
        0;      %% 47 - RESERVED47
        0;      %% 48 - RESERVED48
        0;      %% 49 - RESERVED49
        0;      %% 50 - RESERVED50
        
        %% other options
        1;      %% 51 - SPARSE_QP
        0;      %% 52 - RESERVED52
        0;      %% 53 - RESERVED53
        0;      %% 54 - RESERVED54
        1;      %% 55 - FMC_ALG
        0;      %% 56 - RESERVED56
        0;      %% 57 - RESERVED57
        0;      %% 58 - RESERVED58
        0;      %% 59 - RESERVED59
        0;      %% 60 - RESERVED60
        
        %% other options
        0;      %% 61 - MNS_FEASTOL
        0;      %% 62 - MNS_ROWTOL
        0;      %% 63 - MNS_XTOL
        0;      %% 64 - MNS_MAJDAMP
        0;      %% 65 - MNS_MINDAMP
        0;      %% 66 - MNS_PENALTY_PARM
        0;      %% 67 - MNS_MAJOR_IT
        0;      %% 68 - MNS_MINOR_IT
        0;      %% 69 - MNS_MAX_IT
        -1;     %% 70 - MNS_VERBOSITY
        0;      %% 71 - MNS_CORE
        0;      %% 72 - MNS_SUPBASIC_LIM
        0;      %% 73 - MNS_MULT_PRICE
        0;      %% 74 - RESERVED74
        0;      %% 75 - RESERVED75
        0;      %% 76 - RESERVED76
        0;      %% 77 - RESERVED77
        0;      %% 78 - RESERVED78
        0;      %% 79 - RESERVED79
        0;      %% 80 - FORCE_PC_EQ_P0, for c3sopf
        
        %% PDIPM options
        0;      %% 81 - PDIPM_FEASTOL
        1e-6;   %% 82 - PDIPM_GRADTOL
        1e-6;   %% 83 - PDIPM_COMPTOL
        1e-6;   %% 84 - PDIPM_COSTTOL
        150;    %% 85 - PDIPM_MAX_IT
        20;     %% 86 - SCPDIPM_RED_IT
        0;      %% 87 - TRALM_FEASTOL
        5e-4;   %% 88 - TRALM_PRIMETOL
        5e-4;   %% 89 - TRALM_DUALTOL
        1e-5;   %% 90 - TRALM_COSTTOL
        40;     %% 91 - TRALM_MAJOR_IT
        100;    %% 92 - TRALM_MINOR_IT
        0.04;   %% 93 - SMOOTHING_RATIO        
    ];
end

%%-----  set up option names  -----
%% power flow options
names = str2mat(    'PF_ALG', ...               %% 1
                    'PF_TOL', ...               %% 2
                    'PF_MAX_IT', ...            %% 3
                    'PF_MAX_IT_FD', ...         %% 4
                    'PF_MAX_IT_GS', ...         %% 5
                    'ENFORCE_Q_LIMS', ...       %% 6
                    'RESERVED7', ...            %% 7
                    'RESERVED8', ...            %% 8
                    'RESERVED9', ...            %% 9
                    'PF_DC' );                  %% 10

%% OPF options
names = str2mat(    names, ...
                    'OPF_ALG', ...              %% 11
                    'OPF_ALG_POLY', ...         %% 12
                    'OPF_ALG_PWL', ...          %% 13
                    'OPF_POLY2PWL_PTS', ...     %% 14
                    'OPF_NEQ', ...              %% 15
                    'OPF_VIOLATION', ...        %% 16
                    'CONSTR_TOL_X', ...         %% 17
                    'CONSTR_TOL_F', ...         %% 18
                    'CONSTR_MAX_IT', ...        %% 19
                    'LPC_TOL_GRAD'  );          %% 20
names = str2mat(    names, ...
                    'LPC_TOL_X', ...            %% 21
                    'LPC_MAX_IT', ...           %% 22
                    'LPC_MAX_RESTART', ...      %% 23
                    'OPF_FLOW_LIM', ...         %% 24
                    'OPF_IGNORE_ANG_LIM', ...   %% 25
                    'OPF_ALG_DC', ...           %% 26
                    'RESERVED27', ...           %% 27
                    'RESERVED28', ...           %% 28
                    'RESERVED29', ...           %% 29
                    'RESERVED30'    );          %% 30

%% output options
names = str2mat(    names, ...
                    'VERBOSE', ...              %% 31
                    'OUT_ALL', ...              %% 32
                    'OUT_SYS_SUM', ...          %% 33
                    'OUT_AREA_SUM', ...         %% 34
                    'OUT_BUS', ...              %% 35
                    'OUT_BRANCH', ...           %% 36
                    'OUT_GEN', ...              %% 37
                    'OUT_ALL_LIM', ...          %% 38
                    'OUT_V_LIM', ...            %% 39
                    'OUT_LINE_LIM'  );          %% 40
names = str2mat(    names, ...
                    'OUT_PG_LIM', ...           %% 41
                    'OUT_QG_LIM', ...           %% 42
                    'OUT_RAW', ...              %% 43
                    'RESERVED44', ...           %% 44
                    'RESERVED45', ...           %% 45
                    'RESERVED46', ...           %% 46
                    'RESERVED47', ...           %% 47
                    'RESERVED48', ...           %% 48
                    'RESERVED49', ...           %% 49
                    'RESERVED50'    );          %% 50
%% other options
names = str2mat(    names, ...
                    'SPARSE_QP', ...            %% 51
                    'RESERVED52', ...           %% 52
                    'RESERVED53', ...           %% 53
                    'RESERVED54', ...           %% 54
                    'FMC_ALG', ...              %% 55
                    'RESERVED56', ...           %% 56
                    'RESERVED57', ...           %% 57
                    'RESERVED58', ...           %% 58
                    'RESERVED59', ...           %% 59
                    'RESERVED60'    );          %% 60
%% MINOS options
names = str2mat(    names, ...
                    'MNS_FEASTOL', ...          %% 61
                    'MNS_ROWTOL', ...           %% 62
                    'MNS_XTOL', ...             %% 63
                    'MNS_MAJDAMP', ...          %% 64
                    'MNS_MINDAMP', ...          %% 65
                    'MNS_PENALTY_PARM', ...     %% 66
                    'MNS_MAJOR_IT', ...         %% 67
                    'MNS_MINOR_IT', ...         %% 68
                    'MNS_MAX_IT', ...           %% 69
                    'MNS_VERBOSITY' );          %% 70
%% other flags
names = str2mat(    names, ...
                    'MNS_CORE', ...             %% 71
                    'MNS_SUPBASIC_LIM', ...     %% 72
                    'MNS_MULT_PRICE', ...       %% 73
                    'RESERVED74', ...           %% 74
                    'RESERVED75', ...           %% 75
                    'RESERVED76', ...           %% 76
                    'RESERVED77', ...           %% 77
                    'RESERVED78', ...           %% 78
                    'RESERVED79', ...           %% 79
                    'FORCE_PC_EQ_P0'    );      %% 80

%% PDIPM, SC-PDIPM, and TRALM options                
names = str2mat(    names, ...
                    'PDIPM_FEASTOL', ...        %% 81
                    'PDIPM_GRADTOL', ...        %% 82
                    'PDIPM_COMPTOL', ...        %% 83
                    'PDIPM_COSTTOL', ...        %% 84
                    'PDIPM_MAX_IT', ...         %% 85
                    'SCPDIPM_RED_IT', ...       %% 86
                    'TRALM_FEASTOL', ...        %% 87
                    'TRALM_PRIMETOL', ...       %% 88
                    'TRALM_DUALTOL', ...        %% 89
                    'TRALM_COSTTOL', ...        %% 90
                    'TRALM_MAJOR_IT', ...       %% 91
                    'TRALM_MINOR_IT', ...       %% 92
                    'SMOOTHING_RATIO'    );     %% 93
                
%%-----  process parameters  -----
while i <= nargin
    %% get parameter name and value
    pname = varargin{i};
    pval  = varargin{i+1};
    
    %% get parameter index
    namestr = names';
    namestr = namestr(:)';
    namelen = size(names, 2);
    pidx = ceil(findstr([pname blanks(namelen-length(pname))], namestr) / namelen);
    if isempty(pidx)
        error('"%s" is not a valid named option', pname);
    end
    % fprintf('''%s'' (%d) = %d\n', pname, pidx, pval);

    %% update option
    options(pidx) = pval;

    i = i + 2;                              %% go to next parameter
end