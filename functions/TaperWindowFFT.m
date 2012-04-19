function [wft,vft] = TaperWindowFFT(ptrace,strace,header,adj,viewtaper)

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

pad = 0.1;    % make taper x% wider so we don't cut out source function signal
h = waitbar(0,'Windowing Traces');
steps = size(ptrace,1);
n = size(ptrace(1,:),2);
numtr = size(ptrace(1,:),1);
WIN = zeros(numtr,n);  % splice taper into a window of zeros to multiply with trace
dt = header{1}.DELTA;
t = 1:n;

for ii = 1:steps
 
    begintaper = round( (header{ii}.T1 - header{ii}.B)/dt );
    endtaper   = round( (header{ii}.T3 - header{ii}.B)/dt );
    Ntaper = endtaper - begintaper;
    npad = round(pad*Ntaper); % Pad 10% before
    Ntaper = Ntaper + npad; % So we don't cut off useful info
    nbegintaper = begintaper - npad;
    if nbegintaper < 1   % We don't want to index off begining of the trace
        nbegintaper = 1;
    end
    WIN( ii, nbegintaper : nbegintaper + Ntaper - 1) = tukeywin(Ntaper,adj);
    %
    if viewtaper > 0
        t1 = begintaper;
        t3 = endtaper;
        t4 = round( (header{ii}.T4 - header{ii}.B)/dt );
        figure(34)
        plot(t,WIN(ii,:),t,ptrace(ii,:)./max(ptrace(ii,:)))
        line([ t1; t1], [-1; 1], ...
            'LineWidth', 2, 'Color', [.8 .8 .2]);
        line([ t3; t3], [ -1, 1], ...
            'LineWidth', 2, 'Color', [.8 .2 .8]);
        line([ t4; t4], [ -1, 1], ...
            'LineWidth', 2, 'Color', [.8 .4 .4]);
        legend('Window','normalized trace','T1','T3','T4')
        title(sprintf('Trace # %i\nPress Enter to Continue',ii))
        input('Press Enter to Continue\n')
    end
    %}
    wft(ii,:) = fft(ptrace(ii,:).*WIN(ii,:));
    if (any(isnan(wft(ii,:))))
        fprintf('NaN values in wft at. You should remove\n')
    end
    vft(ii,:) = fft(strace(ii,:));
    waitbar(ii/steps,h)
end    
    % Only use 1st half of fft for deconvolution in future
    %wft = fft((ptrace.*WIN)');
    %if (any(isnan(wft)))
    %    fprintf('NaN values in wft at. You should remove\n')
    %end
    %vft = fft(strace');
    %wft = wft'; vft = vft';
    %w = fft((ptrace{ii}(1,:).*WIN),N);
    %wft(ii,:) = w(1:2^13 + 1);
    
    %v = fft(ptrace{ii}(1,:),N);
    %vft(ii,:) = v(1:2^13 + 1);
    

close(h)

end