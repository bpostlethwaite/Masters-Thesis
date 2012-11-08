clear all; close all
loadtools;
addpath functions
addpath([userdir,'/programming/matlab/jsonlab'])
%% Variables
sacfolder = '/media/TerraS/CN';
databasedir = '/media/TerraS/database';

json = loadjson('../stations.json');

%%  Select Station to Process and load station data
method = 'kanamori';
s = fieldnames(json);
logfile = fopen('logfile','w');

for ii = 1 : length(s)

    station = s{ii};
    
   % try
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
                continue
                %db = struct();
            end
            
        else
            %fprintf('skipping %s\n', station)
            continue    
        end
        
       
        workingdir = fullfile(sacfolder,station);
        vp = json.(station).wm.Vp;
        db = process(db, station, workingdir, method, vp);
 
        db.usable = 1;
        
        if (dbold.hk.stdR - db.hk.stdR) > 0.01
        % Save sequence
            save(dbfile,'db')
            fprintf('%s - pass %1.2f\n', station,...
                dbold.hk.stdR - db.hk.stdR);
        end    
        clear db dbold
        
   % catch ME
   %     fprintf(logfile, '%s - fail\n',station);
   %     fprintf('%s %s\n', station, ME.message)
   % end
end