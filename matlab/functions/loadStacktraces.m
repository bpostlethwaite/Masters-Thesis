function [strace, header, ptrace, pheader, pslows, badpick] = ...
    loadStacktraces(dlist, pfile, slist, sfile, picktol, printinfo)

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
bad = false;
badpick.event = [];
badpick.errmsg = [];
for ii = 1:length(dlist)
    % TRY I/O: Read info from sac files
    %try
        S1  = readsac(fullfile(dlist{ii}, sfile));
        s = S1.DATA1;
        S1 = rmfield(S1, 'DATA1');
        ph = load( fullfile(slist{ii}, pfile));
        p = ph.stack.data' .* tukeywin( length(ph.stack.data) );
        
        % On first pass set N
        if ii == 1
            N = 16384;
        end
        % Truncate if longer
        if length(s) > N || length(p) > N
            s(N+1:end) = [];
            p(N+1:end) = [];
        end
        % Pad with zeros if shorter
        if length(s) < N || length(p) < N
            s(end+1 : N) = 0;
            p(end+1 : N) = 0;
        end
        
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
          
    %catch exception % Skip if we had problems opening it.
    %    bad = true;
    %    emsg = sprintf('Identifier: { %s }\nMessage: { %s } ',...
    %        exception.identifier,exception.message);
    %    disp(emsg)
    %end
    
    if bad
        % Put all filtered info into struct array badpicks
        %badpick.event{ind2} = dlist{ii};
        %badpick.errmsg{ind2} = emsg;
        % Badpick index
        %ind2 = ind2 + 1;
        % Print error message to screen if printinfo = true
        if printinfo
            disp(emsg)
        end
        
    else
        % Good files go in the respective arrays and cells.
        header{ind1} = S1;
        pslows(ind1) = S1.USER0; %#ok<*AGROW>
        strace(ind1,:) = s;
        ptrace(ind1,:) = p ;
        pheader{ind1} = struct('T1', ph.stack.T1,...
            'T3', ph.stack.T3, 'dt', ph.stack.dt);
        ind1 = ind1 + 1;
    end
    
    bad = false;  % Reset our bad/good trace flag.
end

% Sort by ascending pslows
[pslows, I] = sort(pslows);
header = header(I);
pheader = pheader(I);
ptrace = ptrace(I, :);
strace = strace(I,:);

end