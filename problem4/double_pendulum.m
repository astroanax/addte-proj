function dy = double_pendulum(t, y, g, L)
% Double pendulum ODE with small-angle approximation
%
% For equal masses m and equal lengths L:
% State variables: y = [theta1; theta2; omega1; omega2]
%   theta1, theta2 = angular positions
%   omega1, omega2 = angular velocities
%
% Small angle approximation: sin(theta) ≈ theta, cos(theta) ≈ 1
%
% Linearized equations:
%   d(theta1)/dt = omega1
%   d(theta2)/dt = omega2
%   d(omega1)/dt = -2*(g/L)*theta1 + (g/L)*theta2
%   d(omega2)/dt = 2*(g/L)*theta1 - 2*(g/L)*theta2
%
% Parameters:
%   g = gravitational acceleration (default 9.81 m/s^2)
%   L = pendulum length (default 1 m)
%
% For SINDy Problem 4
% ME3435E Applied Data-Driven Techniques in Engineering

% Ratio g/L
gL = g / L;

theta1 = y(1);
theta2 = y(2);
omega1 = y(3);
omega2 = y(4);

dy = [
    omega1;                              % d(theta1)/dt = omega1
    omega2;                              % d(theta2)/dt = omega2
    -2*gL*theta1 + gL*theta2;            % d(omega1)/dt
    2*gL*theta1 - 2*gL*theta2;           % d(omega2)/dt
];

end
