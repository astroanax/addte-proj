clear                      
nonlin_sys_param2;
% creating the for loop for range of the rg %
rf = 1:1:10;
original_rf = rf; 
results = cell(1, numel(rf));
for idx = 1:numel(rf)
    rf(idx) = original_rf(idx);
opts = odeset('RelTol',1e-10,'AbsTol',1e-12);
[t,y]= ode23s(@(t,y)nonlin_sys_func2(t,y,rf(idx)),[0,100],[0.05,1,0.3,2],opts);
end
    figure(1)
plot(rf, psif_syst7_new(p1,1)*max_peak);
xlabel('rf');
ylabel('Maximum Peak of y');
title('rf vs Maximum Peak of y');
