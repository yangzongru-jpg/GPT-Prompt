function [Newpopulation,fitbest,best] =  select(Unew,population,P_MT,Hload,P_buy,pe_grid_S)%ѡ�����
[r1,c1] = size(population);          %������Ⱥ�ĸ�����ά��
Newpopulation=zeros(r1,c1);
tem_fitbest=zeros(1,r1);


for i=1:r1
    xc = Unew(i,:);            %�����������Ⱥ����
    xs = population(i,:);             %ԭʼ��Ⱥ�ĸ���
    fitness1 = computefitness(xc,P_MT,Hload,P_buy,pe_grid_S);   %���㽻����Ⱥ����Ӧ�Ⱥ���
    fitness2 = computefitness(xs,P_MT,Hload,P_buy,pe_grid_S);   %����ԭʼ��Ⱥ����Ӧ�Ⱥ���

    if fitness1>fitness2 
       tem_fitbest(1,i)=fitness1;
       best=xc;
       x=xc;
    else
       tem_fitbest(1,i)=fitness2;
       best=xs;
       x=xs;
    end
 Newpopulation(i,:) = x;
end
 fitbest=max(tem_fitbest);
return;