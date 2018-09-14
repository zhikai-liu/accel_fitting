function fitting_ellipse(x,y)
F=fittype('sqrt(a.^2.*cos(c-x).^2+b.^2.*sin(c-x).^2)','independent','x');
fit(x,y,F)
end