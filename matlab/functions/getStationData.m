function [data] = getStationData(json, regions, cutoff) 
% GETSTATIONDATA gets json data for specifed region and json file.

data.lat = []; data.lon = [];
data.R = []; data.H = [];
data.stn = {};

s = loadjson(json);
fn = fieldnames(s);

%% Get stations.json data 
if ~isempty(strfind(json, 'stations.json'))
    
    for strng = fn'
        str = char(strng);
        % All stns should have geoprov field (ie within Canada)
        if ~isfield(s.(str), 'geoprov')
            continue
        end
        % Skip mirror stations (take the best one)
        % Could average these stations.
        if any(strcmp(str, {'YKW2','YKW4','YKW5'}))
            %fprintf('Skipping %s station\n', str)
            continue
        end
        % Skip stations not within region of interest
        if ~any(strcmp(s.(str).geoprov, regions))
            continue
        end
        if isfield(s.(str), 'hk')

            if s.(str).hk.stdR < cutoff                
                data.stn{end+1} = str;
                data.lat(end+1) = s.(str).lat;
                data.lon(end+1) = s.(str).lon;
                data.R(end+1) = s.(str).hk.R;
                data.H(end+1) = s.(str).hk.H;
            end
        end
    end
    
    
    
    
    %% Get Mooney Vp shot data R = Vp
    %
else
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
        if s.(str).Vp < cutoff
            continue
        end
        data.stn{end+1} = str;
        data.lat(end+1) = s.(str).lat;
        data.lon(end+1) = s.(str).lon;
        data.R(end + 1) = s.(str).Vp;
        data.H(end+1) = s.(str).H;
    end
end

end