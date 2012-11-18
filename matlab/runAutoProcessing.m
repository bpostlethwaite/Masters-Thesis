clear all; close all
loadtools;
addpath functions
addpath([userdir,'/programming/matlab/jsonlab'])
%% Variables
sacfolder = '/media/TerraS/CN';
databasedir = '/media/TerraS/database';

json = loadjson('../data/stations.json');

%%  Select Station to Process and load station data
method = 'kanamori';
s = fieldnames(json);
logfile = fopen('logfile','w');

for ii = 1 : length(s)

    station = s{ii};
   try
        % Get rid of . and .. names
        if length(s{ii}) < 3
            fprinf('skipping %s\n', station)
            continue
        end
        
        dbfile = fullfile(databasedir, [station,'.mat'] );
       
        clear db dbold
        if  strfind(json.(station).status, 'processed') 
            if exist(dbfile, 'file')
                load(dbfile)
                dbold = db;
            else
                %db = struct();
                continue
            end
            
        else
            %fprintf('skipping %s\n', station)
            continue    
        end
        
        if isfield(dbold.hk,'c0R')
            continue
        end
        
        workingdir = fullfile(sacfolder,station);
        vp = json.(station).wm.Vp;
        for qq = 1:2
            db0 = process(db, station, workingdir, method, vp, 0);
            db1 = process(db, station, workingdir, method, vp, 1); 
        end
       
        db.hk.c0R = db0.hk.rbest;
        db.hk.c1R = db1.hk.rbest;
        
     	fprintf('station: %s\n c0 R: %1.3f\n c1 R: %1.3f\n stdR: %1.3f\n',...
                station,db0.hk.rbest, db1.hk.rbest, dbold.hk.stdR )
%        db.usable = 1;
        
%        if (dbold.hk.stdR - db.hk.stdR) > 0.01
        % Save sequence
         save(dbfile,'db')
%            fprintf('%s - pass %1.2f\n', station,...
%                dbold.hk.stdR - db.hk.stdR);
%        end    
        
   catch ME
   %     fprintf(logfile, '%s - fail\n',station);
         fprintf('%s %s\n', station, ME.message)
         continue
   end
end