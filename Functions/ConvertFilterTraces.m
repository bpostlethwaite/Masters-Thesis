function [ptrace,strace,header,pslows] = ConvertFilterTraces(Dlist,station,rfile,zfile,datadir,picktol,printinfo,saveflag)

% FUNCTION CONVERTFILTERTRACES(DLIST,STATION)
% Converts from sac to Matlab format, rotates coords, collects headers.
% Uses function readsac.m to convert from sac to matlab formats, stores
% header information of each trace. Rotates coordinates from r and z to p
% and s using the function freetran.m
% DLIST is the list of directories to be processed. These should contain
% the sac files and not other directories holding the sac files, ie it is
% not recursive.
% STATION is the name of the station being processed, this is used in the
% saving of the .mat file holding the processed data (3 variables ptrace 
% strace and header).
% RFILE is the sac radial component file name
% ZFILE is the sac vertical component file name
% Both of these should have been previously standardized
% SAVEFLAG > 0 means that we save the data in the appropriate directory

ind1 = 1;
ind2 = 1;

for ii = 1:length(Dlist)
    % Read info from sac files sacfiles
    S1  = readsac(fullfile(Dlist(ii,:),rfile));
    [rtime,rcomp] = readsac(fullfile(Dlist(ii,:),rfile));
    [ztime,zcomp] = readsac(fullfile(Dlist(ii,:),zfile));
    % Convert Each trace (rotate coordinates)
    [p,s] = freetran(rcomp',zcomp',S1.USER0,6.06,3.5,1);
    % Check to make sure picked time interval greater than picktol
    gap = S1.T1 - S1.T3;
    if gap > -picktol
        if printinfo
            fprintf('filtering out data as gap is %f\n',gap)
        end
        % Put all filtered info into super cell poorpicks
        poorpicks{1,ind2} = S1;
        poorpicks{2,ind2} = S1.USER0; %#ok<*AGROW>
        poorpicks{3,ind2} = [p;rtime'];
        poorpicks{4,ind2} = [s;ztime'];
        ind2 = ind2 + 1;
    else
        % Good files go in the respective arrays and cells.
        header{ind1,1} = S1;
        pslows(ind1) = S1.USER0; %#ok<*AGROW>
        ptrace{ind1} = [p;rtime'];
        strace{ind1} = [s;ztime'];
        ind1 = ind1 + 1;
    end
    
end

% Sort by ascending pslows
[pslows,I] = sort(pslows);
header = header(I);
ptrace = ptrace(I);
strace = strace(I);

if saveflag > 0
    save([datadir,'/',station,'.mat'],'ptrace','strace','header','pslows','poorpicks')
end


end