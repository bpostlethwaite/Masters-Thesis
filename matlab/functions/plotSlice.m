function plotSlice(station, x, y, xl, yl, s, xstd, ystd, sstd, X, Y, slice)

% set(gca,'FontName','Helvetica','FontSize',16,...
%     'Clipping','off','layer','top');
pcolor(X, Y, slice);
axis xy
axis square
shading interp
hold on
plot(x, y, 'w+')
plot(x, y, 'ko')
[~, H] = contour(X, Y, slice, [s - sstd, s - sstd], 'w-');
set (H, 'LineWidth', 1.2);
hold off
if ~isempty(xl)
    xlab=xlabel(xl);
end
if ~isempty(yl)
    ylab=ylabel(yl);
end
% set(xlab,'FontName','Helvetica','FontSize',16);
% set(ylab,'FontName','Helvetica','FontSize',16);
% title(sprintf('%s\n%s = %1.3f +/- %1.3f km/s\n%s = %1.3f +/- %1.3f',...
%     station, xl, x, xstd, yl, y, ystd));