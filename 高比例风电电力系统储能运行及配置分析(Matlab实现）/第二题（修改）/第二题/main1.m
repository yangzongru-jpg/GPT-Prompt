clc;
clear;
close all;
%% 前两个问号的解答
load X;
biaoge = xlsread('附件1');
Load = biaoge(:,2)*900;
Wind = biaoge(:,3)*300;
X(3,:) = Wind';  %风机实际出力
Un_bal = Load - sum(X)';
Qi_feng = 0;Shi_fuhe = 0;
for t = 1:96
    if Un_bal(t)<0
        Qi_feng = Qi_feng - Un_bal(t);
    else 
        Shi_fuhe = Shi_fuhe + Un_bal(t);
    end
end
% 画图表示
figure(1);
bar(X(1,:));hold on
bar(X(3,:));hold on
%plot(X(2,:),'m-','linewidth',2);hold on
bar(X(2,:));hold on
plot(Load,'r-*');
plot(X(1,:)+X(2,:)+X(3,:),'k--');
%bar(-Un_bal);

legend('一号机组','风电机组','二号机组','负荷需求','总发电功率');
xlabel('时间/15min');
ylabel('功率/MW');
title('机组日发电计划曲线');
% 
fprintf('总的弃风功率：')
disp(Qi_feng);
fprintf('总的弃负荷功率：')
disp(Shi_fuhe);

% % 画图表示
% figure(1);
% plot(X(3,:));
% hold on
% plot(X(1,:));
% plot(X(2,:));
% plot(Load);
% bar(-Un_bal);
% hold off
% legend('风电实际出力','一号机组出力','二号机组出力','负荷情况','功率不平衡量');
% xlabel('时间(15min)');
% ylabel('功率(MW)');
% title('功率不平衡情况');