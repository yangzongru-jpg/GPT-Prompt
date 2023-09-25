%% 清空环境变量
clc
clear all;

%% 提取数据
data=xlsread('实验数据.xlsx',1);

%% 
wind_power_pre=[];
wind_power_reall=[];
for i=1:10
    wind_power_pre(i,:)=data(1+(i-1)*96:96*i,1);
    wind_power_reall(i,:)=data(1+(i-1)*96:96*i,2);
end
mean_value=mean(wind_power_pre(1,:));
std_value=std(wind_power_pre(1,:));
power_up=[];
power_in=[];
for i=1:96
    power_up(i)=wind_power_pre(1,i)-1.96*std_value;%平均值加减标准差的1.96倍是95%置信区间范围
    power_in(i)=wind_power_pre(1,i)+1.96*std_value;
end

%%
x=1:96;
figure;
COLOR=[205  16  118]/255;
h1=fill([x,fliplr(x)],[power_up,fliplr(power_in)],'r','DisplayName','uncertain');
h1.FaceColor = COLOR;%定义区间的填充颜色
h1.EdgeColor =[1,1,1];%边界颜色设置为白色
alpha .2 %设置透明色
hold on
plot(wind_power_pre(1,:),'-k','LineWidth',1.5,'MarkerSize',4,'MarkerFaceColor','m')
hold on
plot(wind_power_reall(1,:),'--b','LineWidth',1.5,'MarkerSize',4,'MarkerFaceColor','c')
hold on
plot(power_up,'--m','LineWidth',0.2,'MarkerSize',4,'MarkerFaceColor','k')
hold on
plot(power_in,'--c','LineWidth',0.2,'MarkerSize',4,'MarkerFaceColor','k')
xlabel('\fontname{宋体}时间\fontname{Times New Roman}(t/h)')
ylabel('\fontname{宋体}功率\fontname{Times New Roman}(MW)')
set(gca,'FontName','Times New Roman','linewidth',1.3)
legend('\fontname{Times New Roman}95%\fontname{宋体}置信区间','\fontname{宋体}预测值','\fontname{宋体}实际值','location','best')
legend('boxoff')
set(gca,'fontsize',16);
set(gca, 'box', 'off')
set(gca,'LooseInset',get(gca,'TightInset'))
