% READS .TXT FILES (FROM BASYTEC MEASUREMENT EQUIPMENT) AND CONVERTS THEM TO .MAT FILES
% v1.0 - 02/11/2018 - NW - Initial Version
% v1.1 - 05/11/2018 - NW - Added disp functions
% v1.2 - 05/11/2018 - NW - Cleaned code bugs
% v1.3 - 30/09/2019 - NW - Removed generateBatpara routine
% v1.4 - 07/11/2019 - NW - Bugfix
% v2.0 - 29/03/2021 - NW - Clean version

%% Initialize
disp('Initialize...')
addpath(genpath(pwd));
filelist = dir([pwd '\01_Input']);
if numel(filelist)<3 % If folder is empty, count is 2 because binary files
    msgbox('No measurements to process. Please check input folder.', 'Error','error');
    return;
end

for i=3:numel(filelist) % Main for loop for batch processing
disp(['Processing file ' num2str(i-2) '...']);

if strcmp(filelist(i).name(end-3:end), '.txt')==1

%% Read in raw data
disp(['File ' num2str(i-2) ': Read in raw data...'])

% Read header data
fid = fopen(filelist(i).name);
headerline = 12;
for ii=1:headerline
    tempfile.headertext{ii,1} = {fgetl(fid)}; 
end
fclose(fid);

% Read field data
fid = fopen(filelist(i).name);
formatSpecTitle=[];
for ii=1:60                                              
    formatSpecTitle=[formatSpecTitle '%s '];
end

tmp1 = textscan(fid,formatSpecTitle,1,'Headerlines', headerline, 'Delimiter','\t');
for ii= 1:60    
     if (isempty(cell2mat(tmp1{1,ii}))) == 1
        countDataColumns=ii-1;   
        break
     end
end                                                     
formatSpecTitle=[];
formatSpecData=[];                                      
for ii=1:countDataColumns
    formatSpecTitle=[formatSpecTitle '%s '];
    formatSpecData=[formatSpecData '%s '];
end


tmp2 = textscan(fid,formatSpecData, 'Delimiter','\t');
formatSpecData=[];
for ii=1:countDataColumns        
    test=char(tmp2{1,ii}(2,1));        
    if isnan(str2double(test))
        formatSpecData=[formatSpecData '%s '];
    else
        formatSpecData=[formatSpecData '%f '];   
    end
end
fclose(fid);

fid = fopen(filelist(i).name);
tmp1 = textscan(fid,formatSpecTitle,1,'Headerlines', 12, 'Delimiter','\t');
tmp2 = textscan(fid,formatSpecData, 'Delimiter','\t');
fclose(fid);

tempfile.colheaders = tmp1(1,1:countDataColumns);
tempfile.datafields = tmp2; 

%% Preprocess textfile
disp(['File ' num2str(i-2) ': Preprocessing...'])
for ii=1:size(tempfile.colheaders,2)
    tempfile.colheaders{1,ii}=strrep(tempfile.colheaders{1,ii},'~','');
end

for ii=1:size(tempfile.colheaders,2)
    tempstr = tempfile.colheaders{1,ii}{1,1};
    cutpos = find(tempstr=='[');
    if isempty(cutpos)==0
        tempstr = tempstr(1:cutpos-1);  
    end
    tempstr = strrep(tempstr, '[', '');
    tempstr = strrep(tempstr, ']', '');
    tempstr = strrep(tempstr, '-', '');
    tempstr = strrep(tempstr, '°', '');
    tempstr = strrep(tempstr, '/', '');
    header{1,ii} = tempstr;
end

%% Write 
disp(['File ' num2str(i-2) ': Writing data...'])

for ii=1:countDataColumns
    try
    Dataset.(sprintf('%s',header{1, ii}(1:end)))=tempfile.datafields{1, ii};
    catch
    end
end

%% Save
disp(['File ' num2str(i-2) ': Saving...'])
save(['02_Output\' filelist(i).name(1:end-4)],'Dataset');
end
end
