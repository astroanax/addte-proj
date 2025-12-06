% Time-response and Phase portrait for the Duffing system.
clc
clear
close all

opts = odeset('RelTol',1e-4,'AbsTol',1e-4);
[t,y] = ode45(@duff_b,[0:0.001:1000],[1,0,0],opts);
% Create noise-only signal.
y1_noise = rand(size(y(:,1)));
 
% Create an amplitude for that noise that is 10% of the noise-free signal at every element.
 amplitude = 0.05 * y(:,1);

% Now add the noise-only signal to your original noise-free signal to create a noisy signal.
% Be sure to use .*, not *, so that you do element-by-element multiplication.
 y1_noise = y(:,1) + amplitude .* rand(size(y(:,1)));

% Adjust amplitude to control the amount of noise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving the data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M = [t y1_noise];
% save('noisy_data1_sys1.mat','M')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)
hold on
plot(t,y(:,1),'b')
hold on
plot(t,y1_noise,'m')

in = 6000;
figure(2)
hold on
plot(y(end-in:end,1),y(end-in:end,2),'b')
% fsize = 15;
% axis([-2 2 -2 2])
% xlabel('x','FontSize',fsize)
% ylabel('y','FontSize',fsize)