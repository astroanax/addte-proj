clear                      
nonlin_sys_param2;
% creating the for loop for range of the rg %
rf = 1:1:10;
original_rf = rf; 
results = cell(1, numel(rf));
for idx = 1:numel(rf)
    rf(idx) = original_rf(idx);
%rf = rf_values(idx);
tspan=8.25:0.01:20;
y0=zeros(12,1);
opts = odeset('RelTol',1e-10,'AbsTol',1e-12);
[t,y]= ode23s(@nonlin_sys_func2,[0,100],[0.05,1,0.3,2],opts);

    
    % Consider a stabilization range (e.g., last 20% of the simulation time)
    stabilization_range = floor(0.8 * size(y, 1)):size(y, 1);
    
    % Extract the third column of y (difelection of the CLB1) within the stabilization range
    y_stabilized = y(stabilization_range, 1);
    
    % Find the maximum peak value within the stabilized range
    max_peak(idx) = max(y_stabilized);
    
    % Store the maximum peak value for this rf value
    %max_peak_values(idx) = max_peak;

end
    figure(1)
plot(rf, psif_syst7_new(p1,1)*max_peak);
xlabel('rf');
ylabel('Maximum Peak of y');
title('rf vs Maximum Peak of y');
