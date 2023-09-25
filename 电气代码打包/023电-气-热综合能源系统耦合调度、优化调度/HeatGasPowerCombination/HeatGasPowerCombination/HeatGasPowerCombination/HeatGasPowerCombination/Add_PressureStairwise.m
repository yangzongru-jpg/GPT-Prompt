
%��������ѹ�������ķֶκ���
GasFlow2 = sdpvar(n_GasBranch,n_T);         %GasFlow��ƽ��
GasFlowSymbol = binvar(n_GasBranch,n_T,2);    %��־����Ķ����Ʊ���
n_L_w2 = 20;   %w2����ƽ���ķֶκ��� 100̫����
state_GasFlow2_nl = binvar(n_GasBranch,n_T,n_L_w2);
GasFlow2_nl = sdpvar(n_GasBranch,n_T,n_L_w2);
GasFlow2Max = zeros(n_GasBranch,1);
Cij=GasBranch(:,4);
for i = 1: n_GasBranch
    f_bus = GasBranch(i,2);
    t_bus = GasBranch(i,3);
    GasFlow2Max(i) = max(Cij(i)^2*abs(GasBus(f_bus,2)^2-GasBus(t_bus,3)^2), Cij(i)^2*abs(GasBus(f_bus,3)^2-GasBus(t_bus,2)^2));
    GasFlow2Max(i) = min(GasFlow2Max(i),4);     %��������Ͻ�̫�����ˣ���Χ��׼û������
end
%һЩ��Ҫ�Ĳ���
GasFlow2_interval = zeros(n_GasBranch, n_L_w2+1);           %ÿ���������½�
GasFlow2_low = zeros(n_GasBranch, n_L_w2);                  %ÿ��������˵�ĺ���ֵ 
for i = 1: n_GasBranch
    GasFlow2_interval(i, :) = 0: GasFlow2Max(i)/n_L_w2: GasFlow2Max(i);   %�Ѿ���ʵ��ֵ��
    for l = 1: n_L_w2
        GasFlow2_low(i,l) = sqrt(GasFlow2_interval(i,l));
    end
end
%����б��
Fij_GasFlow2 = zeros(n_GasBranch, n_L_w2);
for i = 1: n_GasBranch
    for l = 1: n_L_w2
        Fij_GasFlow2(i, l) = (sqrt(GasFlow2_interval(i,l+1))-sqrt(GasFlow2_interval(i,l)))/(GasFlow2_interval(i,l+1)-GasFlow2_interval(i,l));
    end
end

%%
%GasFlow2�ֶ�
% for i = 1: n_GasBranch
for t = 1:n_T
    C = [C,
        sum(GasFlow2_nl(:,t,:), 3)==GasFlow2(:,t),
        sum(state_GasFlow2_nl(:,t,:), 3)==1,
        -sqrt(GasFlow2Max(:))<=GasFlow(:,t)<=sqrt(GasFlow2Max(:)),
        ];
    l = 1: n_L_w2;
%     for l = 1: n_L_w2
    C = [C,
        state_GasFlow2_nl(:,t,l).*GasFlow2_interval(:,l)<= GasFlow2_nl(:,t,l), 
        GasFlow2_nl(:,t,l) <= state_GasFlow2_nl(:,t,l).*GasFlow2_interval(:,l+1),
        0 <= GasFlow2_nl(:,t,l) <= GasFlow2_interval(:,l+1)
        ];
%     end
end
% end

for t = 1: n_T
    for i = 1: n_GasBranch
        GasFlow_temp = 0;
        l = 1: n_L_w2; 
    %     for l = 1: n_L_w2
        GasFlow_temp = GasFlow_temp+...
                    sum(state_GasFlow2_nl(i,t,l).*GasFlow2_low(i,l)+(GasFlow2_nl(i,t,l)-state_GasFlow2_nl(i,t,l).*GasFlow2_interval(i,l)).*Fij_GasFlow2(i, l), 3);
    %     end
    %         C = [C,
    %             abs(GasFlow(i,t)) == GasFlow_temp,
    %             ];
        %��������
        f_bus = GasBranch(i,2);
        t_bus = GasBranch(i,3);
        C = [C,
            GasFlowSymbol(i,t,1)+GasFlowSymbol(i,t,2)==1,
            implies(GasFlowSymbol(i,t,1),[GasPressure2(f_bus,t)>=GasPressure2(t_bus,t),GasFlow(i,t)==GasFlow_temp]),
            implies(GasFlowSymbol(i,t,2),[GasPressure2(f_bus,t)<=GasPressure2(t_bus,t),GasFlow(i,t)==-GasFlow_temp]),
            ];
    end
end

%%
%wij = Cij*������(fai-fai)
for i = 1: n_GasBranch
    f_bus = GasBranch(i,2);
    t_bus = GasBranch(i,3);
%     for t = 1: n_T
    C = [C,
        GasFlow2(i,:) == Cij(i)^2*abs(GasPressure2(f_bus,:)-GasPressure2(t_bus,:)),
        ];
%     end
end

%%
%�ڵ���ѹ����
% for i = 1: n_GasBus
for t = 1: n_T
    C = [C,
        GasBus(:,3).^2<=GasPressure2(:,t)<=GasBus(:,2).^2
        ];
end
% end





