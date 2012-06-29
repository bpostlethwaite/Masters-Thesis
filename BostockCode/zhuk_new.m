function [sf] = zhuk(sv1,dt,pslow,idum);

if numarg == 3
    idum = 99;
end

%sv=sv1(:,1:fix(30/dt));
sv=sv1;

np=length(pslow);
nt = size(sv,2);

ns=200;
nh=200;
h1=30;
h2=50;
dh=(h2-h1)/(nh-1);
h=[h1:dh:h2];
s1=0.23;
s2=0.33;
ds=(s2-s1)/(ns-1);
s=[s1:ds:s2];
c=sqrt((2-2*s)./(1-2*s));
% c = sqrt(1+(1./(1-2*s)));

a=6.54;

fac1=sqrt(1./(a*a)-pslow.*pslow);

%-- reshape for fast element removal
svr = reshape(sv',1,numel(sv));

for ih=1:nh
  ih
  for is=1:ns
    %-- get travel times
    tps=h(ih)*  (sqrt( (c(is)/a)^2 - pslow.*pslow) -fac1);
    tpps=h(ih)* (sqrt( (c(is)/a)^2 - pslow.*pslow) +fac1);
    tpss=2*h(ih)*sqrt((c(is)/a)^2-pslow.*pslow);
   
    %-- determine model fit
    stps(ih,is) = mean(svr(round(tps/dt)+[0:np-1]*nt));
    stpps(ih,is) = mean(svr(round(tpps/dt)+[0:np-1]*nt));
    stpss(ih,is) = -mean(svr(round(tpss/dt)+[0:np-1]*nt));
  end
        
end

% figure(2);
% subplot(221)
%     imagesc(h,s,stps');
%     title('tPs');colormap(seiscol)
%     xlabel('H');ylabel('\sigma')
% subplot(222)
%     imagesc(h,s,stpps');
%     title('tPps'); colormap(seiscol)
%     xlabel('H');ylabel('\sigma');
% subplot(223)
%     imagesc(h,s,stpss')
%     title('tPss'); colormap(seiscol);
%     xlabel('H');ylabel('\sigma');

sf=stps+2*stpps+3*stpss;
smax=max(max(sf));
[ir,ic]=find(sf == smax);

% sf=stps+2*stpps+3*stpss;

figure(idum);
% subplot(313);
imagesc(h,s,sf');
hold on
smax=max(max(sf));
[ir,ic]=find(sf == smax);
plot(h(ir),s(ic),'+')
[h(ir),s(ic)]
hold off
xlabel('Crustal Thickness [km]');
ylabel('Poissons Ratio');
colormap(seiscol);




return
