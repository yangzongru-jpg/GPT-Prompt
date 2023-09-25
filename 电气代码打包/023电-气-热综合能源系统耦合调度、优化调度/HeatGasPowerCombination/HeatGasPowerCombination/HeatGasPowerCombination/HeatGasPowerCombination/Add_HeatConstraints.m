HeatFlowInMatrix = zeros(n_HeatBus,n_HeatBranch);       %��������
HeatFlowInIncMatrix = zeros(n_HeatBranch,n_HeatBus);    %��������
for i=1:n_HeatBranch
    %Tobus
    HeatFlowInMatrix(HeatBranch(i,3),i) = 1*HeatBranch(i,4);
    HeatFlowInIncMatrix(i,HeatBranch(i,3)) = 1;
end
HeatFlowInBus = HeatFlowInMatrix*ones(n_HeatBranch,1);   %��������ڵ��ˮ����

HeatFlowOutMatrix = zeros(n_HeatBus,n_HeatBranch);       %��������
HeatFlowOutIncMatrix = zeros(n_HeatBranch,n_HeatBus);    %��������
for i=1:n_HeatBranch
    %Frombus
    HeatFlowOutMatrix(HeatBranch(i,2),i) = 1*HeatBranch(i,4);
    HeatFlowOutIncMatrix(i,HeatBranch(i,2)) = 1;
end
HeatFlowOutBus = HeatFlowOutMatrix*ones(n_HeatBranch,1);   %���������ڵ��ˮ����

%%
%����
%�����ڵ����ˮ�¶�=����β���Ǹýڵ��֧·β���¶Ȼ��
for t = 1: n_T
    C = [C,
        HeatFlowInBus.*TmprtrBusDir(:,t)==HeatFlowInMatrix*TmprtrToDir(:,t),
        ];
end
%�����ڵ����ˮ�¶�=��֮������֧·�׶��¶�
for t = 1: n_T
    C = [C,
        HeatFlowOutIncMatrix*TmprtrBusDir(:,t)==TmprtrFromDir(:,t),
        ];
end

%%
%����
%�������������ʱ������������������������ʱ���������
%�����ڵ����ˮ�¶�=����β���Ǹýڵ��֧·β���¶Ȼ��
for t = 1: n_T
    C = [C,
        HeatFlowOutBus.*TmprtrBusRev(:,t)==HeatFlowOutMatrix*TmprtrToRev(:,t),
        ];
end
%�����ڵ����ˮ�¶�=��֮������֧·�׶��¶�
for t = 1: n_T
    C = [C,
        HeatFlowInIncMatrix*TmprtrBusRev(:,t)==TmprtrFromRev(:,t),
        ];
end

%%
%���ڵ��ȸ���Լ��
for i = 1: n_HeatBus
    for t = 1: n_T
        if (HeatBus(i,HEATBUS_TYPE)==LOAD)
            C = [C,
                HeatD(i,t) == Cp*HeatFlowInBus(i,1)*(TmprtrBusDir(i,t)-TmprtrBusRev(i,t)),
                ];
        elseif (HeatBus(i,HEATBUS_TYPE)==SOURCE)
            C = [C,
                HeatSource(i,t) == Cp*HeatFlowOutBus(i,1)*(TmprtrBusDir(i,t)-TmprtrBusRev(i,t)),
                ];
        end
    end
end
%%
%HeatSource��chp�Լ����¯֮��Ĺ�ϵ
SourceCHPgenIncMatrix = zeros(n_HeatBus,n_CHPgen);
SourceEBoilerIncMatrix = zeros(n_HeatBus,n_EBoiler);
for i = 1: n_CHPgen
    SourceCHPgenIncMatrix(CHPgen(i,1),i) = 1;
end
for i = 1: n_EBoiler
    SourceEBoilerIncMatrix(EBoiler(i,1),i) = 1;
end
for t = 1: n_T
    C = [C,
        HeatSource(:,t) == SourceCHPgenIncMatrix*HeatCHP(:,t)+SourceEBoilerIncMatrix*HeatEBoiler(:,t),
        ];
end

%%
%chp�ȳ���
for i = 1:n_CHPgen
    [row, col] = find(gen(:,GEN_BUS)==CHPgen(i,2));
    for t = 1: n_T
        C = [C,
            HeatCHP(i,t)==2.58*gen_P(row,col)*baseMVA,
            ];
    end
end
%%
%���¯�ȳ���
for i = 1: n_EBoiler
    row = EBoiler(i,2);
    for t = 1: n_T
        C = [C,
            0.85*PowerEBoiler(i,t)*baseMVA == HeatEBoiler(i,t),
            HeatEBoiler(i,t)>=0,
            ];
    end
end
%%
%��֧·��λ�¶ȹ�ϵ
coefficient = zeros(n_HeatBranch,1);
for i = 1: n_HeatBranch
%         coefficient(i) = exp(-HeatBranch(i,8)*HeatBranch(i,5)/4200/HeatBranch(i,4)*3600);
        coefficient(i) = exp(-HeatBranch(i,8)*HeatBranch(i,5)/Cp/HeatBranch(i,4)/1000000);
end
for t = 1: n_T
    for i = 1: n_HeatBranch
        C = [C,
            HeatBus(i,5) >= TmprtrToDir(i,t) >= HeatBus(i,4),
            HeatBus(i,5) >= TmprtrFromDir(i,t) >= HeatBus(i,4),
            HeatBus(i,7) >= TmprtrToRev(i,t) >= HeatBus(i,6),
            HeatBus(i,7) >= TmprtrFromRev(i,t) >= HeatBus(i,6),
            %�������
%             TmprtrToRev(i,t) == TmprtrFromRev(i,t),
%             TmprtrToDir(i,t) == TmprtrFromDir(i,t),
            %�Ƽ����
            TmprtrToRev(i,t) == coefficient(i)*(TmprtrFromRev(i,t)-SituationTempreture(t))+SituationTempreture(t),
            TmprtrToDir(i,t) == coefficient(i)*(TmprtrFromDir(i,t)-SituationTempreture(t))+SituationTempreture(t),
            ];
    end
end

