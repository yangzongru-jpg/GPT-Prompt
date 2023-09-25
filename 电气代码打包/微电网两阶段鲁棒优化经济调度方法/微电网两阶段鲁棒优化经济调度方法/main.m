clc
clear
warning off
tic
%% 开始运行
%先运行一次，得到UB-LB
[x,LB,y] = MP2();
[u,UB] = SP(x);
UB1 = UB;
p(1)= UB1 - LB;
%开始迭代
for k=1:4
    [x,LB,y] = MP(u);%MP迭代
    [u,UB] = SP(x);%SP迭代
    UB = min(UB1,UB);%取UB较小值
    p(k+1) = UB-LB;
end
 toc
 figure;
 plot(p(1:4))
 xlabel('迭代次数')
 ylabel('UB-LB')
 title('运行曲线')