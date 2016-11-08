function graphicsSLAM(x,count)

N = round((size(x{end},1) - 3)/2);

for i=1:length(x)
    xrobot(:,i) = x{i}(1:3);
end
plot(xrobot(1,:),xrobot(2,:),'k')
xlabel('x (m)'), ylabel('y (m)')


hold on
plot(xrobot(1,1),xrobot(2,1),'g+',xrobot(1,end),xrobot(2,end),'go')

xmap = x{end};
for j=4:2:length(xmap)
    
    if count(round((j-3)/2)) < 40
        color = 'bo';
    elseif count(round((j-3)/2)) < 80
        color = 'bo';
    else 
        color = 'bo';
    end
    plot(xmap(j),xmap(j+1),color)
    
    text(xmap(j)+0.5,xmap(j+1),num2str((j-2)/2),'FontSize',10)
end

hold off
axis([-5 20 -6 8])
grid on
