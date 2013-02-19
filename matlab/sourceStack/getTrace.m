function [trace, header] = getTrace(files)

N = 16384;
for ii = 1:length(files)

    % TRY I/O: Read info from sac files
    S  = readsac(files{ii});
    % Truncate if longer
    if S.NPTS > N
        S.DATA1(N+1:end) = [];
    end
    
    % Pad with zeros if shorter
    if S.NPTS < N
        S.DATA1(end+1 : N) = 0;
    end
    

    trace(ii, :) = S.DATA1; %#ok<*AGROW>
    S = rmfield(S, 'DATA1');
    header{ii} = S;
end



end