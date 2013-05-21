function konrad(db)

% Set up constants
p2 = db.pslow.^2;
f1 = sqrt( (db.hk.rbest/db.hk.v)^2 - p2);
f2 = sqrt( (1/db.hk.v)^2 - p2);
np = length(p2);
nt = length(db.rec);

%% Line search for H.
nh = 400;
h1 = db.dt / (f1(1) - f2(1));
h2 = db.hk.hbest + 2;
dh = (h2-h1)/(nh-1);
H = h1:dh:h2;

gvr = db.rec'; %rotate
gvr = gvr(:); %vectorize

for ih=1:nh
    tps = H(ih)*(f1-f2);
    %ind = round(tps/db.dt)+1+[0:np-1]*nt;
    %disp(ind)
    stackh(ih) = mean(gvr(round(tps/db.dt)+1+[0:np-1]*nt));
end

% Get the "peaks" of stackh
[maxtab, ~] = peakdet(stackh./max(stackh), 0.3);
if isempty(maxtab)
    return
end
% Sort peaks by amplitude
[~, ix] = sort(maxtab(:, 2), 1, 'descend');
maxtab = maxtab(ix, :);
ih = maxtab(:, 1);

% If a peak detect was "near" ZK Moho estimate remove it from ih
% First, get H(ih) of ZK moho depth
ihk = find(H > db.hk.hbest, 1, 'first');
% Find close entry
rmMOHO = find( abs(ih - ihk) < 2/dh, 1);
% If close entry found remove it
if ~(isempty(rmMOHO))
    ih(rmMOHO) = [];
end
if isempty(ih)
    return
end

for ii = 1:length(ih)
    tps(ii, :) = H(ih(ii)) * (f1 - f2);
end
tpsMOHO = H(ihk) * (f1 - f2);

% Get starting and ending times to use as limits of reciever plot
t1 = h1 * (f1(1) - f2(1));
t2 = h2 * (f1(end) - f2(end));
n1 = round(t1 / db.dt);
n2 = round(t2 / db.dt);


figure(23)
h(1) = subplot(1,2,1);
csection(db.rec(:, n1:n2), t1, db.dt);
hold on
plot(tpsMOHO,'k+')
plot(tps', 'g+')
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
plot(stackh(ih), H(ih), 'go', 'MarkerSize', 15)
hold off
%plot(stackh(ih(1)), H(ih(1)), 'go', 'MarkerSize', 15)
%plot(stackh(ih(2)), H(ih(2)), 'ro', 'MarkerSize', 15)
    
pos=get(h,'position');
leftedge = pos{1}(1) + pos{1}(3);
pos{2}(1) = leftedge;
pos{2}(3) = 0.5 * pos{2}(3);
set(h(1),'position',pos{1});
set(h(2),'position',pos{2});