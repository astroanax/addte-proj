function xdot = duff(t,x) % Write both input arguments, t and x
% The percent sign is most commonly used to indicate nonexecutable 
% text within the body of a program. This text is normally used to include comments in your code.
% The Duffing System.

param;
xdot = zeros(2,1);

xdot(1) = x(2);
xdot(2) = -alph*x(1)-bet*x(1)^3-2*xi*x(2)+Gam*cos(Omega*t);