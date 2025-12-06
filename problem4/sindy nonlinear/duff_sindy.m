% Copyright 2015, All Rights Reserved
% Code by Steven L. Brunton
% For Paper, "Discovering Governing Equations from Data: 
%        Sparse Identification of Nonlinear Dynamical Systems"
% by S. L. Brunton, J. L. Proctor, and J. N. Kutz

clear all, close all, clc
% figpath = 'D:/01. NITC/01. NITC_Winter 2023-2024/02. ME6641E/05. matprog/Sindy/sparsedynamics/figures/';
addpath('./utils');

%% generate Data
polyorder = 5;  % search space up to fifth order polynomials
usesine = 1;    % no trig functions
n = 3;          % 3D system

tspan=[0:.01:500];   % time span
x0 = [1; 0; 0];        % initial conditions
options = odeset('RelTol',1e-6,'AbsTol',1e-6*ones(1,n));
[t,x]=ode45(@duff_b,tspan,x0,options);  % integrate

%% compute Derivative 
eps = 0.001;      % noise strength
for i=1:length(x)
    dx(i,:) = duff_b(0,x(i,:));
end
dx = dx + eps*randn(size(dx));   % add noise

figure(1)
plot(t,dx(:,1))
hold on
plot(t,x(:,2))

%% pool Data  (i.e., build library of nonlinear time series)
Theta = poolData(x,n,polyorder,usesine);
m = size(Theta,2);

%% compute Sparse regression: sequential least squares
lambda = 0.05;      % lambda is our sparsification knob.
Xi = sparsifyDynamics(Theta,dx,lambda,n)

%% integrate true and identified systems
[tA,xA]=ode45(@duff_b,tspan,x0,options);   % true model
[tB,xB]=ode45(@(t,x)sparseGalerkin(t,x,Xi,polyorder,usesine),tspan,x0,options);  % approximate

%% FIGURES!!
figure(2)
dtA = [0; diff(tA)];
plot(xA(:,1),xA(:,2),'r','LineWidth',1.5);
hold on
dtB = [0; diff(tB)];
plot(xB(:,1),xB(:,2),'k--','LineWidth',1.2);
xlabel('x_1','FontSize',13)
ylabel('x_2','FontSize',13)
l1 = legend('True','Identified');

figure(3)
plot(tA,xA(:,1),'r','LineWidth',1.5)
hold on
plot(tA,xA(:,2),'b-','LineWidth',1.5)
plot(tB(1:10:end),xB(1:10:end,1),'k--','LineWidth',1.2)
hold on
plot(tB(1:10:end),xB(1:10:end,2),'k--','LineWidth',1.2)
xlabel('Time')
ylabel('State, x_k')
legend('True x_1','True x_2','Identified')