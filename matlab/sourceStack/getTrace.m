function [trace, header] = getTrace(files)

N = 16384;
for ii = 1:length(files)
    
    % TRY I/O: Read info from sac files
    S1  = readsac(files{ii});
    [~,p] = readsac(files{ii});
    
    % Truncate if longer
    if length(p) > N
        p(N+1:end) = [];
    end
    
    % Pad with zeros if shorter
    if length(p) < N
        p(end+1 : N) = 0;
    end
    
    % Good files go in the respective arrays and cells.
    header{ii} = S1; %#ok<*AGROW>
    trace(ii, :) = p;
    
end



end