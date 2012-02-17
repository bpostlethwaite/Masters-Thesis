function [ptrace,strace,header,pslows,badpick] = ...
    ConvertFilterTraces(Dlist,station,rfile,zfile,datadir,picktol,printinfo,saveflag)

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
bad = false;

for ii = 1:length(Dlist)
    % TRY I/O: Read info from sac files
    try
        S1  = readsac(fullfile(Dlist(ii,:),rfile));
        [rtime,rcomp] = readsac(fullfile(Dlist(ii,:),rfile));
        [ztime,zcomp] = readsac(fullfile(Dlist(ii,:),zfile));
        % Convert Each trace (rotate coordinates)
        [p,s] = freetran(rcomp',zcomp',S1.USER0,6.06,3.5,1);
        
        % Check to make sure picked time interval greater than picktol and
        % That the starting time in the record header matches the picks (make
        % sure it makes sense (Both T1 and T3 must be greater that record
        % beginning), and of course that T1 and T3 are numbers.        
        if isempty(S1) % Skip if we get nothing
            bad = true;
            emsg = sprintf('Headers and possibly data containers empty\n');
        else
            gap = S1.T1 - S1.T3;
            
            if gap > -picktol
                bad = true;
                emsg = sprintf('filtering out data as gap is %f\n',gap);
                
            elseif S1.T1 < S1.B || S1.T3 < S1.B
                bad = true;
                emsg = sprintf(['Picked times T1=%s or T3=%s less than beginning of'...
                    'trace record %s. Filtering.\n'],S1,T1,S1.T3,S1.B);
                
            elseif isnan(S1.T1) || isnan(S1.T3)
                bad = true;
                emsg = sprintf('One or both of T1 and T3 is not numeric\n');
            end
        end
        
        
    catch exception % Skip if we had problems opening it.
        bad = true;
        emsg = exception.identifier;
    end
    

    if bad
        % Put all filtered info into struct array badpicks
        badpick.event(ind2) = {Dlist(ii,:)};
        badpick.errmsg(ind2) = {emsg};
        % Badpick index
        ind2 = ind2 + 1;
        % Print error message to screen if printinfo = true
        if printinfo
            disp(emsg)
        end
        
    else
        % Good files go in the respective arrays and cells.
        header{ind1,1} = S1;
        pslows(ind1) = S1.USER0; %#ok<*AGROW>
        ptrace{ind1} = [p;rtime'];
        strace{ind1} = [s;ztime'];
        ind1 = ind1 + 1;
    end
    
    bad = false;  % Reset our bad/good trace flag.
end

% Sort by ascending pslows
[pslows,I] = sort(pslows);
header = header(I);
ptrace = ptrace(I);
strace = strace(I);

end