%ProcessTraces
% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.


%% 1) Filter Event Directories
%
printinfo = 1; % On and off flag to print out processing results
savelist  = 0;
%listname  = [station,'_Dlist'];
dlist = filterEventDirs(workingdir,printinfo);
%}
%% 2)  Convert sac file format, filter bad picks
%
picktol  = 2; % The picks should be more than PICKTOL seconds apart, or something may be wrong
[ptrace,strace,header,pslows,badpicks] = ...
    ConvertFilterTraces(dlist,rfile,zfile,picktol,printinfo);
fclose('all'); % Close all open files from reading
%}
%% 3) Bin by p value (build pIndex)
%
npb = 3; % Average number of traces per bin
numbin = round((1/npb)*size(ptrace,1));
pbinLimits = linspace(.035,.08,numbin);
checkind = 1;
[pIndex,pbin] = pbinIndexer(pbinLimits,pslows,checkind);
pslow = pbin(any(pIndex)); % Strip out pbins with no traces
pIndex = pIndex(:,any(pIndex)); % Strip out indices with no traces
nbins = length(pslow); % Number of bins we now have.
%}
%% 4) Normalize
dt = header{1,1}.DELTA;
n1 = round(100/dt);
%rms = zeros(length(ptrace),2);
%{
for ii = 1:size(ptrace,1)
    rms(ii,1) = norm(ptrace(ii,1:n1))/sqrt(n1);
    %rms(ii,2) = norm(ptrace{ii}(1,end-n1-1:end))/sqrt(n1);
end
sfact = 0.5; % Rescale spread between magnitudes between sfact->1
range = 1-sfact;
scale = [];
for ii = 1:nbins
    rmsN = rms(pIndex(:,ii));
    rmsR = rmsN/max(rmsN);
    sc = rmsR*range/max(rmsR) + sfact; % Project into new range
    scale = [scale; max(rmsN)*(sc./rmsN) ]; % Find multiplier that will rescale traces
end

for ii = 1:size(ptrace,1)
    ptrace(ii,:) = ptrace(ii,:) * scale(ii);
    strace(ii,:) = strace(ii,:) * scale(ii);
end
%}

%rmsR = rms(:,1)./rms(:,2);
%figure(2222)
%plot(rms)
%figure(1111)
%plot(rmsR)

%% 5)  Window with Taper and fourier transform signal.
%
viewtaper  = 0;
adj = 0.1; % This adjusts the Tukey window used.
[wft,vft,WIN] = TaperWindowFFT(ptrace,strace,header,adj,viewtaper);
%}

%{
eos513 = false;
if eos513
    % Temp Cell obj construction for EOS 513 project
    pcoda = ptrace .* WIN;
    for ii = 1:nbins
        D1{ii} = { { strace(pIndex(:,ii),:) } , { pcoda(pIndex(:,ii),:) } , {pslow(ii)} };
    end
  
end
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
rec = zeros(nbins,size(wft,2));
for ii = 1:nbins
    [r,~,~] = simdecf(wft(pIndex(:,ii),:),vft(pIndex(:,ii),:),-1,viewFncs);
    % Take complex conjugate and reverse 1st half to recomplete fft
    %rtrace(ind,:) = real(ifft([r,conj(r(end-1:-1:2))]));
    rec(ii,:) = real(ifft(r));
    waitbar(ii/nbins,h)
end
close(h)



%}
%% 6) Filter Impulse Response
%
if exist('db','var')
    t1 = db(1).t1; % Search max between these two windows (in secs after p arrival)
    t2 = db(1).t2;
else
    t1 = 3.81;
    t2 = 4.5;
end
dt = header{1}.DELTA;
fLow = 0.04;
fHigh = 1;
numPoles = 2;

%brec = fbpfilt(rec,dt,fLow,fHigh,numPoles,0);

%load Rec_50_it
%load Rec_100_it_splines
load Rec_100_it_bsplines
brec = REC;
brec = fbpfilt(brec,dt,fLow,fHigh,numPoles,0);

for ii=1:size(rec,1);
    %brtrace(ii,:)=filter(h2,rtrace(ii,:));
    brec(ii,:)=brec(ii,:)/(max(abs(brec(ii,1:800))) + 0.001);
    brec(ii,:)=brec(ii,:)/pslow(ii)^.2;
end

[~,it] = max(brec(:,round(t1/dt) + 1: round(t2/dt)) + 1,[],2);
tps = (it + round(t1/dt)-1)*dt;

%}
%% 7) IRLS Newtons Method to find regression Tps
%

viewfit = 1; %View newton fit (0 is off)
H = 35; % Starting guesses for physical paramaters
alpha = 6.5;
beta = 3.5;
tol = 1e-4;  % Tolerance on interior linear solve is 10x of Newton solution
itermax = 300; % Stop if we go beyond this iteration number
damp = 0.2;

[ Tps,H,alpha,beta ] = newtonFit(H,alpha,beta,pslow',tps,itermax,tol,damp,viewfit);

%% 8) Grid and Line Search
[ results ] = GridSearch(brec,Tps',dt,pslow);

%[ results ] = GsearchKanamori(brec,dt,pslow);
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




