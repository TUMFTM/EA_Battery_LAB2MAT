% READS .TXT FILES (FROM BIOLOGIC MEASUREMENT EQUIPMENT) AND CONVERTS THEM TO .MAT FILES
% v1.0 - 02/11/2018 - NW - Initial Version
% v1.1 - 05/11/2018 - NW - Added disp functions
% v1.2 - 05/11/2018 - NW - Cleaned code bugs
% v1.3 - 14/11/2018 - MA - Adapted for BioLogic-Input-Datafile
% v2.0 - 14/07/2021 - NW - Adapted to new devices
% v2.1 - 23/06/2022 - JG - Adapted for .txt files without header / Speed
%                          Optimization / Saves filname within output struct

close all
clearvars
clearvars -GLOBAL
fclose('all');

%% Initialize
disp('Initialize...')
addpath(genpath(pwd));
filelist = dir([pwd '\01_Input']);
if numel(filelist) < 3 % If folder is empty, count is 2 because binary files
    msgbox('No measurements to process. Please check input folder.', 'Error','error');
    return;
end

%% Read in raw data
for i=3:numel(filelist) % Main for loop for batch processing
    disp(['Processing file ' num2str(i-2) '...']);
    
    if strcmp(filelist(i).name(end-3:end), '.txt') % Check if file is .txt 
        disp(['File ' num2str(i-2) ': Read in raw data...'])
        
        % Read header data
        fid = fopen(filelist(i).name);
        headerVector = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',1);

        % Check if .txt file has header or not
        headerStatus = strfind(headerVector{1}{1}, 'Nb header lines');
        if headerStatus
        	headerline = str2double(extractAfter(headerVector{1}{1},18))-1;         
        end
        fseek(fid,0,'bof');         % Resets scanning to beginning
        fclose(fid);
        
        % Read original Export filename
        if headerStatus
            fid = fopen(filelist(i).name);
            headerComplete = textscan(fid,'%s',headerline,'delimiter','\n'); %Reads complete header
            headerComplete = headerComplete{1,1};
            positionFilename = strfind(headerComplete, '.mpr');           %finds filname
            linePosFilename = find(~cellfun(@isempty,positionFilename));  %Position where filename located
            fileName = extractAfter(headerComplete{linePosFilename},7) ;  %-7 positions because "File :" 
        end
        
        % Read field data
        fid = fopen(filelist(i).name);

        formatSpecTitle = char(zeros(1,120)); %Preallocation
        for ii = 1:3:120                                             
            formatSpecTitle(ii:ii+2) = '%s ';
        end

        % Read header
        if headerStatus
            tmp1 = textscan(fid,formatSpecTitle,1,'Headerlines', headerline, 'Delimiter','\t');
        else
            tmp1 = textscan(fid,formatSpecTitle,1, 'Delimiter','\t');
        end

        for ii=1:40    
            if (isempty(cell2mat(tmp1{1,ii}))) == 1
                countDataColumns=ii-1;   
                break
            end
        end

        sizeLoop = countDataColumns*3;
        formatSpecTitle = char(zeros(1,sizeLoop)); %Preallocation
        for ii=1:3:sizeLoop                                             
            formatSpecTitle(ii:ii+2) = '%s ';
        end
        formatSpecData = formatSpecTitle;

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
        for ii=1:countDataColumns
            tempfile.colheaders{1,ii}=strrep(tempfile.colheaders{1,ii},'~','');
        end
        header = cell(1,countDataColumns);
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

        % Writes filename within struct
        if headerStatus
            Dataset.filename = fileName;
        end
        
        %% Save
        disp(['File ' num2str(i-2) ': Saving...'])
        save(['02_Output\' filelist(i).name(1:end-4)],'Dataset');
        clear Dataset
        disp(['File ' num2str(i-2) ': Successfully saved in output'])
    else
        disp(['File ' num2str(i-2) ' is no .txt file'])
    end
    
end
