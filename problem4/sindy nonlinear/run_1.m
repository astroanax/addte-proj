clc
clear all
nonlin_sys_param2;
% rooots;
 
psi_D=psi_ld_1(pi,6000,0.3);

options = odeset('RelTol',1e-2,'AbsTol',1e-4);
[t,y]= ode45(@nonlin_sys_func2,[0,500],[1,2,1,2],options);
plot(t,y(:,1));
hold on