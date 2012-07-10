clear all; close all;

load synthetic_test.mat
snr = @(x,y)abs(20*log10(norm(x(:))/norm(x(:)-y(:))));

for ii = 1:2
rec(ii,:) = D1{ii}{1};
end
load synthetic_test_3splines.mat

for ii = 1:2
rec(ii+2,:) = D1{ii}{1};
end

rec(5,:) = D1{1}{2};
n = size(rec,2);
pad = 15;
peak1 = round(n/16) - pad : round(n/16) + pad ;
peak2 = round(n*(7/16)) - pad : round(n*(7/16)) + pad ;
peak3 = round(n*(8/16)) - pad : round(n*(8/16)) + pad ;

np = length(peak1);

%rmax = max(rec(:,peak3));
%rmax = kron(ones(1,n),rmax);

rt = rec;
r = abs(rec);

rmax = max(r(:,peak1),[],2);
rmax = kron(ones(1,np),rmax);
rec(:,peak1) = r(:,peak1)./rmax;

rmax = max(r(:,peak2),[],2);
rmax = kron(ones(1,np),rmax);
rec(:,peak2) = r(:,peak2)./rmax;

rmax = max(r(:,peak3),[],2);
rmax = kron(ones(1,np),rmax);
rec(:,peak3) = r(:,peak3)./rmax;

wrec = rec([1,2,5],:);
srec = rec([3,4,5],:);

rec0 = zeros(n,1);
rec0(round(n/16)) = 1;
rec0(round(n*(7/16))) = -1;
rec0(round(n*(8/16))) = 1;

rec0t = zeros(n,1);
rec0t(round(n/16)) = 1;
rec0t(round(n*(7/16))) = -0.25;
rec0t(round(n*(8/16))) = 0.4;


t = 1:n;

wavs={'Haar Wavelets',...
    'Daubechies Wavelets',...
    'Simultaneous Deconvolution',...
    'Actual Spike Train'};
splin={'Orthonormal Splines',...
    'B - Splines',...
    'Simultaneous Deconvolution',...
    'Actual Spike Train'};

rec0 = rec0.^2;
%% PLOTS
tt = t(1:600);
rt = rt(:,1:600);
figure(11)
subplot(4,1,1)
    plot(tt,rec0t(1:600))
    title('Actual Receiver Function')
subplot(4,1,2)
    plot(tt,rt(1,:))
    title(sprintf('Haar Wavelet Deconvolution SNR = %2.2f dB',snr(rec0t(1:600),rt(1,:))))
subplot(4,1,3)
    plot(tt,rt(2,:))
    title(sprintf('Daubechies Wavelet Deconvolution SNR = %2.2f dB',snr(rec0t(1:600),rt(2,:))))
subplot(4,1,4)
    plot(tt,rt(5,:))
    title(sprintf('Damped L2 Deconvolution SNR = %2.2f dB',snr(rec0t(1:600),rt(5,:))))

figure(15)
subplot(4,1,1)
    plot(tt,rec0t(1:600))
    title('Actual Receiver Function')
subplot(4,1,2)
    plot(tt,rt(3,:))
    title(sprintf('Orthonormal Splines Deconvolution SNR = %2.2f dB',snr(rec0t(1:600),rt(1,:))))
subplot(4,1,3)
    plot(tt,rt(4,:))
    title(sprintf('B-Spline Deconvolution SNR = %2.2f dB',snr(rec0t(1:600),rt(2,:))))
subplot(4,1,4)
    plot(tt,rt(5,:))
    title(sprintf('Damped L2 Deconvolution SNR = %2.2f dB',snr(rec0t(1:600),rt(5,:))))
    
%{
figure(2);
subplot(1,2,1)
    plot(t(:,peak1),wrec(:,peak1).^2)
    hold on
    plot(t(:,peak1),rec0(peak1),'k','LineWidth',2)
    legend(wavs,'Location','NorthEast')    
    title('First Peak - Wavelets')
subplot(1,2,2)
    plot(t(:,peak1),srec(:,peak1).^2)
    hold on
    plot(t(:,peak1),rec0(peak1),'k','LineWidth',2)
    legend(splin,'Location','NorthEast')
    title('First Peak - Splines')

figure(3);
subplot(1,2,1)
    plot(t(:,peak2),wrec(:,peak2).^2)
    hold on
    plot(t(:,peak2),rec0(peak2),'k','LineWidth',2)
    legend(wavs,'Location','NorthEast')
    title('Second Peak - Wavelets')
subplot(1,2,2)
    plot(t(:,peak2),srec(:,peak2).^2)
    hold on
    plot(t(:,peak2),rec0(peak2),'k','LineWidth',2)
    legend(splin,'Location','NorthEast')    
    title('Second Peak - Splines')

figure(4);
subplot(1,2,1)
    plot(t(:,peak3),wrec(:,peak3).^2)
    hold on
    plot(t(:,peak3),rec0(peak3),'k','LineWidth',2)
    legend(wavs,'Location','NorthEast')    
    title('Third Peak - Wavelets')
subplot(1,2,2)
    plot(t(:,peak3),srec(:,peak3).^2)
    hold on
    plot(t(:,peak3),rec0(peak3),'k','LineWidth',2)
    legend(splin,'Location','NorthEast')    
    title('Third Peak - Splines')
    
  %} 
