function conradPlot (db, ih, ihk, stackh, H, f1, f2)

if ~isempty(ih)
    ihexist = true;
else
    ihexist = false;
end
tpps = [];
if ihexist
    for ii = 1:length(ih)
        tps(ii, :) = H(ih(ii)) * (f1 - f2);
    end
    if any( H(ih) < 10 )
        Hpps = H( ih( H(ih) < 10) );
        for ii = 1:length(Hpps)
            tpps(ii, :) = Hpps(ii) * (f1 + f2);
        end
    end
end

tpsMOHO = H(ihk) * (f1 - f2);

% Get starting and ending times to use as limits of reciever plot
t1 = H(1) * (f1(1) - f2(1));
t2 = H(end) * (f1(end) - f2(end)); 
n1 = round(t1 / db.dt);
n2 = round(t2 / db.dt);


figure(23)
h(1) = subplot(1,2,1);
csection(db.rec(:, n1:n2), t1, db.dt);
hold on
plot(tpsMOHO,'k+', 'MarkerSize', 12)
if ihexist
        plot(tps', 'g+', 'MarkerSize', 12)
end
if ~isempty(tpps)
    plot(tpps', 'r+', 'MarkerSize', 12)
end
title(sprintf('%s', db.station) )
set(gca, 'TickDir', 'out')
hold off


h(2) = subplot(1,2,2);
plot(stackh, H)
set(gca,'YDir','reverse');
ylim([H(1), H(end)])
%set(gca,'YTickLabel','')
set(gca, 'YAxisLocation', 'right')
set(gca, 'TickDir', 'out')
hold on
plot(stackh(ihk), H(ihk), 'ko', 'MarkerSize', 15)

if ihexist
    plot(stackh(ih), H(ih), 'go', 'MarkerSize', 15)
end

hold off
   
pos=get(h,'position');
leftedge = pos{1}(1) + pos{1}(3);
pos{2}(1) = leftedge;
pos{2}(3) = 0.5 * pos{2}(3);
set(h(1),'position',pos{1});
set(h(2),'position',pos{2});