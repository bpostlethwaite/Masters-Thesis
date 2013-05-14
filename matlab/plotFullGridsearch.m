        

hfig = figure(29);
pos1(1) = floor(pos(1)/4);
set(hfig,'OuterPosition',pos1)
csection(db.rec(:, 1 : round(26/db.dt)), 0, db.dt);
hold on
plot(tps,'k+')
plot(tpps,'k+')
plot(tpss,'k+')
title(sprintf('%s', station) )
hold off