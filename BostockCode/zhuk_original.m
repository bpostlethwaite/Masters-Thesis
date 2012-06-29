function [sf] = zhuk(sv1,dt,pslow);

%sv=sv1(:,1:fix(30/dt));
sv=sv1;

ns=100;
nh=100;
h1=25;
h2=35;
dh=(h2-h1)/(nh-1);
h=[h1:dh:h2];
s1=0.23;
s2=0.33;
ds=(s2-s1)/(ns-1);
s=[s1:ds:s2];
c=sqrt((2-2*s)./(1-2*s));

a=6.0;

fac1=sqrt(1./(a*a)-pslow.*pslow);

for ih=1:nh
  ih
  for is=1:ns
     tps=h(ih)*(sqrt((c(is)/a)^2-pslow.*pslow)-fac1);
     tpps=h(ih)*(sqrt((c(is)/a)^2-pslow.*pslow)+fac1);
     tpss=2*h(ih)*sqrt((c(is)/a)^2-pslow.*pslow);
     s1=sv(:,round(tps/dt));
     s2=sv(:,round(tpps/dt));
     s3=sv(:,round(tpss/dt));
   
%     s1=shift(sv,dt,-tps);
%     s2=shift(sv,dt,-tpps);
%     s3=shift(sv,dt,-tpss);
     stps(ih,is)=mean(s1(:,1));
     stpps(ih,is)=mean(s2(:,1));
     stpss(ih,is)=-mean(s3(:,1));
  end
end
sf=stps+2*stpps+3*stpss;

imagesc(h,s,sf);
hold on
smax=max(max(sf));
[ir,ic]=find(sf == smax);
plot(h(ic),s(ir),'+')
[h(ic),s(ir)]
hold off
xlabel('Crustal Thickness [km]');
ylabel('Poissons Ratio');

keyboard



return
