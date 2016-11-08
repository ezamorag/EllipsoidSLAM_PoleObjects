function landmarks = extract_poles(laserscan) 
% laserscan is 1xN vector that contains range mesurements in meters.
% landmarks is 3xn matrix, where
% landmarks(1,i) is distance from sensor to i-landmark center, in meters
% landmarks(2,i) is angle of i-landmark center (in radians)
% landmarks(3,i) is i-landmark diameter

global LRF
drmin = 0.3; 	         % Minimum change of distance (dr) to separate clusters
dphimin = 2*pi/180;      % Minimum angular change (dphi) to separate clusters

Edistmin = 0.3;		     % Minimum Euclidean distance allowed between two clusters 
Angdistmin = 3*pi/180;   % Minimum angular distance allowed between two clusters 

distEndpointsmax = 1.0;  % Maximum distance allowed between the cluster's endpoints 

Closestdist = 0.2;       % The closest distance allowed to detect clusters 
angSector = 0*pi/180;    % Angular sector unallowed to detect clusters


% Delete spurious measurements (with no reflections)
ival=find(laserscan<LRF.rmax);
L1 = length(ival); 
if L1<1 
    landmarks=[]; 
    return 
end
R1 = laserscan(ival); A1 = LRF.angles(ival);

% Clustering and identifying the endpoints of each cluster 
itrans = find((abs(diff(R1))>drmin)|(diff(A1)>dphimin));
Nclusters = length(itrans)+1;
iend = int16([itrans,L1]);
ibegin  = int16([1,itrans+1]);
Rbegin  = R1(ibegin); Abegin  = A1(ibegin); 
Rend = R1(iend); Aend = A1(iend); 
xbegin  =  Rbegin.*cos(Abegin);  ybegin =  Rbegin.*sin(Abegin);
xend = Rend.*cos(Aend); yend = Rend.*sin(Aend);
%hold on, plot(xend,yend,'k+')

% Identifying the closest clusters each other in terms of Euclidean distance (searching in 3 neighbors)
flagCluster = zeros(1,Nclusters);
L3 = 0; M3c = Edistmin*Edistmin;
if Nclusters > 1 % First Neighbor
    dx2 = xbegin(2:Nclusters)-xend(1:Nclusters-1);  dy2 = ybegin(2:Nclusters)-yend(1:Nclusters-1); 
    dl2 = dx2.*dx2 + dy2.*dy2;
    iaux = find(dl2 < M3c); L3 = length(iaux);
    if L3>0, flagCluster(iaux)=1; flagCluster(iaux+1)=1; end

    if Nclusters > 2 % Second Neighbor
        dx2 = xbegin(3:Nclusters)-xend(1:Nclusters-2);  dy2 = ybegin(3:Nclusters)-yend(1:Nclusters-2); 
        dl2 = dx2.*dx2 + dy2.*dy2;
        iaux = find(dl2<M3c); L3b=length(iaux);
        if L3b>0, flagCluster(iaux)=1; flagCluster(iaux+2)=1; L3=L3+L3b; end

        if Nclusters > 3 % Third Neighbor
            dx2 = xbegin(4:Nclusters)-xend(1:Nclusters-3);  dy2 = ybegin(4:Nclusters)-yend(1:Nclusters-3); 
            dl2 = dx2.*dx2 + dy2.*dy2;
            iaux = find(dl2<M3c); L3b=length(iaux);
            if L3b>0, flagCluster(iaux)=1; flagCluster(iaux+3)=1 ;L3=L3+L3b; end
        end
    end
end

% Identifying the closest clusters each other in terms of angular distance 
if Nclusters>1 
    iaux = 1:Nclusters-1;
    iaux = find((Abegin(iaux+1)-Aend(iaux))<Angdistmin ); 
    L3b = length(iaux);
    if L3b>0
        ff = Rbegin(iaux+1)>Rend(iaux);		      
        iaux=iaux+ff;
        flagCluster(iaux)=1;		                  
        L3=L3+L3b;
    end 
end

% Delete the closest clusters each other
if L3>0
    iaux=find(flagCluster==0);
    ibeginf = double(ibegin(iaux)); iendf = double(iend(iaux));
    Rbeginf  = Rbegin(iaux); Rendf = Rend(iaux);
    Abeginf  = Abegin(iaux); Aendf = Aend(iaux);
    xbeginf  = xbegin(iaux); ybeginf = ybegin(iaux);
    xendf = xend(iaux); yendf = yend(iaux);
else
    ibeginf = double(ibegin); iendf = double(iend);
    Rbeginf = Rbegin; Rendf = Rend;
    Abeginf = Abegin; Aendf = Aend;
    xbeginf = xbegin; ybeginf = ybegin;
    xendf = xend; yendf = yend;
end
%hold on, plot(xendf,yendf,'k+')

% Delete the large clusters
dx2 = xbeginf - xendf;  dy2 = ybeginf - yendf; 
dl2 = dx2.*dx2 + dy2.*dy2;
ii5 = find(dl2<(distEndpointsmax*distEndpointsmax)); L5 = length(ii5); 
if L5<1, landmarks=[]; return, end 
R5 = Rbeginf(ii5); R5u = Rendf(ii5); A5 = Abeginf(ii5); A5u = Aendf(ii5); ibeginf=ibeginf(ii5); iendf=iendf(ii5);
%hold on, plot(R5u.*cos(A5u),R5u.*sin(A5u),'k+')

% Delete the closest clusters to sensor and to angular periphery
ii5 = find((R5>Closestdist)&(A5>LRF.angles(1) + angSector)&(A5u<LRF.angles(end) - angSector));     
L5 = length(ii5); 
if L5<1, landmarks=[]; return, end
R5 = R5(ii5); R5u = R5u(ii5); A5 = A5(ii5); A5u = A5u(ii5); ibeginf=ibeginf(ii5); iendf=iendf(ii5);
%hold on, plot(R5u.*cos(A5u),R5u.*sin(A5u),'ko')

% Detect the clusters that appear pole-like object
dL5 = (A5u + 0*pi/180 - A5).*(R5 + R5u)/2; 
compa = abs(R5-R5u)<dL5;	% why?????
ii5 = find(compa); L5 = length(ii5); 
if L5<1, landmarks=[]; return, end
R5 = R5(ii5); R5u = R5u(ii5); A5 = A5(ii5); A5u = A5u(ii5); ibeginf=ibeginf(ii5); iendf=iendf(ii5);
dL5 =dL5(ii5);

% Compute the position (distance,angle) and the diameter of landmarks
auxi = (ibeginf+iendf)/2;
iia = floor(auxi);
iib = ceil(auxi);
Rs = (R1(iia)+R1(iib))/2;
landmarks = [ Rs+dL5/2;(A5+A5u)*0.5; dL5]; 






