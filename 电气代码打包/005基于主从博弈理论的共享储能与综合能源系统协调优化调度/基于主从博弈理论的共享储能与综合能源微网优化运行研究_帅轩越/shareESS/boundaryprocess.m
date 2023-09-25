function u= boundaryprocess(x,pe_grid_S,pe_grid_B,ph_max,ph_min)   %检查种群中个体数值是否超出取值范围。
[row,col] = size(x);


% 边界条件处理
 for i=1:row
    for j=1:col
        tmp(i,j) = x(i,j);
          if j<25      
              if x(i,j)<=pe_grid_B(j)
                  tmp=pe_grid_B(j)+0.01;
                   elseif x(i,j)>=pe_grid_S(j)
                       if 22<j<25
                        tmp=pe_grid_S(j)-0.12;
                       elseif 23>j>17
                           tmp=pe_grid_S(j)-0.24;
                       elseif  18>j>14
                           tmp=pe_grid_S(j)-0.15;
                       elseif 15>j>9
                           tmp=pe_grid_S(j)-0.28;
                       else
                           tmp=pe_grid_S(j)- 0.01;
                       end
              else
                tmp=x(i,j);  
              end
          end
          if j>24&&j<49       
              if x(i,j)<=ph_min(j-24)
                  tmp=ph_min(j-24)+0.05;
                  elseif x(i,j)>=ph_max(j-24)
                        tmp=ph_max(j-24)-0.05;
                        else
                tmp=x(i,j);  
              end
          
          end
    u(i,j) = tmp;
    end
             
 end

 
return;
              
              
              
                  





