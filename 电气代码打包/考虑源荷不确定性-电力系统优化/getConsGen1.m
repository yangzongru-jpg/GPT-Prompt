function cons = getConsGen1(PG,Pgmax,Pgmin,rud, Horizon,OnOff,On_min,Off_min)
OnOff_history=zeros(5,2);
%% 获取机组约束
cons = [];
% 1. 机组上下限约束
%cons = [cons, repmat(Pmin,1,Horizon) <=PG <= repmat(Pgmax,1,Horizon)];
% 2. 爬坡约束
cons = [cons, abs([PG(:, 2:end),PG(:, 1)] - PG)<=repmat(rud,1,Horizon)];
% 3. 机组上下限约束和最小启停时间约束
for i=1:5
for t=1:Horizon
    cons=[cons,
            OnOff(i,t)*Pgmin(i) <= PG(i,t) <= OnOff(i,t)*Pgmax(i), 

            consequtiveON([OnOff_history(i,:) OnOff(i,:)],On_min(i)),
            consequtiveON(1-[OnOff_history(i,:) OnOff(i,:)],Off_min(i))
        ];
end
end
