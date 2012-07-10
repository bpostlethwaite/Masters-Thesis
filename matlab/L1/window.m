function [atoms,sigt] = window(ptrace,strace,header,adj)

% FUNCTION TAPERWINDOW(PTRACE,STRACE,HEADER)
% Windows traces with a tukey window, basically an adjustable cosine window
% PTRACE is the array of p traces
% STRACE is the array of s traces
% HEADER is the header structure with the sac header information.
% ADJ is the adjustable paramater for scaling the taper between a boxcar
% and a hanning cosine window
% VIEWTAPER is the boolean 0/1 which switches on/off viewing of taper to be
% applied to trace
% VIEWWINDOW is the boolean value which switches on/off windowed trace

a = adj;
pad = 0.1;    % make taper x% wider so we don't cut out source function signal
h = waitbar(0,'Windowing Traces');
steps = length(ptrace);
len = 0;

for ii = 1:steps
    l = length(ptrace{ii});
    if l > len
      len = l;
    end
end

p = nextpow2(len);
len = 2^p;
hlen = round(0.5*len);   % half length of signal length

for ii = 1:steps
    
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
    tlen = length(taper);
    htlen = round(0.5*tlen);
    
    atom = zeros(len,1);
    atom(hlen-htlen + 1:hlen-htlen+tlen,1) = ...
        (taper.*ptrace{ii}(1,nbegintaper : nbegintaper + length(taper) - 1))';
    
    ptrace{ii}(1,end+1:len) = 0;
    strace{ii}(1,end+1:len) = 0;
    atoms(:,ii) = atom;
    sigt(:,ii) = strace';

    

end

close(h)