clc
clear
warning off
tic
%% ��ʼ����
%������һ�Σ��õ�UB-LB
[x,LB,y] = MP2();
[u,UB] = SP(x);
UB1 = UB;
p(1)= UB1 - LB;
%��ʼ����
for k=1:4
    [x,LB,y] = MP(u);%MP����
    [u,UB] = SP(x);%SP����
    UB = min(UB1,UB);%ȡUB��Сֵ
    p(k+1) = UB-LB;
end
 toc
 figure;
 plot(p(1:4))
 xlabel('��������')
 ylabel('UB-LB')
 title('��������')