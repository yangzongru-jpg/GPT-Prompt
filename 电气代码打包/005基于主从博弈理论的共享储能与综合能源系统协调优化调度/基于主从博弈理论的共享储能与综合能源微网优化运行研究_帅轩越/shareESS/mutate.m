function Vnew = mutate(x,F,MAXGEN,gen)

[row,col] = size(x);

for i=1:row    
    Solution0 = FindLeft(i,x);                   %i��ʾ����Ⱥ�е�λ�ã�����Ⱥ��ȥ����Ҫ����ĸ��塣
    [x1,SolutionLeft1] = SelectRand(Solution0);         %������������������x1��������Ⱥ�����
    [x2,SolutionLeft2] = SelectRand(SolutionLeft1);     %������������������x2��������Ⱥ�����
    [x3,SolutionLeft3] = SelectRand(SolutionLeft2);     %������������������x3��������Ⱥ�����
   % Vnew(i,:) = x1 + F*(x2-x3);                         %���ñ��칫ʽ���б������
    suanzi = exp(1-MAXGEN/(MAXGEN + 1-gen));
        F = F*2.^suanzi;
     Vnew(i,:) = x1 + F*(x2-x3);
%      elseif (sum(Solution(i,1:24))>24*0.7)&&(sum(Solution(i,25:48))>24*0.45)
%             Vnew(i,:) =Solution(i,:);
%      end
end
  
return;
