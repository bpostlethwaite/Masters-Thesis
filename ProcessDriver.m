%ProcessTraces

% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.
clear all
close all

addpath sac
addpath Data
addpath Functions

viewtraces = false;
%% Variables

sacfolder = '/media/TerraS/CNSN';

user = getenv('USER');
datadir = ['/home/',user,'/Dropbox/ComLinks/programming/matlab/thesis/Data'];

rfile = 'STACK_R.sac';
zfile = 'STACK_Z.sac';

%% 1) Select Station folder to process
station = 'ULM';
%workingdir = fullfile(sacfolder,station);
workingdir = fullfile(['/home/',user,'/Dropbox/School/'],station);

%load(sprintf('%s/%s.mat',datadir,station))

%% 2) Filter Event Diretories
%   
    printinfo = 1; % On and off flag to print out processing results
    savelist  = 0;
    listname  = [station,'_Dlist'];
    Dlist = filterEventDirs(workingdir,printinfo,savelist,listname);
%}
%% 3)  Convert sac file format, filter bad picks
%    
    picktol  = 10; % The picks should be more than PICKTOL seconds apart, or something may be wrong
    saveflag = 0;
    [ptrace,strace,header,pslows,tps] = ConvertFilterTraces(Dlist,station,rfile,zfile,datadir,picktol,printinfo,saveflag);
%}

%% 4) Bin by p value (build pIndex)
%    
    pbinLimits = linspace(.035,.08,100);
    [pIndex,pbin] = pbinIndexer(pbinLimits,pslows,1);
%}

%% 5)  Window with Taper and fourier transform signal.
%
    viewtaper  = 1;
    viewwindow = 0;
    [wft,vft] = TaperWindowFFT(ptrace,strace,header,0.5,viewtaper,viewwindow);
%}
%% 6) Stack and Deconvolve
% prep all signals to same length N (power of 2)
% FFT windowed traces and stack in by appropriate pbin

%{
% Build up spectral stack, 1 stack for each p (need to sort traces by
% p and put them into bins, all need to be length n
% Now fft windowed traces
ind = 1;
for ii = 1:length(pbin)
    if any(pIndex(:,ii))
        [r,~,~] = simdecf(wft(pIndex(:,ii),:),vft(pIndex(:,ii),:),-1,-1);
        
        % Take complex conjugate and reverse 1st half to recomplete fft
        Rtrace(ind,:) = real(ifft([r,conj(r(end-1:-1:2))]));
        pslow(ind) = pbin(ii);
        ind = ind + 1;
    end
end
%}

figure(243)
plot(pslows,tps)

%% Newtons Method to find tps
%{
H = 35;
alpha = 6;
beta = 3.5;
iter = 0;
while iter < 8
    %f = H*sqrt(1/beta^2 - pslows.^2) - sqrt(1/alpha^2 - pslows.^2);
    r = tps - f;
    dfdH = f/H;
    dfda = H/alpha^3 * sqrt(1/alpha^2 - pslows.^2);
    dfdb = -H/beta^3 * sqrt(1/beta^2 - pslows.^2);
    J = [dfdH(:),dfda(:),dfdb(:)];
    
    delm = -J\r(:);
    H = H + delm(1); beta = beta + delm(2); alpha = alpha + delm(3);
    iter = iter + 1
end

Tps = H*sqrt(1/beta^2 - pslows.^2) - sqrt(1/alpha^2 - pslows.^2);

plot(pslows,Tps)

%% Viewers
%
    
    figure(567)
    hist(pslow(:))
    title(sprintf('pvalue histogram from station %s',station))
%}

% View Earth Response
%{
    for ii = 1:length(Rtrace)
        plot(Rtrace(ii,:))        
        pause(4)
    end
%}




