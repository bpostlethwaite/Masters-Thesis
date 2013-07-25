function plotSlice(station, x, y, xl, yl, s, xstd, ystd, sstd, X, Y, slice)


figure()
set(gca,'FontName','Helvetica','FontSize',16,...
    'Clipping','off','layer','top');
imagesc(X, Y, slice);
axis xy
axis square
colorbar
hold on
plot(x, y, 'w+')
plot(x, y, 'ko')
contour(X, Y, slice, [s - sstd, s - sstd], 'k-')
hold off
xlab=xlabel(xl);
ylab=ylabel(yl);
set(xlab,'FontName','Helvetica','FontSize',16);
set(ylab,'FontName','Helvetica','FontSize',16);
title(sprintf('%s\n%s = %1.3f +/- %1.3f km/s\n%s = %1.3f +/- %1.3f',...
    station, xl, x, xstd, yl, y, ystd));