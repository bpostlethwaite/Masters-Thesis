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
method = 'kanamori';
s = fieldnames(json);

func = @konrad;

for ii = 40 : length(s)

    station = s{ii};
 %  try
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
        
        func(db)    
        pause()
        
%    catch ME
%          fprintf('%s %s\n', station, ME.message)
%          continue
%    end
end