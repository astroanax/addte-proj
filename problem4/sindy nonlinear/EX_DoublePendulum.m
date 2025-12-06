% Problem 4: SINDy on Double Pendulum (Small-Angle Approximation)
% ME3435E Applied Data-Driven Techniques in Engineering
%
% Based on EX02_Lorenz.m from:
% Copyright 2015, All Rights Reserved
% Code by Steven L. Brunton
% For Paper, "Discovering Governing Equations from Data: 
%        Sparse Identification of Nonlinear Dynamical Systems"
% by S. L. Brunton, J. L. Proctor, and J. N. Kutz

clear all, close all, clc
figpath = '../';
addpath('./utils');

%% generate Data
polyorder = 2;  % Linear system, so order 2 is sufficient (includes linear terms)
usesine = 0;

% Physical parameters
g = 9.81;  % gravitational acceleration (m/s^2)
L = 1.0;   % pendulum length (m)
gL = g/L;  % ratio used in equations

n = 4;  % 4 state variables: theta1, theta2, omega1, omega2

% Initial condition (small angles in radians)
x0 = [0.2; 0.1; 0; 0];  % theta1=0.2rad, theta2=0.1rad, omega1=0, omega2=0

% Integrate
tspan = [0:.001:10];
N = length(tspan);
options = odeset('RelTol',1e-12,'AbsTol',1e-12);
[t,x] = ode45(@(t,x) double_pendulum(t,x,g,L), tspan, x0, options);

%% compute Derivative
eps = .001;  % noise level (smaller for linear system)
for i=1:length(x)
    dx(i,:) = double_pendulum(0, x(i,:)', g, L)';
end
dx = dx + eps*randn(size(dx));  % add noise

%% pool Data (i.e., build library of nonlinear time series)
Theta = poolData(x, n, polyorder, usesine);
m = size(Theta, 2);

%% compute Sparse regression: sequential least squares
lambda = 0.1;  % lambda is our sparsification knob
Xi = sparsifyDynamics(Theta, dx, lambda, n)
poolDataLIST({'t1','t2','w1','w2'}, Xi, n, polyorder, usesine);

%% Display true dynamics for comparison
fprintf('\n--- TRUE DOUBLE PENDULUM DYNAMICS (Small-Angle) ---\n');
fprintf('d(theta1)/dt = omega1\n');
fprintf('d(theta2)/dt = omega2\n');
fprintf('d(omega1)/dt = -2*(g/L)*theta1 + (g/L)*theta2 = -%.2f*t1 + %.2f*t2\n', 2*gL, gL);
fprintf('d(omega2)/dt = 2*(g/L)*theta1 - 2*(g/L)*theta2 = %.2f*t1 - %.2f*t2\n', 2*gL, 2*gL);

%% FIGURE 1: Time Series for T in [0,10]
[tA,xA] = ode45(@(t,x) double_pendulum(t,x,g,L), tspan, x0, options);  % true model
[tB,xB] = ode45(@(t,x) sparseGalerkin(t,x,Xi,polyorder,usesine), tspan, x0, options);  % SINDy model

figure('Position', [100, 100, 1200, 800])

subplot(2,2,1)
plot(tA, xA(:,1), 'b-', 'LineWidth', 1.5)
hold on
plot(tB, xB(:,1), 'r--', 'LineWidth', 1.5)
xlabel('Time (s)', 'FontSize', 12)
ylabel('\theta_1 (rad)', 'FontSize', 12)
title('Angle \theta_1', 'FontSize', 14)
legend('True', 'SINDy', 'Location', 'best')
grid on

subplot(2,2,2)
plot(tA, xA(:,2), 'b-', 'LineWidth', 1.5)
hold on
plot(tB, xB(:,2), 'r--', 'LineWidth', 1.5)
xlabel('Time (s)', 'FontSize', 12)
ylabel('\theta_2 (rad)', 'FontSize', 12)
title('Angle \theta_2', 'FontSize', 14)
legend('True', 'SINDy', 'Location', 'best')
grid on

subplot(2,2,3)
plot(tA, xA(:,3), 'b-', 'LineWidth', 1.5)
hold on
plot(tB, xB(:,3), 'r--', 'LineWidth', 1.5)
xlabel('Time (s)', 'FontSize', 12)
ylabel('\omega_1 (rad/s)', 'FontSize', 12)
title('Angular Velocity \omega_1', 'FontSize', 14)
legend('True', 'SINDy', 'Location', 'best')
grid on

subplot(2,2,4)
plot(tA, xA(:,4), 'b-', 'LineWidth', 1.5)
hold on
plot(tB, xB(:,4), 'r--', 'LineWidth', 1.5)
xlabel('Time (s)', 'FontSize', 12)
ylabel('\omega_2 (rad/s)', 'FontSize', 12)
title('Angular Velocity \omega_2', 'FontSize', 14)
legend('True', 'SINDy', 'Location', 'best')
grid on

sgtitle('Double Pendulum: Time Series Comparison (T \in [0,10])', 'FontSize', 16)
print('-dpng', '-r150', [figpath 'p4_fig1_time_series.png']);

%% FIGURE 2: Phase Portraits
figure('Position', [100, 100, 1000, 400])

subplot(1,2,1)
plot(xA(:,1), xA(:,3), 'b-', 'LineWidth', 1.5)
hold on
plot(xB(:,1), xB(:,3), 'r--', 'LineWidth', 1.5)
plot(x0(1), x0(3), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
xlabel('\theta_1 (rad)', 'FontSize', 12)
ylabel('\omega_1 (rad/s)', 'FontSize', 12)
title('Phase Portrait: Pendulum 1', 'FontSize', 14)
legend('True', 'SINDy', 'IC', 'Location', 'best')
grid on
axis equal

subplot(1,2,2)
plot(xA(:,2), xA(:,4), 'b-', 'LineWidth', 1.5)
hold on
plot(xB(:,2), xB(:,4), 'r--', 'LineWidth', 1.5)
plot(x0(2), x0(4), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
xlabel('\theta_2 (rad)', 'FontSize', 12)
ylabel('\omega_2 (rad/s)', 'FontSize', 12)
title('Phase Portrait: Pendulum 2', 'FontSize', 14)
legend('True', 'SINDy', 'IC', 'Location', 'best')
grid on
axis equal

sgtitle('Double Pendulum Phase Portraits', 'FontSize', 16)
print('-dpng', '-r150', [figpath 'p4_fig2_phase_portrait.png']);

%% FIGURE 3: Pendulum Animation Snapshots
figure('Position', [100, 100, 1200, 400])

% Select time snapshots
t_snapshots = [0, 1, 2, 3, 4];

for k = 1:length(t_snapshots)
    subplot(1, length(t_snapshots), k)
    
    % Find index closest to desired time
    [~, idx] = min(abs(tA - t_snapshots(k)));
    
    % Get angles
    th1 = xA(idx, 1);
    th2 = xA(idx, 2);
    
    % Compute pendulum positions
    x1 = L * sin(th1);
    y1 = -L * cos(th1);
    x2 = x1 + L * sin(th2);
    y2 = y1 - L * cos(th2);
    
    % Plot
    plot([0, x1], [0, y1], 'b-', 'LineWidth', 3)
    hold on
    plot([x1, x2], [y1, y2], 'r-', 'LineWidth', 3)
    plot(0, 0, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
    plot(x1, y1, 'bo', 'MarkerSize', 15, 'MarkerFaceColor', 'b')
    plot(x2, y2, 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r')
    
    axis equal
    xlim([-2.5, 2.5])
    ylim([-2.5, 0.5])
    grid on
    title(sprintf('t = %.1f s', t_snapshots(k)), 'FontSize', 12)
    xlabel('x (m)', 'FontSize', 10)
    ylabel('y (m)', 'FontSize', 10)
end

sgtitle('Double Pendulum Motion Snapshots', 'FontSize', 16)
print('-dpng', '-r150', [figpath 'p4_fig3_pendulum_snapshots.png']);

%% FIGURE 4: Coefficient Comparison (Bar Plot)
% True coefficients for linearized double pendulum
% Library for n=4, polyorder=2: 
% 1, t1, t2, w1, w2, t1^2, t1*t2, t1*w1, t1*w2, t2^2, t2*w1, t2*w2, w1^2, w1*w2, w2^2
% Total: 15 terms

% Build true coefficient matrix
true_Xi = zeros(size(Xi));
% d(theta1)/dt = omega1  => coeff of w1 is 1
true_Xi(4, 1) = 1;
% d(theta2)/dt = omega2  => coeff of w2 is 1
true_Xi(5, 2) = 1;
% d(omega1)/dt = -2*gL*theta1 + gL*theta2
true_Xi(2, 3) = -2*gL;  % t1 coefficient
true_Xi(3, 3) = gL;     % t2 coefficient
% d(omega2)/dt = 2*gL*theta1 - 2*gL*theta2
true_Xi(2, 4) = 2*gL;   % t1 coefficient
true_Xi(3, 4) = -2*gL;  % t2 coefficient

figure('Position', [100, 100, 1200, 600])

% Get library terms for n=4, polyorder=2
terms = {'1', 't1', 't2', 'w1', 'w2', 't1^2', 't1t2', 't1w1', 't1w2', ...
         't2^2', 't2w1', 't2w2', 'w1^2', 'w1w2', 'w2^2'};

for eq = 1:4
    subplot(2,2,eq)
    bar_data = [true_Xi(:,eq), Xi(:,eq)];
    b = bar(bar_data);
    b(1).FaceColor = [0.2, 0.4, 0.8];
    b(2).FaceColor = [0.8, 0.2, 0.2];
    set(gca, 'XTickLabel', terms, 'FontSize', 8);
    xtickangle(45)
    xlabel('Library Terms', 'FontSize', 10);
    ylabel('Coefficient', 'FontSize', 10);
    
    if eq == 1
        title('d\theta_1/dt', 'FontSize', 12);
    elseif eq == 2
        title('d\theta_2/dt', 'FontSize', 12);
    elseif eq == 3
        title('d\omega_1/dt', 'FontSize', 12);
    else
        title('d\omega_2/dt', 'FontSize', 12);
    end
    legend('True', 'SINDy', 'Location', 'best');
    grid on;
end

sgtitle('Coefficient Comparison: True vs SINDy', 'FontSize', 16);
print('-dpng', '-r150', [figpath 'p4_fig4_coefficients.png']);

%% Summary Statistics
fprintf('\n========================================\n');
fprintf('SUMMARY\n');
fprintf('========================================\n');
fprintf('System: Double Pendulum (small-angle approximation)\n');
fprintf('Parameters: g = %.2f m/s^2, L = %.2f m, g/L = %.2f\n', g, L, gL);
fprintf('Data points: %d\n', length(x));
fprintf('Noise level: %.2f%%\n', eps*100);
fprintf('Polynomial order: %d\n', polyorder);
fprintf('Lambda (sparsification): %.3f\n', lambda);

% Coefficient error
coef_error = norm(Xi - true_Xi, 'fro') / norm(true_Xi, 'fro');
fprintf('Relative coefficient error: %.4f%%\n', coef_error*100);

% Trajectory error
traj_error = sqrt(mean(mean((xA - xB).^2)));
fprintf('RMS trajectory error (T=0-10): %.6f\n', traj_error);

fprintf('\nFigures saved to %s\n', figpath);
