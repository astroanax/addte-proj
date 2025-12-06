% Problem 4: SINDy on Van der Pol Oscillator
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
polyorder = 3;
usesine = 0;

mu = 2.0;  % Van der Pol parameter (controls nonlinearity)

n = 2;  % 2 state variables: x, y (velocity)

x0 = [2; 0];  % Initial condition

% Integrate
tspan = [0:.001:20];
N = length(tspan);
options = odeset('RelTol',1e-12,'AbsTol',1e-12);
[t,x] = ode45(@(t,x) vanderpol(t,x,mu), tspan, x0, options);

%% compute Derivative
eps = .01;  % noise level
for i=1:length(x)
    dx(i,:) = vanderpol(0, x(i,:)', mu)';
end
dx = dx + eps*randn(size(dx));  % add noise

%% pool Data (i.e., build library of nonlinear time series)
Theta = poolData(x, n, polyorder, usesine);
m = size(Theta, 2);

%% compute Sparse regression: sequential least squares
lambda = 0.025;  % lambda is our sparsification knob
Xi = sparsifyDynamics(Theta, dx, lambda, n)
poolDataLIST({'x','y'}, Xi, n, polyorder, usesine);

%% Display true dynamics for comparison
fprintf('\n--- TRUE VAN DER POL DYNAMICS ---\n');
fprintf('dx/dt = y\n');
fprintf('dy/dt = mu*(1-x^2)*y - x = -x + %.1f*y - %.1f*x^2*y\n', mu, mu);

%% FIGURE 1: Phase Portrait for T in [0,20]
[tA,xA] = ode45(@(t,x) vanderpol(t,x,mu), tspan, x0, options);  % true model
[tB,xB] = ode45(@(t,x) sparseGalerkin(t,x,Xi,polyorder,usesine), tspan, x0, options);  % SINDy model

figure('Position', [100, 100, 1000, 400])
subplot(1,2,1)
plot(xA(:,1), xA(:,2), 'b-', 'LineWidth', 1.5)
hold on
plot(x0(1), x0(2), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
grid on
xlabel('x', 'FontSize', 13)
ylabel('y', 'FontSize', 13)
title('True Van der Pol', 'FontSize', 14)
axis equal
xlim([-3 3])
ylim([-4 4])
set(gca, 'FontSize', 13)

subplot(1,2,2)
plot(xB(:,1), xB(:,2), 'r--', 'LineWidth', 1.5)
hold on
plot(x0(1), x0(2), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
grid on
xlabel('x', 'FontSize', 13)
ylabel('y', 'FontSize', 13)
title('SINDy Identified', 'FontSize', 14)
axis equal
xlim([-3 3])
ylim([-4 4])
set(gca, 'FontSize', 13)

sgtitle(sprintf('Van der Pol Phase Portrait (\\mu = %.1f, T \\in [0,20])', mu), 'FontSize', 16)
print('-dpng', '-r150', [figpath 'p4_fig1_phase_portrait.png']);

%% FIGURE 2: Time series comparison
figure('Position', [100, 100, 1000, 400])
subplot(1,2,1)
plot(tA, xA(:,1), 'b', 'LineWidth', 1.5), hold on
plot(tB, xB(:,1), 'r--', 'LineWidth', 1.5)
grid on
xlabel('Time', 'FontSize', 13)
ylabel('x', 'FontSize', 13)
title('Position x(t)', 'FontSize', 14)
legend('True', 'SINDy', 'Location', 'best')
set(gca, 'FontSize', 13)

subplot(1,2,2)
plot(tA, xA(:,2), 'b', 'LineWidth', 1.5), hold on
plot(tB, xB(:,2), 'r--', 'LineWidth', 1.5)
grid on
xlabel('Time', 'FontSize', 13)
ylabel('y = dx/dt', 'FontSize', 13)
title('Velocity y(t)', 'FontSize', 14)
legend('True', 'SINDy', 'Location', 'best')
set(gca, 'FontSize', 13)

sgtitle('Van der Pol Time Series (T \in [0,20])', 'FontSize', 16)
print('-dpng', '-r150', [figpath 'p4_fig2_time_series.png']);

%% FIGURE 3: Long-term prediction T in [0,100]
tspan_long = [0 100];
options_long = odeset('RelTol',1e-6,'AbsTol',1e-6*ones(1,n));
[tA_long, xA_long] = ode45(@(t,x) vanderpol(t,x,mu), tspan_long, x0, options_long);
[tB_long, xB_long] = ode45(@(t,x) sparseGalerkin(t,x,Xi,polyorder,usesine), tspan_long, x0, options_long);

figure('Position', [100, 100, 1000, 400])
subplot(1,2,1)
plot(xA_long(:,1), xA_long(:,2), 'b-', 'LineWidth', 1)
hold on
plot(x0(1), x0(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k')
grid on
xlabel('x', 'FontSize', 13)
ylabel('y', 'FontSize', 13)
title('True Model', 'FontSize', 14)
axis equal
xlim([-3 3])
ylim([-4 4])

subplot(1,2,2)
plot(xB_long(:,1), xB_long(:,2), 'r-', 'LineWidth', 1)
hold on
plot(x0(1), x0(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k')
grid on
xlabel('x', 'FontSize', 13)
ylabel('y', 'FontSize', 13)
title('SINDy Model', 'FontSize', 14)
axis equal
xlim([-3 3])
ylim([-4 4])

sgtitle(sprintf('Long-term Prediction (T \\in [0,100])', mu), 'FontSize', 16)
print('-dpng', '-r150', [figpath 'p4_fig3_long_term.png']);

%% FIGURE 4: Coefficient comparison bar chart
% True coefficients: dx/dt = y, dy/dt = -x + mu*y - mu*x^2*y
% Library for n=2, polyorder=3: 1, x, y, x^2, xy, y^2, x^3, x^2y, xy^2, y^3
true_Xi = zeros(10, 2);
true_Xi(3, 1) = 1;     % y for dx/dt
true_Xi(2, 2) = -1;    % -x for dy/dt
true_Xi(3, 2) = mu;    % mu*y for dy/dt
true_Xi(8, 2) = -mu;   % -mu*x^2*y for dy/dt

figure('Position', [100, 100, 1000, 400])
terms = {'1', 'x', 'y', 'x^2', 'xy', 'y^2', 'x^3', 'x^2y', 'xy^2', 'y^3'};

subplot(1,2,1)
bar_data = [true_Xi(:,1), Xi(:,1)];
b = bar(bar_data);
b(1).FaceColor = [0.2, 0.4, 0.8];
b(2).FaceColor = [0.8, 0.2, 0.2];
set(gca, 'XTickLabel', terms, 'FontSize', 10);
xtickangle(45)
xlabel('Library Terms', 'FontSize', 12);
ylabel('Coefficient', 'FontSize', 12);
title('dx/dt Equation', 'FontSize', 14);
legend('True', 'SINDy', 'Location', 'best');
grid on;

subplot(1,2,2)
bar_data = [true_Xi(:,2), Xi(:,2)];
b = bar(bar_data);
b(1).FaceColor = [0.2, 0.4, 0.8];
b(2).FaceColor = [0.8, 0.2, 0.2];
set(gca, 'XTickLabel', terms, 'FontSize', 10);
xtickangle(45)
xlabel('Library Terms', 'FontSize', 12);
ylabel('Coefficient', 'FontSize', 12);
title('dy/dt Equation', 'FontSize', 14);
legend('True', 'SINDy', 'Location', 'best');
grid on;

sgtitle('Coefficient Comparison: True vs SINDy', 'FontSize', 16);
print('-dpng', '-r150', [figpath 'p4_fig4_coefficients.png']);

%% Summary
fprintf('\n========================================\n');
fprintf('SUMMARY\n');
fprintf('========================================\n');
fprintf('System: Van der Pol oscillator (mu = %.1f)\n', mu);
fprintf('Data points: %d\n', length(x));
fprintf('Noise level: %.1f%%\n', eps*100);
fprintf('Polynomial order: %d\n', polyorder);
fprintf('Lambda (sparsification): %.3f\n', lambda);

% Coefficient error
coef_error = norm(Xi - true_Xi, 'fro') / norm(true_Xi, 'fro');
fprintf('Relative coefficient error: %.4f%%\n', coef_error*100);

% Trajectory error
traj_error = sqrt(mean(mean((xA - xB).^2)));
fprintf('RMS trajectory error (T=0-20): %.6f\n', traj_error);

fprintf('\nFigures saved to %s\n', figpath);
