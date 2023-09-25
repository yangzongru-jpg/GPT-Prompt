function Vnew = mutate(x,F,MAXGEN,gen)

[row,col] = size(x);

for i=1:row    
    Solution0 = FindLeft(i,x);                   %i表示在种群中的位置，从种群中去除掉要变异的个体。
    [x1,SolutionLeft1] = SelectRand(Solution0);         %随机产生父带变异个体x1，并从种群中提出
    [x2,SolutionLeft2] = SelectRand(SolutionLeft1);     %随机产生父带变异个体x2，并从种群中提出
    [x3,SolutionLeft3] = SelectRand(SolutionLeft2);     %随机产生父带变异个体x3，并从种群中提出
   % Vnew(i,:) = x1 + F*(x2-x3);                         %利用变异公式进行变异操作
    suanzi = exp(1-MAXGEN/(MAXGEN + 1-gen));
        F = F*2.^suanzi;
     Vnew(i,:) = x1 + F*(x2-x3);
%      elseif (sum(Solution(i,1:24))>24*0.7)&&(sum(Solution(i,25:48))>24*0.45)
%             Vnew(i,:) =Solution(i,:);
%      end
end
  
return;
