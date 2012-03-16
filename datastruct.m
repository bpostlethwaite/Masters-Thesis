% This program when run will suck up the Process Driver parameters into a
% Structure and append it into structure saved under database.mat.
% Parameters will turn on various functionality.
% Read about function getfield, setfield, rmfield, isfield,
% This function will automatically name resaved stations as ULMa ULMb etc
% so that additional mods can be made and saved for comparison. This
% feature can be turned off.


load(sprintf('%s/database.mat',datadir))

s = results;
s.station = station;    
s.scanstatus = 'null';  % Creat some method to update these
s.failmessage = 'not scanned'; % Creat some method to update these
s.badpicks = badpicks;   %Bad picks which come from ConvertFilterTraces.m
s.rec = brec;            % Filtered traces
s.dt = dt;               % dt for station
s.npb = npb; % average number of traces per pslow bin
s.fLow = fLow;
s.fHigh = fHigh;
s.t1 = t1; % These are the time windows constraining the automatic
s.t2 = t2; % pick of reciever function impulses

append = true;
remove = false;
stID = [station,'a'];

% This either removes all fields associated with station or appends a new
% structure with fieldname station+postfix a,b,c etc. It automatically
% appends the next available postfix. 
if append == true || remove == true
    ii = 1;
    while isfield(db,stID)
        if remove == true
            db = rmfield(db,stID);
        end
        stID = [station,char(double('a')+ii)];
        ii = ii + 1;
    end
end

% TO ADD FIELDS UNCOMMENT LINE BELOW
db.(stID) = s;

plotStack(db.(stID));

save(sprintf('%s/database.mat',datadir),'db')