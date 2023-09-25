GasCost = 0;
for t=1:n_T
%     for i=1: n_GasSource
    GasCost=GasCost+sum(GasSourceOutput(:,t).*GasSource(:,5), 1);
%     end
end 
SCUC_value = SCUC_value+GasCost;

