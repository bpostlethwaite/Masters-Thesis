% Access Database
%clear all
%close all


user = getenv('USER');
sacfolder = '/media/TerraS/CNSN';
datadir = ['/home/',user,'/Dropbox/ComLinks/Programming/matlab/thesis/Data'];
databasedir = [datadir,'/database'];
all = 1;

prompt={'Press Enter to Continue'};
name='Pause Dialogue';
numlines=1;
defaultanswer={' '};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
    
%% Select station. Include name or use 'all' for all.
%station = all;

if any(station == 1)
    dblist = dir(databasedir);
    dblist(1:2) = []; % Get rid of . and ..
else
    clear dblist
    dblist.name = [station,'.mat'];
end

%% Iterate through stations        
for ii = 1:length(dblist)
    load(fullfile(databasedir,dblist(ii).name))
    for jj = 1:length(db) 
        fprintf('%s:\n%s\n',db(jj).station,cell2mat(db(jj).processnotes))
        fprintf('T1 = %f   T2 = %f\n',db(jj).t1,db(jj).t2)
        %if db(jj).scanstatus
        %   fprintf('Displaying results for %s\n',db(jj).station)
        %   plotStack(db(jj))
        %   answer=inputdlg(prompt,name,numlines,defaultanswer,options);
        %else
        %   fprintf('Null scan status for %s\n',db(jj).station)      
        %end
     end
    %save([databasedir,'/',db(1).station,'.mat'],'db')
end
    
    %if any(strcmp([dba.station,'.mat'],{dblist.name}))
    %    load([databasedir,'/',dba.station,'.mat'])
    %    db(end+1) = dba;
    %else
    %    db = dba;
    
    
%save([databasedir,'/',db.station,'.mat'],'db')