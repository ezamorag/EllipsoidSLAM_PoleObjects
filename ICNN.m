function H = ICNN(observations, compatibility)

for i=1:observations.m
    if ~isempty(find(compatibility.ICNN(i,:) == 1)) 
        [no_used H(i)]= min(compatibility.Mdist(i,:));
    else
        H(i) = 0;
    end
end