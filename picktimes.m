clear all;
load rvpap
load slopap
psection100

%limits for the Ps
tp1=3.0;
tp2=5.0;
s1=round(tp1/dt);
s2=round(tp2/dt);

 for i=1:npsbins
	i
	maxtp=max(max(fp(i,s1:s2),0));
	if maxtp >0
	tps(i)=(find(fp(i,s1:s2)==maxtp))*dt+tp1;
 	end
 end

%limits for the Pps 

tp1=13.0;
tp2=14.0;
s1=round(tp1/dt);
s2=round(tp2/dt);

 for i=1:npsbins
	i
	maxtp=max(max(fp(i,s1:s2),0));
	if maxtp >0
	tpps(i)=(find(fp(i,s1:s2)==maxtp))*dt+tp1;
 	end
 end

%limits for the Pss
tp1=17.0;
tp2=17.9;

s1=round(tp1/dt);
s2=round(tp2/dt);

 for i=1:npsbins
	i
	maxtp=min(min(fp(i,s1:s2),0));
	if maxtp <0
	tpss(i)=(find(fp(i,s1:s2)==maxtp))*dt+tp1;
 	end
 end	 	 

