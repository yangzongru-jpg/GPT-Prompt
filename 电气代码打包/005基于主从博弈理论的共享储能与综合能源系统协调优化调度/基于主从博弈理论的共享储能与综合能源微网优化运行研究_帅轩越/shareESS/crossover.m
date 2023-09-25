function u = crossover(x,v,CR)

[row,col] = size(x);                 %计算种群的个体数(30)和维数(变量数2)
[rownew,colnew] = size(v);               %计算变异产生的种群的个数和维数

if row ~= rownew                       %如果变异种群个数和原种群的个数不一样
    u = 0;
    return;
end

if col ~= colnew                       %如果变异种群的维数和原种群的维数不一样
    u = 0;
    return;
end

for i=1:row                             
    tmp = rand;                     %随机产生一个0-1的数
    pos = 1+floor(col*tmp);         %随机产生维数
    Vnew = x(i,:);
    for j=1:col
        if j== pos                  %如果维数等于随机产生的整数
            Vnew(j) = v(i,j);
        end
        tmp = rand;
        if tmp <= CR                %如果随机产生的数小于变异概率发生变异操作
            Vnew(j) = v(i,j);
        end        
    end
    u(i,:) = Vnew;          %产生的交叉种群SolutionC（i，j），临时个体Vnew
    
end

 
return;