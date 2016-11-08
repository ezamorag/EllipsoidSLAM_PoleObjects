function estimates = add_features(estimates,observations,H)
global noise map
if nargin == 2
    H = 1:observations.m;
end
x = estimates.x;
P = estimates.P;
z = observations.z;

for i=H 
    xnew = x(1:2) + [z(1,i)*cos(z(2,i) + x(3)); 
                     z(1,i)*sin(z(2,i) + x(3))];
    % Verificando que no haya vecinos muy cercanos en el nuevo landmark
    flag = 1;
    for j=1:estimates.n
        if sqrt((xnew(1) - x(2*j+2))^2 + (xnew(2) - x(2*j+3))^2) < map.distmin;
             flag = 0;
             break 
        end
    end
    if flag 
        % Add a landmark
        estimates.n = estimates.n + 1;
        estimates.count = [estimates.count, 1];
        x(end+1:end+2) = xnew;
        sn = sin(z(2,i) + x(3));
        cs = cos(z(2,i) + x(3));
        Dgx = [1 0 -z(1,i)*sn; 0 1 z(1,i)*cs];
        Dgz = [cs, -z(1,i)*sn; sn, z(1,i)*cs];
        P = [P(1:3,1:3),     P(1:3,4:end),     P(1:3,1:3)*Dgx';
             P(4:end,1:3),   P(4:end,4:end),   P(4:end,1:3)*Dgx';
             Dgx*P(1:3,1:3), Dgx*P(1:3,4:end), Dgx*P(1:3,1:3)*Dgx' + Dgz*noise.Rz*Dgz'];
    end
end

estimates.x = x;
estimates.P = P;