function [e_avg e] = ComputingError(t_loc,x_loc,t_est,xest)
% Input: t_loc vector (n,1)
%        t_est vector (m,1)
%        x_loc matrix (n,2)
%        xest  m cells with vectors (2*N+3 states)

% Output: e_avg error average
%         e error vector (m,1)
%         The errors are calculated at time t_est

for i=1:length(xest)
    x_robot(i,:) = xest{i}(1:2)';
end

% Sincronización (Asumo que n > m)
n = length(t_loc);
m = size(t_est,1);
k = 1;
for i=1:m
    [no_used id] = min(abs(t_loc - t_est(i)));
    if abs(t_loc(id) - t_est(i)) <= 0.1   %Solo comparamos puntos casi simultaneos <0.1seg de diferencia.
        i_est(k) = i;
        i_loc(k) = id;
        k = k + 1;
    end
end
%figure, plot(t_loc(i_loc) - t_est(i_est)) for debugging

e = sqrt((x_loc(i_loc,1) - x_robot(i_est,1)).^2 + (x_loc(i_loc,2) - x_robot(i_est,2)).^2);
e_avg = 1/m*sum(e);
figure, plot(t_est(i_est),e), xlabel('time (s)'), ylabel('error (m)')