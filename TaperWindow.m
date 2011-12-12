function WIN = TaperWindowFFT(ptrace,strace,header,adj)

% FUNCTION TAPERWINDOW(PTRACE,STRACE,HEADER)
% Windows traces with a tukey window, basically an adjustable cosine window
% PTRACE is the array of p traces
% STRACE is the array of s traces
% HEADER is the header structure with the sac header information.
% ADJ is the adjustable paramater for scaling the taper between a boxcar
% and a hanning cosine window

a = adj;
pad = 0.25;    % make taper x% wider so we don't cut out source function signal
    for ii = 1:length(ptrace)
        
        dt = header{ii,1}.DELTA;
        begintrace = header{ii,1}.B;
        begintaper = header{ii,1}.T1;
        endtaper   = header{ii,1}.T3;

        N = round((endtaper - begintaper)/dt) + round(pad*((endtaper - begintaper)/dt));  % Number of points between picked window 
        n = 0:N;
        nbegintaper = round((begintaper - begintrace)/dt) - round(pad*((endtaper - begintaper)/dt)); % index where taper should begin
        if nbegintaper < 1   % We don't want to index off begining of the trace
            nbegintaper = 1;
        end
        ltaper = 0.5 * (1 + cos(pi * (2 * n(n <= a*(N-1)/2) / (a*(N-1)) - 1 )));  % Tukey window left side
        ctaper = ones(1,length(n (n >= a*(N-1)/2 & n <= (N-1)*(1-a/2)))); % Tukey window centre
        rtaper = 0.5 * (1 + cos(pi * (2*n(n >= (N-1)*(1-a/2) & n <= (N-1)) / (a*(N-1)) - 2/a + 1 ))); % Tukey Rside
        taper = [ltaper,ctaper,rtaper]; % FUll taper
        
        WIN = zeros(1,length(ptrace{ii}(:,2)));  % splice taper into a window of zeros to multiply with trace
        WIN( nbegintaper : nbegintaper + length(taper) - 1) = taper;
        
            
    end