function discontinuaty(xest)

for ku=2:length(xest)
    d(ku) = sqrt((xest{ku}(1) - xest{ku - 1}(1))^2 + (xest{ku}(2) - xest{ku - 1}(2))^2);
    dth(ku) = xest{ku}(3) - xest{ku - 1}(3);
end
figure
subplot(2,2,1), plot(d)
subplot(2,2,2), plot(dth)
subplot(2,2,3), hist(d, min(d):0.001:max(d))
subplot(2,2,4), hist(dth, min(dth):0.0001:max(dth))