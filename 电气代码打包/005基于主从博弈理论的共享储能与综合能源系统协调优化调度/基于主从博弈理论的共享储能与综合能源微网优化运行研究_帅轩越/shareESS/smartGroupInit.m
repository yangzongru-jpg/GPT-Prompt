function population = smartGroupInit(groupSize,groupDimension)
%% ��ȡ����
shuju=xlsread('share+EtoH����.xlsx'); %��һ�컮��Ϊ24Сʱ
pe_grid_S=shuju(5,:); %�����۵��
pe_grid_B=shuju(6,:); %���������
ph_max=shuju(7,:); %�ȼ�����
ph_min=shuju(8,:); %�ȼ�����
x=zeros(groupSize,groupDimension);%ĳ����

c=rand(1,2);
while (sum(c)>=1||sum(c)<=0.4)
 c=rand(1,2);
end
 
for i=1:groupSize
    for j=1:groupDimension
        if j<25
            x(i,j)=pe_grid_B(j)+rand()*(pe_grid_S(j)-pe_grid_B(j));%�۵��
        elseif   j>24&&j<49
             x(i,j)=ph_min(j-24)+rand()*(ph_max(j-24)-ph_min(j-24));%���ȼ�                          
        end
    end
       population(i,:) = x(i,:);
end
  

    return;
                
            
            
            
            
