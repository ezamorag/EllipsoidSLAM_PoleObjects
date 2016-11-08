function estimates = pruning(estimates)
global map

[no_used pruning] = find(estimates.count <= map.Npruning);
while ~isempty(pruning)
    j = 2*pruning(1) + 2;
    estimates.x(j:j+1) = [];
    estimates.count(pruning(1)) = [];
    estimates.P = [estimates.P(1:j-1,1:j-1)   estimates.P(1:j-1,j+2:end);
                   estimates.P(j+2:end,1:j-1) estimates.P(j+2:end,j+2:end)];
    estimates.n = estimates.n - 1;
    pruning(1) = [];
    pruning = pruning - 1;
end