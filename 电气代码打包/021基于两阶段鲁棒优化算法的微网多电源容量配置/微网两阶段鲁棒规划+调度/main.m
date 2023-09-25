clc
clear
warning off
tic
%% ��ʼ����
%������һ�Σ��õ�UB-LB
[yita,LB,ee_bat_int, p_wt_int,p_pv_int,p_g_int] = MP;
[p_wt,p_pv,p_load,x,UB] = SP(ee_bat_int,p_wt_int,p_pv_int,p_g_int,LB,yita);
UB1 = UB;
p(1)= UB - LB;
pub(1)=0;
plb(1)=0;
%��ʼ����
for k=1:10
    [yita,LB,ee_bat_int,p_wt_int,p_pv_int,p_g_int] = MP2(p_wt,p_pv,p_load);%MP����
    [p_wt,p_pv,p_load,x,UB] = SP(ee_bat_int,p_wt_int,p_pv_int,p_g_int,LB,yita);%SP����
    UB = min(UB1,UB);%ȡUB��Сֵ
    pub(k+1)=UB;
    plb(k+1)=LB;
    p(k+1) = UB-LB;
end
toc
%%��ͼ��飺��Ҫ�����˸�΢���������мƻ����������ý�����������̵ȵ�
figure(1)
plot(x(1:24),'-*')
xlim([1 24])
grid
hold on 
plot(x(25:48),'-*')
bar(x(49:72))
plot(x(73:96),'-d')
plot(x(97:120),'-d')
title('������1������΢�����мƻ�')
legend('���繦��','�۵繦�� ','ȼ���ֻ�����','���ܳ��','���ܷŵ�')
xlabel('ʱ��')
ylabel('����')

figure(2)
plot(x(121:144),'-*')
xlim([1 24])
grid
hold on 
plot(x(145:168),'-*')
bar(x(169:192))
plot(x(193:216),'-*')
plot(x(217:240),'-*')
title('������2������΢�����мƻ�')
legend('���繦��','�۵繦�� ','ȼ���ֻ�����','���ܳ��','���ܷŵ�')
xlabel('ʱ��')
ylabel('����')

figure(3)
plot(x(241:264),'-*')
xlim([1 24])
grid
hold on 
plot(x(265:288),'-*')
bar(x(289:312))
plot(x(313:336),'-*')
plot(x(337:360),'-*')
title('������3������΢�����мƻ�')
legend('���繦��','�۵繦�� ','ȼ���ֻ�����','���ܳ��','���ܷŵ�')
xlabel('ʱ��')
ylabel('����')

figure(4)
plot(x(361:384),'-*')
xlim([1 24])
grid
hold on 
plot(x(385:408),'-*')
bar(x(409:432))
plot(x(433:456),'-*')
plot(x(457:480),'-*')
title('������4������΢�����мƻ�')
legend('���繦��','�۵繦�� ','ȼ���ֻ�����','���ܳ��','���ܷŵ�')
xlabel('ʱ��')
ylabel('����')

% figure(1)
% bar(R_31);
% set(gca,'XTickLabel',{'A','B','C'});
% for i=1:3  
%     text(i,R_31(i)+0.03,num2str(R_31(i)),'VerticalAlignment','bottom','HorizontalAlignment','center');%������test����ֵ�����0.03���������������ֵ��С���ٸľͺ���
% end
%  ylim([0,1.2]);
% ylabel('R^2');

figure(5)
bar([ee_bat_int,p_g_int,p_pv_int,p_wt_int],0.5);
set(gca,'XTickLabel',{'��������','ȼ���ֻ�����','�������','�������'});
ylim([0,620]);
ylabel('���ý��');

figure(6)
[ss,gg]=meshgrid(1:4,1:24 );
plot3(ss,gg,p_load,'-');
xlabel('΢�����');
ylabel('ʱ��');
zlabel('����ֵ');
title('���ɵ��Ƚ��ͼ');
legend('��������1','��������2 ','��������3 ','��������4 ')

figure(7)
[ss,gg]=meshgrid(1:4,1:24 );
plot3(ss,gg,p_pv,'-');
xlabel('΢�����');
ylabel('ʱ��');
zlabel('�������');
title('������Ƚ��ͼ');
legend('�������1','�������2 ','�������3 ','�������4 ')

figure(8)
[ss,gg]=meshgrid(1:4,1:24 );
mesh(ss,gg,p_wt);
xlabel('΢�����');
ylabel('ʱ��');
zlabel('�������');
title('������Ƚ��ͼ');
legend('�������1','�������2 ','�������3 ','�������4 ')



figure(9)
plot(pub(1:10),'-*')
hold on
plot(plb(1:10),'-*')
xlabel('��������')
ylabel('��ֵ')
legend('�Ͻ�������','�½������� ')
title('��������')


 figure(10)
 plot(p(1:10))
 xlabel('��������')
 ylabel('UB-LB')
 title('��������')
 
 
 
 
 
 