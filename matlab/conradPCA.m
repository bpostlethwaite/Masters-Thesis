% conrad pricipal componenet analysis

%clear all; close all
loadtools;
addpath functions
addpath ../sac
addpath([userdir,'/programming/matlab/jsonlab'])
%% Variables
clearvars -except json
sacfolder = '/media/bpostlet/TerraS/CN';
databasedir = '/media/bpostlet/TerraS/database';
if ~exist('json', 'var')
    json = loadjson('../data/stations.json');
end
%%  Select Station to Process and load station data
s = fieldnames(json);

PLOT = false;
idx = 1;

for ii = 1 : length(s)
    
    station = s{ii};
    
    dbfile = fullfile(databasedir, [station,'.mat'] );
    
    if  numel(strfind(json.(station).status, 'processed'))
        if exist(dbfile, 'file')
            disp(station)
            load(dbfile)
            
            if db.hk.stdR > 0.06
                fprintf('skipping %s\n', station)
                continue
            end
        else
            continue
        end
        
    else
        fprintf('skipping %s\n', station)
        continue
    end
    %% Application logic
    % Set up constants
    p2 = db.pslow.^2;
    f1 = sqrt( (db.hk.rbest/db.hk.v)^2 - p2);
    f2 = sqrt( (1/db.hk.v)^2 - p2);
    np = length(p2);
    nt = length(db.rec);
    
    %% Line search for H.
    nh = 500;
    h1 = .1; %db.dt / (f1(1) - f2(1));
    h2 = 50; %;db.hk.hbest + 2;
    dh = (h2-h1)/(nh-1);
    H = h1:dh:h2;
%     
    gvr = db.rec'; %rotate
    gvr = gvr(:); %vectorize
    
    % Stack
    for ih= 1:length(H)
        tps = H(ih)*(f1-f2);
        %ind = round(tps/db.dt)+1+[0:np-1]*nt;
        %disp(ind)
        stackh(ih) = mean(gvr(round(tps/db.dt)+1+[0:np-1]*nt));
    end
    
   
    
    % Note, that we are using all processed stations not processed-ok
    X(idx, :) = stackh;

    % Going to sort by Moho
    moho(idx) = db.hk.hbest;
    stations{idx} = station;
    
    idx = idx + 1;
    
    if (PLOT)

        t1 = H * (f1(1) - f2(1));
        t2 = H(end) * (f1(end) - f2(end));
        n1 = round(t1 / db.dt);
        n2 = round(t2 / db.dt);
        
        figure(23)
        h(1) = subplot(1,2,1);
        csection(db.rec(:, n1:n2), t1, db.dt);
        hold on
        plot(db.hk.tps,'k+', 'MarkerSize', 12)
        plot(db.hk.tps', 'g+', 'MarkerSize', 12)
        plot(db.hk.tpss', 'r+', 'MarkerSize', 12)
        
        title(sprintf('%s', db.station) )
        set(gca, 'TickDir', 'out')
        hold off
        
        
        h(2) = subplot(1,2,2);
        plot(stackh, db.hk.hRange)
        set(gca,'YDir','reverse');
        ylim([db.hk.hRange(1), db.hk.hRange(end)])
        %set(gca,'YTickLabel','')
        set(gca, 'YAxisLocation', 'right')
        set(gca, 'TickDir', 'out')
        
        pos=get(h,'position');
        leftedge = pos{1}(1) + pos{1}(3);
        pos{2}(1) = leftedge;
        pos{2}(3) = 0.5 * pos{2}(3);
        set(h(1),'position',pos{1});
        set(h(2),'position',pos{2});
        
        
        pause()
    end
end 


%%
close all
%X = zscore(X);
%figure()
%imagesc([1:length(s)], H, X')

% Sort X by increasing moho depth
[moho, imoho] = sort(moho);
X = X(imoho, :);
stations = stations(imoho);

X = spdiags(1./sqrt(sum(X.^2,2)),0,idx-1,idx-1)*X;

[U,S,V] = svd(X);

% EigenValues
E = diag(S*S');

%% Scroll through image X vs X projected onto modes n = 1->end



%Xn = spdiags(1./sqrt(sum(X.^2,2)),0,idx-1,idx-1)*X;

mask = zeros(idx-1, nh);

hwin1 = H(1);
hwin2 = H(end);

%hwin1 = 10;
%hwin2 = 30;

win1 = find(H >= hwin1, 1, 'first');
win2 = find(H <= hwin2, 1, 'last');
%{
for ii = 1:length(stations)
    mask(ii, ii) = S(ii, ii);
    
    Xproj = U*mask*V';
    %Xproj = spdiags(1./sqrt(sum(Xproj.^2,2)),0,idx-1,idx-1)*Xproj;
    
    var = sum( E(1:ii) / sum(E) ) * 100;
    
    figure(1234)
    subplot(2,1,1)
        imagesc(1:nh, H(win1:win2), X(:, win1:win2)')
        cax = caxis;
    subplot(2,1,2)
        imagesc(1:nh, H(win1:win2), Xproj(:, win1 : win2)')   
        caxis(cax)
        title(sprintf('adding %i modes capturing %2.1f%% variance', ii, var))
    pause()
end
%}
%% Interpolate and Stretch

midx = zeros(1, length(moho));

ninterp = 500;

xi = 1:500; % Set for xor'ing later

XI = zeros(length(stations), ninterp);

maxq = 1;

for qq = 1:maxq
    
    for ii = 1:length(moho)
        midx(ii) = find(H >= moho(ii), 1, 'first');
    end

    for ii = 1:length(midx)

        ntoshift = ninterp - midx(ii);
        x = 1:midx(ii); % Vector representing indicies of profile
        vx = X(ii, 1:midx(ii));

        for jj = 1:ntoshift
            ridx = randi([2, midx(ii) - 1], 1);
            x(ridx:end) = x(ridx:end) + 1; % Shift indices one for each insert
        end

        qx = setxor(x, xi);

        vq = interp1(x, vx, qx);

        XI(ii, x) = XI(ii, x) + vx;
        XI(ii, qx) = XI(ii, qx) + vq;

    end
end


profile =  sum(sqrt(XI.^2),1)';
profile =  sum(abs(XI),1)';

profile = profile;

figure(23)
h(1) = subplot(1,2,1);
    imagesc(XI')

    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    set(gca,'YTickLabel','')
    set(gca,'XTickLabel','')
    %set(gca, 'TickDir', 'out')

h(2) = subplot(1,2,2);
    plot(profile, xi, 'LineWidth', 2)
    hold on
    line([mean(profile), mean(profile)],[xi(1), xi(end)], 'Color', [0.7,0.7,0.7])
    hold off
    set(gca,'YDir','reverse');
    ylim([xi(1), xi(end)])
    set(gca,'YTickLabel','')
    set(gca,'XTickLabel','')
    set(gca, 'YAxisLocation', 'right')
    %set(gca, 'TickDir', 'out')
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    
pos=get(h,'position');
leftedge = pos{1}(1) + pos{1}(3);
pos{2}(1) = leftedge;
pos{2}(3) = 0.7 * pos{2}(3);
set(h(1),'position',pos{1});
set(h(2),'position',pos{2});


% figure()
% subplot(1,2,1)
%     imagesc(XI')
% subplot(1,2,2)
%     plot( sum(sqrt(XI.^2),1)', 'LineWidth', 2)
figure()
    imagesc(X')

%% Plot Modes

ne = 10;

Vs = V(:, 1:ne);
vmax = max(max(abs(Vs)));

scale  = vmax + 0.2*vmax;

shift = kron([1:ne]*scale, ones(length(X), 1));

var = E./sum(E);

Xs = sum(X);
Xs = Xs/max(abs(Xs));

figure(34)

plot(Vs + shift, H, 'LineWidth', 2)

axis tight
ylabel('H [km]')
set(gca,'YDir','reverse');
set(gca,'TickLength', [0 0]);

hold on
% Box 
lim = xlim;
H1 = 20;
H2 = 30;
p=patch([lim(1) lim(1) lim(2) lim(2)],[H1 H2 H2 H1],'k',...
     'EdgeColor', 'none','FaceColor',[0.9, 0.9, 0.9],...
    'FaceAlpha',0.5);


for ii = 1:ne
  line([shift(1,ii),shift(1,ii)],[H(1), H(end)], 'Color', [0.7,0.7,0.7])
end
hold off


pos = get(gca,'Position');
set(gca,'Position',[pos(1), .15, pos(3) .75])

clear tickLabels
for ii = 1:ne
    tickLabels{ii} = sprintf('PC %1.0d \n %2.1f%%', ii, var(ii) *100);
end

% Set xtick points
Xt = shift(1,:) + 0.2*vmax;
set(gca,'XTick',Xt);

ax = axis; % Current axis limits
axis(axis); % Set the axis limit modes (e.g. XLimMode) to manual
Yl = ax(3:4); % Y-axis limits

% Place the text labels
t = text(Xt,Yl(2)*ones(1,length(Xt)),tickLabels,'FontSize',14);
set(t,'HorizontalAlignment','right','VerticalAlignment','top');% ...

% Remove the default labels
set(gca,'XTickLabel','')
