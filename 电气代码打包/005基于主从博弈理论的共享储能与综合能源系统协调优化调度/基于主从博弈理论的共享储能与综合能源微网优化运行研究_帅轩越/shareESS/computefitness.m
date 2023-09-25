%微网运营商收益为适应度函数
function  fitness = computefitness(x,P_MT,P_h,P_buy,pe_grid_S)  %计算适应度函数


%燃气发电机、锅炉常数
MT_e=0.4; %发电效率
Q_gas=9.88;%天然气热值

C_IESP=0;F_H=0;
for i=1:24
  C_IESP=C_IESP-2.55*P_MT(i)/MT_e/Q_gas+x(i).*(P_MT(i)+P_buy(i))-P_buy(i)*pe_grid_S(i);%燃气轮机的耗气成本，向用户售电，向电网买电
  F_H=F_H+x(i+24).*P_h(i);%向用户售热
end

fitness= C_IESP+ F_H;

  return;





