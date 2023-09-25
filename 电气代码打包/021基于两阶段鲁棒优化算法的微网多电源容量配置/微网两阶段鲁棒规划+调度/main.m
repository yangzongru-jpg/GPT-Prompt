clc
clear
warning off
tic
%% 开始运行
%先运行一次，得到UB-LB
[yita,LB,ee_bat_int, p_wt_int,p_pv_int,p_g_int] = MP;
[p_wt,p_pv,p_load,x,UB] = SP(ee_bat_int,p_wt_int,p_pv_int,p_g_int,LB,yita);
UB1 = UB;
p(1)= UB - LB;
pub(1)=0;
plb(1)=0;
%开始迭代
for k=1:10
    [yita,LB,ee_bat_int,p_wt_int,p_pv_int,p_g_int] = MP2(p_wt,p_pv,p_load);%MP迭代
    [p_wt,p_pv,p_load,x,UB] = SP(ee_bat_int,p_wt_int,p_pv_int,p_g_int,LB,yita);%SP迭代
    UB = min(UB1,UB);%取UB较小值
    pub(k+1)=UB;
    plb(k+1)=LB;
    p(k+1) = UB-LB;
end
toc
%%绘图版块：主要绘制了各微网的日运行计划，容量配置结果，迭代过程等等
figure(1)
plot(x(1:24),'-*')
xlim([1 24])
grid
hold on 
plot(x(25:48),'-*')
bar(x(49:72))
plot(x(73:96),'-d')
plot(x(97:120),'-d')
title('典型日1场景下微网运行计划')
legend('购电功率','售电功率 ','燃气轮机功率','储能充电','储能放电')
xlabel('时间')
ylabel('功率')

figure(2)
plot(x(121:144),'-*')
xlim([1 24])
grid
hold on 
plot(x(145:168),'-*')
bar(x(169:192))
plot(x(193:216),'-*')
plot(x(217:240),'-*')
title('典型日2场景下微网运行计划')
legend('购电功率','售电功率 ','燃气轮机功率','储能充电','储能放电')
xlabel('时间')
ylabel('功率')

figure(3)
plot(x(241:264),'-*')
xlim([1 24])
grid
hold on 
plot(x(265:288),'-*')
bar(x(289:312))
plot(x(313:336),'-*')
plot(x(337:360),'-*')
title('典型日3场景下微网运行计划')
legend('购电功率','售电功率 ','燃气轮机功率','储能充电','储能放电')
xlabel('时间')
ylabel('功率')

figure(4)
plot(x(361:384),'-*')
xlim([1 24])
grid
hold on 
plot(x(385:408),'-*')
bar(x(409:432))
plot(x(433:456),'-*')
plot(x(457:480),'-*')
title('典型日4场景下微网运行计划')
legend('购电功率','售电功率 ','燃气轮机功率','储能充电','储能放电')
xlabel('时间')
ylabel('功率')

% figure(1)
% bar(R_31);
% set(gca,'XTickLabel',{'A','B','C'});
% for i=1:3  
%     text(i,R_31(i)+0.03,num2str(R_31(i)),'VerticalAlignment','bottom','HorizontalAlignment','center');%就是用test加数值，这个0.03看情况定，根据数值大小，再改就好了
% end
%  ylim([0,1.2]);
% ylabel('R^2');

figure(5)
bar([ee_bat_int,p_g_int,p_pv_int,p_wt_int],0.5);
set(gca,'XTickLabel',{'储能容量','燃气轮机容量','光伏容量','风机容量'});
ylim([0,620]);
ylabel('配置结果');

figure(6)
[ss,gg]=meshgrid(1:4,1:24 );
plot3(ss,gg,p_load,'-');
xlabel('微网编号');
ylabel('时刻');
zlabel('负荷值');
title('负荷调度结果图');
legend('负荷曲线1','负荷曲线2 ','负荷曲线3 ','负荷曲线4 ')

figure(7)
[ss,gg]=meshgrid(1:4,1:24 );
plot3(ss,gg,p_pv,'-');
xlabel('微网编号');
ylabel('时刻');
zlabel('光伏出力');
title('光伏调度结果图');
legend('光伏曲线1','光伏曲线2 ','光伏曲线3 ','光伏曲线4 ')

figure(8)
[ss,gg]=meshgrid(1:4,1:24 );
mesh(ss,gg,p_wt);
xlabel('微网编号');
ylabel('时刻');
zlabel('风机出力');
title('风机调度结果图');
legend('风机曲线1','风机曲线2 ','风机曲线3 ','风机曲线4 ')



figure(9)
plot(pub(1:10),'-*')
hold on
plot(plb(1:10),'-*')
xlabel('迭代次数')
ylabel('数值')
legend('上界限曲线','下界限曲线 ')
title('运行曲线')


 figure(10)
 plot(p(1:10))
 xlabel('迭代次数')
 ylabel('UB-LB')
 title('运行曲线')
 
 
 
 
 
 