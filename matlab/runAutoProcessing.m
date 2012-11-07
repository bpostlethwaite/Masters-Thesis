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
s = dir(databasedir);
logfile = fopen('logfile','w');

for ii = 1 : length(s)

    try
        % Get rid of . and .. names
        if length(s(ii).name) < 3
            continue
        end
        
        [~,station,~] = fileparts(s(ii).name);
        
        dbfile = fullfile(databasedir, [station,'.mat'] );
        
        
        clear db dbold
        if exist(dbfile, 'file')
            load(dbfile)
            if  strcmp(json.(station).status,'picked') ||...
                    strcmp(json.(station).status,'processed-notok') || ...
                    strcmp(json.(station).status, 'processed-ok')
            else
                continue
            end
        end
        
        if ~exist('db', 'var')
            db = struct();
        end
        
        workingdir = fullfile(sacfolder,station);
        vp = json.(station).wm.Vp;
        db = process(db, station, workingdir, method, vp);
 
        db.usable = 1;
        
        % Save sequence
        save(dbfile,'db')
        fprintf(logfile, '%s - pass\n',station);
        clear db dbold
        
    catch ME
        fprintf(logfile, '%s - fail\n',station);
        fprintf('%s\n', ME.message)
    end
end