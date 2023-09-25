%% 清空环境变量
clc
clear all;
%% 提取数据 
data1=xlsread('实验数据.xlsx',4);

%% 绘图
figure
H = heatmap(data1,'FontSize',12,'FontName','宋体');
set(gca,'fontsize',12)
