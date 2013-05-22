%clear all; close all
loadtools;
addpath functions
addpath ../sac
addpath([userdir,'/programming/matlab/jsonlab'])
%% Variables
sacfolder = '/media/TerraS/CN';
databasedir = '/media/TerraS/database';
if ~exist('json', 'var')
    json = loadjson('../data/stations.json');
end
%%  Select Station to Process and load station data
s = fieldnames(json);

func = @conrad;
ind = 1;
for ii = 1 : length(s)

    station = s{ii};

        dbfile = fullfile(databasedir, [station,'.mat'] );
       
        if  numel(strfind(json.(station).status, 'processed'))
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
        %func(db, dbfile);
        if isfield(db, 'conrad')
            if isfield(db.conrad, 'ih')
                H = db.conrad.H;
                for jj = 1:length(db.conrad.ih)
                    hpoints(ind) = H(db.conrad.ih(jj));
                    ind = ind + 1;
                end
            end
            clear db
        end
end
