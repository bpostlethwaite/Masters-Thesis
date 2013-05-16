function konrad(db)

% thickness h
nh=200;
h1=5;
h2=db.hk.hbest - 5;
dh=(h2-h1)/(nh-1);
H=[h1:dh:h2];


%% Line search for H.
p2 = db.pslow.^2;
f1 = sqrt((db.hk.rbest/db.hk.v)^2-p2);
f2 = sqrt((1/db.hk.v)^2-p2);
np = length(p2);
nt = size(db.rec, 1);

gvr = db.rec'; %rotate
gvr = gvr(:); %vectorize

for ih=1:nh
    tps = round( H(ih)*(f1-f2) / db.dt);
    stackh(ih) = mean(gvr(round(tps/dt)+1+[0:np-1]*nt));
end

[hmax,ih]=max(stackh); %#ok<ASGLU>
h2best = H(ih);

tps2 = h2best * (f1 - f2);
tps1 = db.hk.hbest * (f1 - f2);
maxtps = max(tps1);

t1 = 1;
t2 = round((maxtps + 1) /db.dt);

figure(23)
h(1) = subplot(1,2,1);
csection(db.rec(:, 1:t2), 0, db.dt);
hold on
plot(tps1,'k+')
plot(tps2,'k+')
title(sprintf('%s', db.station) )
hold off

h(2) = subplot(1,2,2);
plot(sum(db.rec(:, 1:t2), 1), t1:t2)
set(gca,'YDir','reverse');
ylim([t1, t2])
set(gca,'YTickLabel','')

pos=get(h,'position');
leftedge = pos{1}(1) + pos{1}(3);
pos{2}(1) = leftedge;
pos{2}(3) = 0.5 * pos{2}(3);

set(h(1),'position',pos{1});
set(h(2),'position',pos{2});