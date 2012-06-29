clear all
load HCsynth.mat
% TRUE RESULTS SHOULD BE 
% Grid search. 
[v,r,h]=crust(tv,dt,pslow',3.5,4.3);
