%% ��ջ�������
clc
clear all;
%% ��ȡ���� 
data1=xlsread('ʵ������.xlsx',4);

%% ��ͼ
figure
H = heatmap(data1,'FontSize',12,'FontName','����');
set(gca,'fontsize',12)
