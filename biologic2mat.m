% READS .TXT FILES (FROM BIOLOGIC MEASUREMENT EQUIPMENT) AND CONVERTS THEM TO .MAT FILES
% v1.0 - 02/11/2018 - NW - Initial Version
% v1.1 - 05/11/2018 - NW - Added disp functions
% v1.2 - 05/11/2018 - NW - Cleaned code bugs
% v1.3 - 14/11/2018 - MA - Adapted for BioLogic-Input-Datafile
% v2.0 - 14/07/2021 - NW - Adapted to new devices

close all
clear all
fclose('all')

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
headerVector = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',1);  
headerline = str2double(extractAfter(headerVector{1}{1},18))-1;         
fseek(fid,0,'bof');                                                     
fclose(fid);

% Read field data
fid = fopen(filelist(i).name);
formatSpecTitle=[];
for ii=1:40                                              
    formatSpecTitle=[formatSpecTitle '%s '];
end

% Read header
tmp1 = textscan(fid,formatSpecTitle,1,'Headerlines', headerline, 'Delimiter','\t');
for ii= 1:40    
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

% Read data
tmp2 = textscan(fid,formatSpecData, 'Delimiter','\t');
formatSpecData=[];
for ii=1:countDataColumns
    tmp2{1,ii} = strrep(tmp2{1,ii}, ',', '.');
    tmp2{1,ii} = str2double(tmp2{1,ii});
end
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
    tempstr = strrep(tempstr, '%', '');
    tempstr = strrep(tempstr, 'µ', 'mu');
    tempstr = strrep(tempstr, '.', '');
    tempstr = strrep(tempstr, ' ', '');
    tempstr = strrep(tempstr, '(', '');
    tempstr = strrep(tempstr, ')', '');
    tempstr = strrep(tempstr, '|', '');
    header{1,ii} = tempstr;
end

%% Write 
disp(['File ' num2str(i-2) ': Writing data...'])

for ii=1:countDataColumns
    Dataset.(sprintf('%s',header{1, ii}(1:end)))=tempfile.datafields{1, ii};
end

%% Save
disp(['File ' num2str(i-2) ': Saving...'])
save(['02_Output\' filelist(i).name(1:end-4)],'Dataset');
end
end
