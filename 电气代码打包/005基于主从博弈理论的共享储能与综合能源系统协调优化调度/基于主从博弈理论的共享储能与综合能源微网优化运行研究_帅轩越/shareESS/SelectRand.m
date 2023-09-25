function [x,SolutionLeft] = SelectRand(Solution)  %找出进行变异操作的父带

[row,col] = size(Solution);                         %计算样本的个体数和维数

if row<=1                                           %种群的个体数等于行数，个体数小于1
    x = Solution;                                   %
    SolutionLeft = 0;                               %种群个体数剩余
else
    tmp = rand;                                     %随即产生一个0-1之间的数
    pos = 1+floor(row*tmp);                         %floor寻找最小整数
    x = Solution(pos,:);                            %将随机产生的位置的数赋予x（1，2）
    SolutionLeft = FindLeft(pos,Solution);          %将随机产生的数从种群中去掉，避免下次产生的随机数相同
    
end

return;