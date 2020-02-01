 t = linspace(0,2*pi,100);
 x = cos(t);
  x1 = cos(2*t);
 y = sin(t);
 z = t;
 c = t;
 colormap(hsv)
 patch([x nan],[y nan],[z nan],[c nan],'FaceColor','none','EdgeColor','interp')
 hold on
  patch([x1 nan],[y nan],[z nan],[c nan],'FaceColor','none','EdgeColor','interp')
 colorbar
 view(3)