function [wft,vft] = TaperWindowFFT(ptrace,strace,header,adj,viewtaper,viewwindow)

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
    
    WIN = zeros(1,length(ptrace{ii}));  % splice taper into a window of zeros to multiply with trace
    WIN( nbegintaper : nbegintaper + length(taper) - 1) = taper;
    
    if viewtaper > 0
        figure(34)
        plot(ptrace{ii}(2,:),WIN,ptrace{ii}(2,:),ptrace{ii}(1,:)./max(ptrace{ii}(1,:)))
        h1 = line([header{ii,1}.T1; header{ii,1}.T1],[-1; 1],...
            'LineWidth',2,'Color',[.8 .8 .2]);
        h2 = line([header{ii,1}.T3;header{ii,1}.T3],[-1,1],...
            'LineWidth',2,'Color',[.8 .2 .8]);
        legend('Window','normalized trace','T1','T3')
        title(sprintf('Trace # %i',ii))
        pause(3)
    end
    
    N = 2^14;
    % Only use 1st half of fft for deconvolution in future
    wft(ii,:) = fft((ptrace{ii}(1,:).*WIN),N);
    if (any(isnan(wft(ii,:))))
        fprintf('NaN values in wft at index %i. You should remove\n',ii)
    end
    %w = fft((ptrace{ii}(1,:).*WIN),N);
    %wft(ii,:) = w(1:2^13 + 1);
    vft(ii,:) = fft(strace{ii}(1,:),N);
    %v = fft(ptrace{ii}(1,:),N);
    %vft(ii,:) = v(1:2^13 + 1);
    waitbar(ii/steps,h)
end

close(h)