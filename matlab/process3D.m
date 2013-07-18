% Automatic Kanamori Algorithm

NUM = 1;

fid = fopen('processed-ok.list');
ix = 1;
stns{ix} = fgetl(fid);
 
while ischar(stns{ix})
    ix = ix + 1;  
    stns{ix} = fgetl(fid);
end
stns(end) = [];
fclose(fid);

databasedir = '/mnt/backup/backup/bpostlet/TerraS/database';

if ~matlabpool('size')
    workers = 7;
    matlabpool('local', workers)
end

ns = round(length(stns) / 3);

for ii = ((NUM - 1) * ns + 1) : ns * NUM
    if (ii > length(stns))
        continue
    end
    station = stns{ii};
    disp(['processing', station])
    
    load(fullfile(databasedir, station));
        
    [ v, r, h, smaxss] = gridsearch3DC(db.rec', db.dt, db.pslow, 150);
    [Vp, R, H, SMax] = bootstrap3D(db.rec, db.dt, db.pslow, 150, 1);    
 
    save(['data/',station,'.mat'], 'v', 'r', 'h', 'Vp', 'R', 'H', 'SMax')

end


matlabpool close