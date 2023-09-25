%% 清空环境变量
clc
clear all;
%% 提取数据 
data=xlsread('实验数据.xlsx',1);

%% 提取对应各段中点位置处的误差值
error_fenbu_1=[];
for i=1:size(data,1)
   if data(i,3)>=220 && data(i,3)<=240
        error_fenbu_1(i)=data(i,8);
   else
       error_fenbu_1(i)=0;
   end
end
error_1=error_fenbu_1(find(error_fenbu_1~=0));
error_fenbu_2=[];
for i=1:size(data,1)
    if data(i,3)>=670&&data(i,3)<=690;
        error_fenbu_2(i)=data(i,8);
      else error_fenbu_2(i)=0;
   end
end  
error_2=error_fenbu_2(find(error_fenbu_2~=0));

error_fenbu_3=[];
for i=1:size(data,1)
    if data(i,3)>=1128 && data(i,3)<=1148;
        error_fenbu_3(i)=data(i,8);
     else error_fenbu_3(i)=0;
   end
end
error_3=error_fenbu_3(find(error_fenbu_3~=0));
error_fenbu_4=[];
for i=1:size(data,1)
    if data(i,3)>=1585&&data(i,3)<=1605;
        error_fenbu_4(i)=data(i,8);
       else error_fenbu_4(i)=0;
   end
end  
error_4=error_fenbu_4(find(error_fenbu_4~=0));
error_fenbu_5=[];
for i=1:size(data,1) 
   if data(i,3)>=2040&&data(i,3)<=2060;
        error_fenbu_5(i)=data(i,8);
   else   error_fenbu_5(i)=0;
   end
end
error_5=error_fenbu_5(find(error_fenbu_5~=0));

error_fenbu_6=[];
for i=1:size(data,1) 
   if data(i,3)>=2495 && data(i,3)<=2515;
        error_fenbu_6(i)=data(i,8);
        else   error_fenbu_6(i)=0;
   end
end
error_6=error_fenbu_6(find(error_fenbu_6~=0));
error_fenbu_7=[];
for i=1:size(data,1)  
    if data(i,3)>=2950&&data(i,3)<=2970;
        error_fenbu_7(i)=data(i,8);
     else   error_fenbu_7(i)=0;
   end
end 
error_7=error_fenbu_7(find(error_fenbu_7~=0));
error_fenbu_8=[];
for i=1:size(data,1)  
    if data(i,3)>=3406 && data(i,3)<=3426;
        error_fenbu_8(i)=data(i,8);   
        else   error_fenbu_8(i)=0;
   end
end 
error_8=error_fenbu_8(find(error_fenbu_8~=0));
error_fenbu_9=[];
for i=1:size(data,1)  
   if data(i,3)>=3860&&data(i,3)<=3880;
        error_fenbu_9(i)=data(i,8); 
        else   error_fenbu_9(i)=0;
   end
end 
error_9=error_fenbu_9(find(error_fenbu_9~=0));
error_fenbu_10=[];
for i=1:size(data,1)  
    if data(i,3)>=4317&&data(i,3)<=4337;
        error_fenbu_10(i)=data(i,8); 
        else   error_fenbu_10(i)=0;
   end
end 
error_10=error_fenbu_10(find(error_fenbu_10~=0));

%% 拟合分布—求取t分布参数进行拟合
error_values=-3000:0.5:3000;
pd_1= fitdist(error_1','tLocationScale');
desity_1= pdf(pd_1,error_values);
pd_2= fitdist(error_2','tLocationScale');
desity_2= pdf(pd_2,error_values);
pd_3= fitdist(error_3','tLocationScale');
desity_3= pdf(pd_3,error_values);
pd_4= fitdist(error_4','tLocationScale');
desity_4= pdf(pd_4,error_values);
pd_5= fitdist(error_5','tLocationScale');
desity_5= pdf(pd_5,error_values);
pd_6= fitdist(error_6','tLocationScale');
desity_6= pdf(pd_6,error_values);
pd_7= fitdist(error_7','tLocationScale');
desity_7= pdf(pd_7,error_values);
pd_8= fitdist(error_8','tLocationScale');
desity_8= pdf(pd_8,error_values);
pd_9= fitdist(error_9','tLocationScale');
desity_9= pdf(pd_9,error_values);
pd_10= fitdist(error_10','tLocationScale');
desity_10= pdf(pd_10,error_values);

%% 绘制三维t—分布图
X=[];
for i=1:10
X(i,1:length(error_values))=i*0.1;
end
figure
plot3(X(1,:),error_values,desity_1,'-b')
hold on
plot3(X(2,:),error_values,desity_2,'-k')
hold on
plot3(X(3,:),error_values,desity_3,'-c')
hold on
plot3(X(4,:),error_values,desity_4,'-m')
hold on
plot3(X(5,:),error_values,desity_5,'-g')
hold on
plot3(X(6,:),error_values,desity_6,'-b')
hold on
plot3(X(7,:),error_values,desity_7,'-y')
hold on
plot3(X(8,:),error_values,desity_8,'-r')
hold on
plot3(X(9,:),error_values,desity_2,'-g')
hold on
plot3(X(10,:),error_values,desity_1,'-c')
xlabel('\fontname{宋体}功率\fontname{Times New Roman}(p.u)')
ylabel('\fontname{宋体}误差\fontname{Times New Roman}(MW)')
zlabel('\fontname{宋体}概率密度')
set(gca,'FontName','Times New Roman','linewidth',1.1)
set(gca,'fontsize',12);
set(gca,'YTick',-3000:800:3000);
grid on

%% 绘制A风电场的采样功率及一天内的功率变化过程
wind_power=[];
for i=1:10
    wind_power(i,:)=data(1+(i-1)*96:96*i,3);
end
power_1=[];
power_2=[];
for i=1:24
    power_1(i)=mean(wind_power(1,1+(i-1)*4:4*i));
    power_2(i)=mean(wind_power(2,1+(i-1)*4:4*i));
end

%% 随机采样
rate=[];
for i=1:24
    if power_1(i)>=1 && power_1(i)<=455
        rate(i)=1;
    elseif power_1(i)>455 && power_1(i)<=911
        rate(i)=2;
    elseif power_1(i)>911 && power_1(i)<=1366
        rate(i)=3;
    elseif power_1(i)>1366 && power_1(i)<=1822
        rate(i)=4;
    elseif power_1(i)>1822 && power_1(i)<=2277
        rate(i)=5;
    elseif power_1(i)>2277 && power_1(i)<=2733
        rate(i)=6;
    elseif power_1(i)>2733 && power_1(i)<=3188
        rate(i)=7;
    elseif power_1(i)>3188 && power_1(i)<=3644
        rate(i)=8;
    elseif power_1(i)>3644 && power_1(i)<4099
        rate(i)=9;
    elseif power_1(i)>4099 && power_1(i)<=4555
        rate(i)=10;
    end
end
%% 对误差进行排序
[R,location]=sort(data(:,1),'descend');
error_wind=data(location,7);
error_wind_1=error_wind(1:length(find(R<=455)));
error_wind_2=error_wind(length(find(R<=455))+1:length(find(R<=911)));
error_wind_3=error_wind(length(find(R<=911))+1:length(find(R<=1366)));
error_wind_4=error_wind(length(find(R<=1366))+1:length(find(R<=1822)));
error_wind_5=error_wind(length(find(R<=1822))+1:length(find(R<=2277)));
error_wind_6=error_wind(length(find(R<=2277))+1:length(find(R<=2733)));
error_wind_7=error_wind(length(find(R<=2733))+1:length(find(R<=3188)));
error_wind_8=error_wind(length(find(R<=3188))+1:length(find(R<=3644)));
error_wind_9=error_wind(length(find(R<=3644))+1:length(find(R<=4099)));
error_wind_10=error_wind(length(find(R<=4099))+1:length(find(R<=4555)));
temp1=randperm(length(error_wind_1));
temp2=randperm(length(error_wind_2));
temp3=randperm(length(error_wind_3));
temp4=randperm(length(error_wind_4));
temp5=randperm(length(error_wind_5));
temp6=randperm(length(error_wind_6));
temp7=randperm(length(error_wind_7));
temp8=randperm(length(error_wind_8));
temp9=randperm(length(error_wind_9));
temp10=randperm(length(error_wind_10));
caiyang=[];
for i=1:24
    if rate(i)==1
        caiyang(i,1:100)=power_1(i)+error_wind_1(temp1(1:100))';
    elseif rate(i)==2
        caiyang(i,1:100)=power_1(i)+error_wind_2(temp2(1:100))';
    elseif rate(i)==3
        caiyang(i,1:100)=power_1(i)+error_wind_3(temp3(1:100))';
    elseif rate(i)==4
        caiyang(i,1:100)=power_1(i)+error_wind_4(temp4(1:100))';
    elseif rate(i)==5
        caiyang(i,1:100)=power_1(i)+error_wind_5(temp5(1:100))';
    elseif rate(i)==6
        caiyang(i,1:100)=power_1(i)+error_wind_6(temp6(1:100))';
    elseif rate(i)==7
        caiyang(i,1:100)=power_1(i)+error_wind_7(temp7(1:100))';
    elseif rate(i)==8
        caiyang(i,1:100)=power_1(i)+error_wind_8(temp8(1:100))';
    elseif rate(i)==9
        caiyang(i,1:100)=power_1(i)+error_wind_9(temp9(1:100))';
    elseif rate(i)==10
        caiyang(i,1:100)=power_1(i)+error_wind_10(temp10(1:100))';
    else caiyang(i,1:100)=0;
    end
end
x_caiyang=[];
for i=1:24
x_caiyang(i,:)=[i-1+0.75:0.005:i+0.245];
end
%% 绘图
figure
plot(x_caiyang(1,:),caiyang(1,:),'dm','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','m')
hold on
plot(x_caiyang(2,:),caiyang(2,:),'dk','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','k')
hold on
plot(x_caiyang(3,:),caiyang(3,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang(4,:),caiyang(4,:),'db','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','b')
hold on
plot(x_caiyang(5,:),caiyang(5,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang(6,:),caiyang(6,:),'dr','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','r')
hold on
plot(x_caiyang(7,:),caiyang(7,:),'dg','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','g')
hold on
plot(x_caiyang(8,:),caiyang(8,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang(9,:),caiyang(9,:),'db','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','b')
hold on
plot(x_caiyang(10,:),caiyang(10,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang(11,:),caiyang(11,:),'dy','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','y')
hold on
plot(x_caiyang(12,:),caiyang(12,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang(13,:),caiyang(13,:),'sk','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','k')
hold on
plot(x_caiyang(14,:),caiyang(14,:),'dm','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','m')
hold on
plot(x_caiyang(15,:),caiyang(15,:),'db','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','b')
hold on
plot(x_caiyang(16,:),caiyang(16,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang(17,:),caiyang(17,:),'dg','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','g')
hold on
plot(x_caiyang(18,:),caiyang(18,:),'dk','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','k')
hold on
plot(x_caiyang(19,:),caiyang(19,:),'dr','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','r')
hold on
plot(x_caiyang(20,:),caiyang(20,:),'>c','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang(21,:),caiyang(21,:),'<m','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','m')
hold on
plot(x_caiyang(22,:),caiyang(22,:),'<k','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','k')
hold on
plot(x_caiyang(23,:),caiyang(23,:),'<b','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','b')
hold on
plot(x_caiyang(24,:),caiyang(24,:),'>c','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(power_1,'-dm','LineWidth',1,'MarkerSize',4,'MarkerFaceColor','m')
xlabel('\fontname{宋体}时间\fontname{Times New Roman}(t/h)')
ylabel('\fontname{宋体}功率\fontname{Times New Roman}(MW)')
set(gca,'FontName','Times New Roman','linewidth',1.1)
set(gca,'fontsize',16);
set(gca, 'box', 'off')
set(gca,'LooseInset',get(gca,'TightInset'))
%% Day2

rate1=[];
for i=1:24
    if power_2(i)>=1 && power_2(i)<=455
        rate1(i)=1;
    elseif power_2(i)>455 && power_2(i)<=911
        rate1(i)=2;
    elseif power_2(i)>911 && power_2(i)<=1366
        rate1(i)=3;
    elseif power_2(i)>1366 && power_2(i)<=1822
        rate1(i)=4;
    elseif power_2(i)>1822 && power_2(i)<=2277
        rate1(i)=5;
    elseif power_2(i)>2277 && power_2(i)<=2733
        rate1(i)=6;
    elseif power_2(i)>2733 && power_2(i)<=3188
        rate1(i)=7;
    elseif power_2(i)>3188 && power_2(i)<=3644
        rate1(i)=8;
    elseif power_2(i)>3644 && power_2(i)<4099
        rate1(i)=9;
    elseif power_2(i)>4099 && power_2(i)<=4555
        rate1(i)=10;
    end
end

caiyang1=[];
for i=1:24
    if rate1(i)==1
        caiyang1(i,1:100)=power_2(i)+error_wind_1(temp1(1:100))';
    elseif rate1(i)==2
        caiyang1(i,1:100)=power_2(i)+error_wind_2(temp2(1:100))';
    elseif rate1(i)==3
        caiyang1(i,1:100)=power_2(i)+error_wind_3(temp3(1:100))';
    elseif rate1(i)==4
        caiyang1(i,1:100)=power_2(i)+error_wind_4(temp4(1:100))';
    elseif rate1(i)==5
        caiyang1(i,1:100)=power_2(i)+error_wind_5(temp5(1:100))';
    elseif rate1(i)==6
        caiyang1(i,1:100)=power_2(i)+error_wind_6(temp6(1:100))';
    elseif rate1(i)==7
        caiyang1(i,1:100)=power_2(i)+error_wind_7(temp7(1:100))';
    elseif rate1(i)==8
        caiyang1(i,1:100)=power_2(i)+error_wind_8(temp8(1:100))';
    elseif rate1(i)==9
        caiyang1(i,1:100)=power_2(i)+error_wind_9(temp9(1:100))';
    elseif rate1(i)==10
        caiyang1(i,1:100)=power_2(i)+error_wind_10(temp10(1:100))';
    else caiyang1(i,1:100)=0;
    end
end
x_caiyang1=[];
for i=1:24
x_caiyang1(i,:)=[i-1+0.75:0.005:i+0.245];
end
%% 绘图
figure
plot(x_caiyang1(1,:),caiyang1(1,:),'dm','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','m')
hold on
plot(x_caiyang1(2,:),caiyang1(2,:),'dk','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','k')
hold on
plot(x_caiyang1(3,:),caiyang1(3,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang1(4,:),caiyang1(4,:),'db','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','b')
hold on
plot(x_caiyang1(5,:),caiyang1(5,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang1(6,:),caiyang1(6,:),'dr','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','r')
hold on
plot(x_caiyang1(7,:),caiyang1(7,:),'dg','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','g')
hold on
plot(x_caiyang1(8,:),caiyang1(8,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang1(9,:),caiyang1(9,:),'db','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','b')
hold on
plot(x_caiyang1(10,:),caiyang1(10,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang1(11,:),caiyang1(11,:),'dy','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','y')
hold on
plot(x_caiyang1(12,:),caiyang1(12,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang1(13,:),caiyang1(13,:),'dk','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','k')
hold on
plot(x_caiyang1(14,:),caiyang1(14,:),'dm','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','m')
hold on
plot(x_caiyang1(15,:),caiyang1(15,:),'db','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','b')
hold on
plot(x_caiyang1(16,:),caiyang1(16,:),'dc','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang1(17,:),caiyang1(17,:),'dg','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','g')
hold on
plot(x_caiyang1(18,:),caiyang1(18,:),'dk','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','k')
hold on
plot(x_caiyang1(19,:),caiyang1(19,:),'dr','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','r')
hold on
plot(x_caiyang1(20,:),caiyang1(20,:),'>c','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(x_caiyang1(21,:),caiyang1(21,:),'<m','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','m')
hold on
plot(x_caiyang1(22,:),caiyang1(22,:),'<k','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','k')
hold on
plot(x_caiyang1(23,:),caiyang1(23,:),'<b','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','b')
hold on
plot(x_caiyang1(24,:),caiyang1(24,:),'>c','LineWidth',0.5,'MarkerSize',1,'MarkerFaceColor','c')
hold on
plot(power_2,'-dm','LineWidth',1,'MarkerSize',4,'MarkerFaceColor','m')
xlabel('\fontname{宋体}时间\fontname{Times New Roman}(t/h)')
ylabel('\fontname{宋体}功率\fontname{Times New Roman}(MW)')
set(gca,'FontName','Times New Roman','linewidth',1.1)
set(gca,'fontsize',16);
set(gca, 'box', 'off')
set(gca,'LooseInset',get(gca,'TightInset'))
