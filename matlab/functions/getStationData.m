function [data] = getStationData(json, regions) 
% GETSTATIONDATA gets json data for specifed region and json file.

data.lat = []; data.lon = [];
data.stn = {};

s = loadjson(json);
fn = fieldnames(s);

%% Get stations.json data 
if ~isempty(strfind(json, 'stations.json'))

    data.R = []; data.H = [];
    
    for strng = fn'
        str = char(strng);
        % All stns should have geoprov field (ie within Canada)
        if ~isfield(s.(str), 'geoprov')
            continue
        end
        % Skip stations not within region of interest
        if ~any(strcmp(s.(str).geoprov, regions))
            continue
        end
        if ~strcmp(s.(str).status, 'processed-ok')
            continue
        end
        % Skip mirror stations (take the best one)
        % Could average these stations.
        if any(strcmp(str, {'YKW2','YKW4','YKW5'}))
            %fprintf('Skipping %s station\n', str)
            continue
        end
        if isfield(s.(str), 'hk')
            
            data.stn{end+1} = str;
            data.lat(end+1) = s.(str).lat;
            data.lon(end+1) = s.(str).lon;
            data.R(end+1) = s.(str).hk.R;
            data.H(end+1) = s.(str).hk.H;
        end
    end
        
    %% Get Mooney Vp shot data R = Vp
    %
elseif ~isempty(strfind(json, 'moonvpGeology.json'))
    
    data.R = []; data.H = [];
    
    for strng = fn'
        str = char(strng);
        % All stns should have geoprov field (ie within Canada)
        if ~isfield(s.(str), 'geoprov')
            continue
        end
        % Skip stations not within region of interest
        if ~any(strcmp(s.(str).geoprov, regions))
            continue
        end
 
        data.stn{end+1} = str;
        data.lat(end+1) = s.(str).lat;
        data.lon(end+1) = s.(str).lon;
        data.R(end+1) = s.(str).Vp; %This is because it has NO R
        % is just setup to work on two variables - might change it though
        data.H(end+1) = s.(str).H;
    end
    
    %% Get Crust 2.0 / 1.0 Data
else
    data.Vp = []; data.H = []; data.R = [];
     for strng = fn'
        str = char(strng);
        % All stns should have geoprov field (ie within Canada)
        if ~isfield(s.(str), 'geoprov')
            continue
        end
        % Skip stations not within region of interest
        if ~any(strcmp(s.(str).geoprov, regions))
            continue
        end
 
        data.stn{end+1} = str;
        data.lat(end+1) = s.(str).lat;
        data.lon(end+1) = s.(str).lon;
        data.R(end + 1) = s.(str).R;
        data.H(end+1) = s.(str).H;
        data.Vp(end+1) = s.(str).Vp;
    end
end

end