%΢����Ӫ������Ϊ��Ӧ�Ⱥ���
function  fitness = computefitness(x,P_MT,P_h,P_buy,pe_grid_S)  %������Ӧ�Ⱥ���


%ȼ�����������¯����
MT_e=0.4; %����Ч��
Q_gas=9.88;%��Ȼ����ֵ

C_IESP=0;F_H=0;
for i=1:24
  C_IESP=C_IESP-2.55*P_MT(i)/MT_e/Q_gas+x(i).*(P_MT(i)+P_buy(i))-P_buy(i)*pe_grid_S(i);%ȼ���ֻ��ĺ����ɱ������û��۵磬��������
  F_H=F_H+x(i+24).*P_h(i);%���û�����
end

fitness= C_IESP+ F_H;

  return;





