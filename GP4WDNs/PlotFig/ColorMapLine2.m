n = 100;
x = linspace(-10,10,n); y = x.^2;
p = plot(x,y,'r', 'LineWidth',5);

%// modified jet-colormap
cd = [uint8(jet(n)*255) uint8(ones(n,1))]';

drawnow
set(p.Edge, 'ColorBinding','interpolated', 'ColorData',cd)