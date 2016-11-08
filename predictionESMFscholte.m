function estimates = predictionESMFscholte(estimates,u)
global noise 

N = estimates.n;
ds = u(1);
dth = u(2);
th1 = estimates.x(3) + dth;
Dfx = [1 0 -ds*sin(th1); 
       0 1  ds*cos(th1);
       0 0  1];
Gt = [Dfx, zeros(3,2*N); zeros(2*N,3) eye(2*N,2*N)];

% Predict the belief
estimates.x = estimates.x + [ds*cos(th1); 
                             ds*sin(th1);
                             dth; 
                             zeros(2*N,1)];
estimates.P = 1/(1-noise.beta)*Gt*estimates.P*Gt' +...
              (1/noise.beta)*blkdiag(noise.Qx,zeros(2*N));