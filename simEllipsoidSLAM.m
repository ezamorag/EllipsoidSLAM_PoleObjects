clc, clear all, close all
global vehicle noise map LRF detection
 
% Configuration
vehicle.L = 0.312805010921192;      %
vehicle.al = 4.34899369897736e-05;  %
vehicle.ar = 4.33717743447206e-05;  %
LRF.rmax = 10;                                          % Maximum relaible distance for sensor 
LRF.angles = (-pi/2+pi/(2*99)):pi/99:(pi/2-pi/(2*99));  % AngLRF, Vector of discrete angules of laser rays

% Free parameters
noise.Qx = diag([5e-7 5e-7 5e-8]); % (x, y, th) 
noise.Rz = diag([0.00015 0.00001]);   % (range, angle)  
noise.beta = 3e-5;
noise.rho = 3e-6;
Tkz = 200;
map.Npruning = 10; % 
map.chi2 = chi2inv(1-0.95,2);  %  
map.distmin = 1;

% DCA Dataset 
odo = load('odometriaTreesSyn.csv');
laser = load('laserTreesSyn.csv');
zt = double(laser(:,13:end-11)/1000);


% Map initialization
x0 = [0; 0; 0]; %Initial condition
estimates.n = 0;
estimates.x = x0;
estimates.P = zeros(3,3);
estimates.count = [];

% Get observations
observations = get_observations(zt(1,:));

% Add features
estimates = add_features(estimates,observations);
k_initial = 2;

xest{1} = x0;
tic
for k=k_initial:size(odo,1)
    % get controls
    u = get_controls(odo(k,2)-odo(k-1,2),odo(k,3)-odo(k-1,3));
    
    % prediction
    estimates = predictionESMFscholte(estimates,u);
    
    % get observations
    observations = get_observations(zt(k,:));

    if observations.m > 0 && estimates.n > 0    
        % Data association
        compatibility = individual_compatibility(estimates,observations);
        H = ICNN(observations,compatibility);

        % Update
        [estimates new] = updateESMFscholte(estimates,observations,compatibility,H);
        % Add new features 
        estimates = add_features(estimates,observations,new);
    elseif observations.m > 0 && estimates.n == 0   
        estimates = add_features(estimates,observations);
    end

    if mod(k,Tkz) == 0
        estimates = pruning(estimates);
    end
    xest{k} = estimates.x;
    numlandmarks(k) = estimates.n;
      
    if mod(k,1000) == 0
        close all
        graphicsSLAM(xest,estimates.count)
        pause(0.1)
    end
end
toc
close all
graphicsSLAM(xest,estimates.count)
figure, plot(numlandmarks)
mean(numlandmarks)
discontinuaty(xest)
