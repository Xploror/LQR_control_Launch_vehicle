clc; clear all;

%constants
Iyy = 2.186e8;
m = 38901;
Tc = 2.361e6;
V = 1347;
x_cg = 53.19;
x_cp = 121.2;
Cn_alpha = 0.1465;
g = 26.10;
N_alpha = 686819;
M_alpha = x_cp*N_alpha/Iyy;
M_delta = x_cg*Tc/Iyy;

draw = true;   % Whether to plot the statespace plots or root locus plot or notq3qwv

%other constants
Mach = 1.4;
h = 34000;
S = 116.2;
Fbase = 1000;
Ca = 2.4;
D = Ca*680*S - Fbase;
Drag = 7.15*D;
F = Tc-Drag;

A_m = [0 1 0; M_alpha 0 M_alpha/V; -(F+N_alpha)/m 0 -N_alpha/(m*V)];

B_m = [0;M_delta;Tc/m];

C_m = diag([1 1 1]);

D_m = [0;0;0];

pitch_ss = ss(A_m,B_m,C_m,D_m);

K = LQR_cost(pitch_ss, V, draw);

K_1 = K(1);
K_2 = K(2);
K_3 = K(3);

% These K_1 K_2 and K_3 feedback Gains are used in the simulink block system to
% simulate the controller 