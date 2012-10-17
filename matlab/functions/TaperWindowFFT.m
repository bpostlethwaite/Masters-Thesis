function [wft, vft] = TaperWindowFFT(ptrace, strace, ...
    header, adj, viewtaper)

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
steps = size(ptrace,1);
n = size(ptrace, 2);
dt = header{1}.DELTA;
%t = 1:n;

for ii = 1 : steps
    
    begintaper = round( (header{ii}.T1 - header{ii}.B)/dt );
    endtaper   = round( (header{ii}.T3 - header{ii}.B)/dt );
    Ntaper = endtaper - begintaper;
    npad = round(pad*Ntaper); % Pad 10% before
    Ntaper = Ntaper + npad; % So we don't cut off useful info
    nbegintaper = begintaper - npad;
    if nbegintaper < 1   % We don't want to index off begining of the trace
        nbegintaper = 1;
    end
    
    if nbegintaper + Ntaper - 1 >= n % don't want it to be larger than  array
        Ntaper = n - nbegintaper;
    end
    wft(ii,:) = fft(ptrace(ii,:) .* [ zeros(1, nbegintaper),...
            tukeywin(Ntaper,adj)', zeros(1, n - Ntaper - nbegintaper)]);
    vft(ii,:) = fft(strace(ii,:));
    %if (any(isnan(wft(ii,:))))
    %    fprintf('NaN values in wft at. You should remove\n')
    %end
    
end 

end

%     if viewtaper > 0
%         t0 = round( (header{ii}.T0 - header{ii}.B) /dt );
%         t1 = round( (header{ii}.T1 - header{ii}.B) /dt );
%         t2 = round( (header{ii}.T2 - header{ii}.B)/dt );
%         t3 = round( (header{ii}.T3 - header{ii}.B) /dt );
%         figure(34)
%         plot(t,WIN(ii,:),t,ptrace(ii,:)./max(ptrace(ii,:)))
%         line([ t0; t0], [-1; 1], ...
%             'LineWidth', 2, 'Color', [.8 .8 .2]);
%         line([ t1; t1], [ -1, 1], ...
%             'LineWidth', 2, 'Color', [.8 .2 .8]);
%         line([ t2; t2], [ -1, 1], ...
%             'LineWidth', 2, 'Color', [.8 .4 .4]);
%         line([ t3; t3], [ -1, 1], ...
%             'LineWidth', 2, 'Color', [.4 .4 .4]);
%         legend('Window','normalized trace','T0','T1','T2','T3')
%         title(sprintf('Trace # %i\nPress Enter to Continue',ii))
%         input('Press Enter to Continue\n')
%     end
