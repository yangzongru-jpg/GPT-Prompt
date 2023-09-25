GasBranchIncMatrix = zeros(n_GasBus, n_GasBranch);
for i = 1: n_GasBranch
    GasBranchIncMatrix(GasBranch(i,2),i) = 1;
    GasBranchIncMatrix(GasBranch(i,3),i) = -1;
end

GasSourceIncMatrix = zeros(n_GasBus, n_GasSource);
for i = 1: n_GasSource
    GasSourceIncMatrix(GasSource(i,2),i) = 1;
end

GasGenIncMatrix = zeros(n_GasBus, n_GasGen);
for i = 1: n_GasGen
    GasGenIncMatrix(GasGen(i,1),i) = 1;
end

%%
%��Ȼ��ƽ��
for t = 1: n_T
    C = [C,
        GasSourceIncMatrix*GasSourceOutput(:,t) == GasBranchIncMatrix*GasFlow(:,t)+GasGenIncMatrix*GasGenNeed(:,t)+GasD(:,t),
        ];
end
%%
%����Ȼ��Դ��������
for i = 1: n_GasSource
    C = [C,
        GasSource(i,3)<=GasSourceOutput(i,:)<=GasSource(i,4),
        ];
end

%%
% %���ܵ���������
% for i = 1: n_GasBranch
%     C = [C,
%         GasFlow<=GasBranch()
%         ];
% end
%%
%��Ȼ���������
for i = 1: n_gen
     if (gen(i,GEN_TYPE)==TIANRANQI)
         [GasGenIndex, ~] = find(GasGen(:,2)==gen(i,GEN_BUS));
         C = [C,
             GasGenNeed(GasGenIndex,:) == gen_P(i,:)*baseMVA/0.35/QLHV,
             ];
     end
end

%%
%������ѹ���������ϵ
Add_PressureStairwise;




