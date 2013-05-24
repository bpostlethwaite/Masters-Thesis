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
indh = 1;
indhp = 1;
hcount = 1;
hpcount = 1;

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
        %        func(db, dbfile);
        if isfield(db, 'conrad')
            if isfield(db.conrad, 'hdisc')
                hcount = hcount + 1;
                H = db.conrad.H;
                for jj = 1:length(db.conrad.hdisc)
                    h(indh) = H(db.conrad.hdisc(jj));
                    indh = indh + 1;
                end
                
            end
            if isfield(db.conrad, 'hdiscp')
                hpcount = hpcount + 1;
                H = db.conrad.H;
                for jj = 1:length(db.conrad.hdiscp)
                    hpicked(indhp) = H(db.conrad.hdiscp(jj));
                    indhp = indhp + 1;
                end
            end
            clear db
        end
end
