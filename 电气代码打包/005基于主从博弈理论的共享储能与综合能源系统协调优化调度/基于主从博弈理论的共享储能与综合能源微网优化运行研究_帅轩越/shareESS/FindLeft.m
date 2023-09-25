function SolutionNew = FindLeft(pos,Solution) %将上一代的第i行去掉，满足变异操作时父带与子代不能一样。

[row,col] = size(Solution);

if( row <=1)
    SolutionNew =0;
else
    k=1;
    for i=1:row
        if(i== pos)
            continue;
        else
            SolutionNew(k,:) = Solution(i,:);
            k = k + 1;
        end
    end

end
return;