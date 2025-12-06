function dy = vanderpol(t, y, mu)
% Van der Pol oscillator ODE
% dy/dt = [y(2); mu*(1 - y(1)^2)*y(2) - y(1)]
%
% States: y(1) = x (position), y(2) = v (velocity)
% Parameter: mu = nonlinearity parameter
%
% For SINDy Problem 4
% ME3435E Applied Data-Driven Techniques in Engineering

dy = [
    y(2);
    mu*(1 - y(1)^2)*y(2) - y(1);
];

end
