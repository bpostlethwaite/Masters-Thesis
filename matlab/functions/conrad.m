function conrad(db, dbfile)

% Set up constants
p2 = db.pslow.^2;
f1 = sqrt( (db.hk.rbest/db.hk.v)^2 - p2);
f2 = sqrt( (1/db.hk.v)^2 - p2);
np = length(p2);
nt = length(db.rec);

%% Line search for H.
nh = 500;
h1 = db.dt / (f1(1) - f2(1));
h2 = db.hk.hbest + 2;
dh = (h2-h1)/(nh-1);
H = h1:dh:h2;

gvr = db.rec'; %rotate
gvr = gvr(:); %vectorize

% Stack
for ih=1:nh
    tps = H(ih)*(f1-f2);
    %ind = round(tps/db.dt)+1+[0:np-1]*nt;
    %disp(ind)
    stackh(ih) = mean(gvr(round(tps/db.dt)+1+[0:np-1]*nt));
end

ihk = find(H > db.hk.hbest, 1, 'first');   
del = 0.5;


% Get peaks from generic del = 0.5 without modification
% ih = conradPeaks(stackh, del, ihk, 2/dh);
% db.conrad.hdisc = H(ih);    

% save(dbfile, 'db')
% disp(['saved', dbfile])
% return



menuItem = true;
while menuItem
% Get closest index of Moho from ZK estimate
    ih = conradPeaks(stackh, del, ihk, 2/dh);
        
    conradPlot(db, ih, ihk, stackh, H, f1, f2)
    menuItem = conradMenu(del);
    
    switch menuItem
        case 0
            disp('next station')
        case 1
            del = input(sprintf('enter new peak DEL value, currently %f1.2\n', del));
        case 2
            del = input('Enter Flags: (S)edimentary (C)onrad\n','s');
            db.conrad.flags = del;
         case 3
            %db.conrad.stackh = stackh;
            db.conrad.hdiscp = H(ih);
            %db.conrad.H = H;
            %db.conrad.del = del;
            save(dbfile, 'db')
            disp('saved')
            menuItem = 0;
        otherwise
            disp('Unknown Input')
    end
end
