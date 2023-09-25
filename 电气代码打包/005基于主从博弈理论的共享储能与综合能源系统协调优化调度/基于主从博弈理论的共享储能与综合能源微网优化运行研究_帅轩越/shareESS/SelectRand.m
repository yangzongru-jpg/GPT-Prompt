function [x,SolutionLeft] = SelectRand(Solution)  %�ҳ����б�������ĸ���

[row,col] = size(Solution);                         %���������ĸ�������ά��

if row<=1                                           %��Ⱥ�ĸ���������������������С��1
    x = Solution;                                   %
    SolutionLeft = 0;                               %��Ⱥ������ʣ��
else
    tmp = rand;                                     %�漴����һ��0-1֮�����
    pos = 1+floor(row*tmp);                         %floorѰ����С����
    x = Solution(pos,:);                            %�����������λ�õ�������x��1��2��
    SolutionLeft = FindLeft(pos,Solution);          %�����������������Ⱥ��ȥ���������´β������������ͬ
    
end

return;