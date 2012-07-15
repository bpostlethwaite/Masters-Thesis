% Bootstap performs bootsrap error calculations on given station and
% updates the json with the results. It uses an environmental variable as
% communication to determine which station to process.
% The program is meant to be called by external programs.

setenv('STATION','SADO')
home = getenv('HOME');
station = getenv('STATION');
addpath([home,'/thesis/matlab/functions']);

% Set JSON options
opt.FileName = [home,'/thesis/stations.json'];
opt.ForceRootName = 0;

databasedir = '/media/TerraS/database';
dbfile = fullfile(databasedir, [station,'.mat'] );

if exist(dbfile, 'file')
    load(dbfile)
    rec = db.rec;
    Tps = db.Tps';
    dt = db.dt;
    pslow = db.pslow;
else
    fprintf('No station in the database. Exiting\n')
    %exit
end
nmax = 1000;
n = size(db.rec, 1);
Vp = zeros(1,1000);
R = Vp;
H = Vp;
fprintf('    ');

%[Vp, R] = gridsearch( rec', Tps, dt, pslow);
%[Vpold, Rold, H] = fastgrid( rec, Tps, dt, pslow);

for ii = 1:nmax
    ind = randi(n, n, 1);
    [Vp(ii),R(ii)] = gridsearch( rec(ind, :)', Tps(ind), dt, pslow(ind) );
    fprintf('\b\b\b\b%2.1f%', ii/nmax * 100)
end