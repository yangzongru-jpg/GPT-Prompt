function cons = getConsGen1(PG,Pgmax,Pgmin,rud, Horizon,OnOff,On_min,Off_min)
OnOff_history=zeros(5,2);
%% ��ȡ����Լ��
cons = [];
% 1. ����������Լ��
%cons = [cons, repmat(Pmin,1,Horizon) <=PG <= repmat(Pgmax,1,Horizon)];
% 2. ����Լ��
cons = [cons, abs([PG(:, 2:end),PG(:, 1)] - PG)<=repmat(rud,1,Horizon)];
% 3. ����������Լ������С��ͣʱ��Լ��
for i=1:5
for t=1:Horizon
    cons=[cons,
            OnOff(i,t)*Pgmin(i) <= PG(i,t) <= OnOff(i,t)*Pgmax(i), 

            consequtiveON([OnOff_history(i,:) OnOff(i,:)],On_min(i)),
            consequtiveON(1-[OnOff_history(i,:) OnOff(i,:)],Off_min(i))
        ];
end
end
