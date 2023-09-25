function u = crossover(x,v,CR)

[row,col] = size(x);                 %������Ⱥ�ĸ�����(30)��ά��(������2)
[rownew,colnew] = size(v);               %��������������Ⱥ�ĸ�����ά��

if row ~= rownew                       %���������Ⱥ������ԭ��Ⱥ�ĸ�����һ��
    u = 0;
    return;
end

if col ~= colnew                       %���������Ⱥ��ά����ԭ��Ⱥ��ά����һ��
    u = 0;
    return;
end

for i=1:row                             
    tmp = rand;                     %�������һ��0-1����
    pos = 1+floor(col*tmp);         %�������ά��
    Vnew = x(i,:);
    for j=1:col
        if j== pos                  %���ά�������������������
            Vnew(j) = v(i,j);
        end
        tmp = rand;
        if tmp <= CR                %��������������С�ڱ�����ʷ����������
            Vnew(j) = v(i,j);
        end        
    end
    u(i,:) = Vnew;          %�����Ľ�����ȺSolutionC��i��j������ʱ����Vnew
    
end

 
return;