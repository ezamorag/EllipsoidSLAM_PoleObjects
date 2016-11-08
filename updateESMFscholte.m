function [estimates new] = updateESMFscholte(estimates,observations,compatibility,H)
global noise
new = [];
for i=1:size(H,2) 
    j = H(i);
    if j > 0    
        % Update the estimates       
        dH = compatibility.dH(2*j-1:2*j,:);      
        phi = dH*estimates.P*dH'/(1-noise.rho) + noise.Rz/noise.rho;
        K = estimates.P*dH'*inv(phi);
        innov = [observations.z(1,i)-compatibility.z(1,j); pi_pi(observations.z(2,i)-compatibility.z(2,j))];
        estimates.x = estimates.x + K*innov;
        
        Ptmp = (estimates.P - K*dH*estimates.P/(1-noise.rho))/(1-noise.rho);
        delta = innov'*inv(dH*(Ptmp/(1-noise.rho))*dH' + noise.Rz/noise.rho)*innov;
        estimates.P = (1-delta)*Ptmp;
        
        estimates.count(j) = estimates.count(j) + 1;
    else
        % only new features with no neighbours
        if compatibility.AL(i) == 0 
            new = [new i];
        end
    end
end





