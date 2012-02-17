%ProcessTraces
% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.


%% 1) Filter Event Diretories
%
printinfo = 1; % On and off flag to print out processing results
savelist  = 0;
listname  = [station,'_Dlist'];
Dlist = filterEventDirs(workingdir,printinfo,savelist,listname);
%}
%% 2)  Convert sac file format, filter bad picks
%
picktol  = 10; % The picks should be more than PICKTOL seconds apart, or something may be wrong
saveflag = 0;
[ptrace,strace,header,pslows,badpicks] = ...
    ConvertFilterTraces(Dlist,station,rfile,zfile,datadir,picktol,printinfo,saveflag);
fclose('all'); % Close all open files from reading
%}
%% 3)  Window with Taper and fourier transform signal.
%
viewtaper  = 0;
viewwindow = 0;
adj = 0.2;
[wft,vft] = TaperWindowFFT(ptrace,strace,header,adj,viewtaper,viewwindow);
%}
%% 4) Bin by p value (build pIndex)
%
npb = 3; % Average number of traces per bin
numbin = round((1/npb)*size(wft,1));
pbinLimits = linspace(.035,.08,numbin);
checkind = 1;
[pIndex,pbin] = pbinIndexer(pbinLimits,pslows,checkind);
%}
%% 5) Impulse Response: Stack & Deconvolve
% prep all signals to same length N (power of 2)
% FFT windowed traces and stack in by appropriate pbin
% Build up spectral stack, 1 stack for each p (need to sort traces by
% p and put them into bins, all need to be length n
% Now fft windowed traces
ind = 1;
viewFncs = 0;
h = waitbar(0,'Deconvolving...');
steps = length(pbin);
for ii = 1:steps
    if any(pIndex(:,ii))
        
        [r,~,~] = simdecf(wft(pIndex(:,ii),:),vft(pIndex(:,ii),:),-1,viewFncs);
        
        % Take complex conjugate and reverse 1st half to recomplete fft
        %rtrace(ind,:) = real(ifft([r,conj(r(end-1:-1:2))]));
        rec(ind,:) = real(ifft(r));
        pslow(ind) = pbin(ii);
        ind = ind + 1;
    end
    waitbar(ii/steps,h)
end
close(h)
%}
%% 6) Filter Impulse Response
%
t1 = 3.8; % Search max between these two windows (in secs after p arrival)
t2 = 4.4;
dt = header{1}.DELTA;
fLow = 0.03;
fHigh = 1;
numPoles = 2;

brec = fbpfilt(rec,dt,fLow,fHigh,numPoles,0);

for ii=1:size(rec,1);
    %brtrace(ii,:)=filter(h2,rtrace(ii,:));
    brec(ii,:)=brec(ii,:)/max(abs(brec(ii,1:800)));
    brec(ii,:)=brec(ii,:)/pslow(ii)^.2;
end

[~,it] = max(brec(:,round(t1/dt) + 1: round(t2/dt)) + 1,[],2);
tps = (it + round(t1/dt)-1)*dt;

%}
%% 7) IRLS Newtons Method to find regression Tps
%
viewfit = 1; %View newton fit (0 is off)
H = 36; % Starting guesses for physical paramaters
alpha = 6;
beta = 3.5;
tol = 1e-2;  % Tolerance on interior linear solve is 10x of Newton solution
itermax = 100; % Stop if we go beyond this iteration number
damp = 0.25;

[ Tps,H,alpha,beta ] = newtonFit(H,alpha,beta,pslow',tps,itermax,tol,damp,viewfit);

%% 8) Grid and Line Search
[ results ] = GridSearch(brec,Tps',dt,pslow);

%% Scan Status
% If we made it this far we consider it success
scanstatus = true;

%% Viewers
%{
    
    figure(567)
    bar(pbin,sum(pIndex,1))
    title(sprintf('pvalue histogram from station %s',station))
    xlabel('pvalue')
    ylabel('number of traces in pbin')
%}
%%
% View Earth Response
%{
t = [1:size(brec,2)] * dt;
    for ii = 1:size(brec,1)
        figure(5)
        plot(brec(ii,round(t1/dt) + 1: round(t2/dt)))
        title(sprintf('trace %i',ii))
        %hold on
        %plot(brtrace(ii,:))
        pause(1)
    end
%}




