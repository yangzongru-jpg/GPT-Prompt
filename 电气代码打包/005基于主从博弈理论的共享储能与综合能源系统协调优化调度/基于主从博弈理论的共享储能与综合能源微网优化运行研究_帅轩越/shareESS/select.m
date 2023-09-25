function [Newpopulation,fitbest,best] =  select(Unew,population,P_MT,Hload,P_buy,pe_grid_S)%选择操作
[r1,c1] = size(population);          %计算种群的个数和维数
Newpopulation=zeros(r1,c1);
tem_fitbest=zeros(1,r1);


for i=1:r1
    xc = Unew(i,:);            %交叉变异后的种群个体
    xs = population(i,:);             %原始种群的个体
    fitness1 = computefitness(xc,P_MT,Hload,P_buy,pe_grid_S);   %计算交叉种群的适应度函数
    fitness2 = computefitness(xs,P_MT,Hload,P_buy,pe_grid_S);   %计算原始种群的适应度函数

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