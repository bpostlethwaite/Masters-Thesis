% conrad pricipal componenet analysis

%clear all; close all
loadtools;
addpath functions
addpath ../sac
addpath([userdir,'/programming/matlab/jsonlab'])
%% Variables
clear X
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
    
    if  numel(strfind(json.(station).status, 'processed-ok'))
        if exist(dbfile, 'file')
            disp(station)
            load(dbfile)
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
figure()
imagesc([1:length(s)], H, X')

[U,S,V] = svd(X);
E = diag(S*S');
 
disp(E(1:10) ./ sum(E))
 
ne = 6;

scale  = 2;%1%5e2;
Vs = [];
for ii = 1:ne
    Vs(:,ii) = V(:,ii)/(max(abs(V(:,ii)))) ; %%S(ii,ii)^2 * V(:,ii);
end

% Flip first component cause its negative
Vs(:,1) = Vs(:,1) * -1;

shift = kron([1:ne]*scale, ones(length(X), 1));

var = E./sum(E);

% figure()
% plot(var(1:10))
% title('Variance captured by first 10 Principal components')
Xs = sum(X);
Xs = Xs/max(abs(Xs));

figure(34)
plot(Xs, H,'k', 'LineWidth', 3)
hold on
%plot(H, sum(Vs'))
plot(Vs + shift, H, 'LineWidth', 2)%, H, pc(:,2))
legend(sprintf('Average Stack', var(1) *100),...
sprintf('PC 1 = %2.1f%%', var(1) *100),...
    sprintf('PC 2 = %2.1f%%', var(2) *100),...
    sprintf('PC 3 = %2.1f%%', var(3) *100),...
    sprintf('PC 4 = %2.1f%%', var(4) *100),...
    sprintf('PC 5 = %2.1f%%', var(5) *100),...
    'Location', 'Best')
xlabel('Principal Component Vector')
ylabel('H [km]')
set(gca,'YDir','reverse');
hold off
 