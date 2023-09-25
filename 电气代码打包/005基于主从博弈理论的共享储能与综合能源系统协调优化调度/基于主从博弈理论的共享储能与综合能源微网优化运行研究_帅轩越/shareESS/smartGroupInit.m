function population = smartGroupInit(groupSize,groupDimension)
%% 读取数据
shuju=xlsread('share+EtoH数据.xlsx'); %把一天划分为24小时
pe_grid_S=shuju(5,:); %电网售电价
pe_grid_B=shuju(6,:); %电网购电价
ph_max=shuju(7,:); %热价上限
ph_min=shuju(8,:); %热价下限
x=zeros(groupSize,groupDimension);%某个体

c=rand(1,2);
while (sum(c)>=1||sum(c)<=0.4)
 c=rand(1,2);
end
 
for i=1:groupSize
    for j=1:groupDimension
        if j<25
            x(i,j)=pe_grid_B(j)+rand()*(pe_grid_S(j)-pe_grid_B(j));%售电价
        elseif   j>24&&j<49
             x(i,j)=ph_min(j-24)+rand()*(ph_max(j-24)-ph_min(j-24));%售热价                          
        end
    end
       population(i,:) = x(i,:);
end
  

    return;
                
            
            
            
            
