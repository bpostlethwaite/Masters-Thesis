%sac test
clear all
close all

% Location of Sac files
sacfolder = '/media/TerraS/CNSN';
%sacfolder =  '/home/ben/Dropbox/School';
flag = true;
% Ask user for event folder
directory = uigetdir(sacfolder,'Choose Event Folder');
% get list of folders or files from chosen folder


while flag
    
    items = struct2cell(dir(directory));
    items = items(1,1:end);
    
    [Selection,ok] = listdlg('ListString',items,'ListSize',[400,400]);
    
    if ok == 1
        item = cell2mat(items(Selection));
        item = fullfile(directory,item);
        if isdir(item)
            directory =  item;
            flag = true;
        else
            sacfile = item;
            flag = false;
        end
    else
        fprintf('whatever')
        flag = false;
    end
    
end

if sacfile
    [t1, d] = readsac(sacfile);
    S = readsac(sacfile);        
    plot(t1,d);
end