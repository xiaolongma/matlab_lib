function x=smooth2(x)

% F=[0.0 0.0 0.0 0.0 0.0 0.0 0.0;
%    0.0 0.50 0.75 1.0 0.75 0.50 0.0;
%    0.0 0.75 1.50 2.0 1.50 0.75 0.0;
%    0.0 1.00 2.00 2.0 2.00 1.00 0.0;
%    0.0 0.75 1.50 2.0 1.50 0.75 0.0;
%    0.0 0.50 0.75 1.0 0.75 0.50 0.0;
%    0.0 0.0 0.0 0.0 0.0 0.0 0.0]./28;
% F=[0.0 0.0  0.0 0.0  0.0;
%    0.0 0.75 1.0 0.75 0.0;
%    0.0 1.0  2.0 1.0  0.0;
%    0.0 0.75 1.0 0.75 0.0;
%    0.0 0.0 0.0 0.0 0.0]./9;
F=[1 2 1; 
    2 4 2;
    1 2 1]./16;

x=conv2(F,x);
x=x(1+floor(length(F)/2):end-floor(length(F)/2),...
    1+floor(length(F)/2):end-floor(length(F)/2));
   
   