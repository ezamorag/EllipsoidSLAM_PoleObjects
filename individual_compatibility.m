function compatibility = individual_compatibility(estimates,observations)
global noise map
% ICNN es una matriz m observaciones por N landmarks, que determina que
% pares son compatibles en el espacio de observación.

% AL contiene el numero de asociadas aceptadas individualmente por cada
% observación

% Pre-compute z, H, Mdist
z = [];
dH = [];
for j = 1:estimates.n  
    dx = estimates.x(2*j+2) - estimates.x(1);
    dy = estimates.x(2*j+3) - estimates.x(2);
    q = dx^2 + dy^2;
    z(:,j) = [sqrt(q); atan2(dy,dx) - estimates.x(3)];
    Hx = [-dx/sqrt(q) -dy/sqrt(q) 0; dy/q -dx/q -1];
    Hmk = [dx/sqrt(q) dy/sqrt(q); -dy/q dx/q]; 
    dH(2*j-1:2*j,:) = [Hx, zeros(2,2*j-2), Hmk, zeros(2,2*estimates.n-2*j)];
end 

Mdist = [];
for i=1:observations.m
    for j = 1:estimates.n 
        % Mahalanobis distance
        phi = dH(2*j-1:2*j,:)*estimates.P*dH(2*j-1:2*j,:)' + noise.Rz;
        innov = [observations.z(1,i)-z(1,j); pi_pi(observations.z(2,i)-z(2,j))];
        Mdist(i,j) = innov'/phi*innov;
    end      
end
compatibility.z = z;
compatibility.dH = dH;
compatibility.Mdist = Mdist;
compatibility.ICNN = (Mdist <=  map.chi2);
compatibility.AL = (sum(compatibility.ICNN, 2))';


