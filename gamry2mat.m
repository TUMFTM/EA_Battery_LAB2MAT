% READS .DTA FILES (FROM GAMRY MEASUREMENT EQUIPMENT) AND CONVERTS THEM TO .MAT FILES
% v1.0 - 29/03/2021 - Philipp Gieler - Clean version

addpath(genpath(pwd));

InputFolder = '\01_Input';
OutputFolder = '\02_Output';

CurrentFolder = cd(InputFolder);
if ~( isempty(dir('*.DTA')) & isempty(dir('*.txt')) ) %.DTA or .txt files in folder?
    cd(CurrentFolder);

    copyfile(InputFolder,OutputFolder);
    
    CurrentFolder = cd(OutputFolder);	% Change current folder to OutputFolder
    
    system('ren  *.DTA *.txt');         % convert all .DTA files to .txt files
    files = dir('*.txt');               % get all .txt files
    
    try
        ind = regexp(InputFolder,'DEG.\d\d');
        T = str2num(string(extractBetween(...
            InputFolder,ind(end)+3,ind(end)+5)));
    catch
        T=[];
%         disp('-----no Temperature-specification in folder name-----')
    end
    
    
    for counter = 1:numel(files)       	% loop through all .txt files
        
        % cange all ',' to '.'
        Data = fileread(files(counter).name);
        Data = strrep(Data, ',', '.');
        fid = fopen(files(counter).name, 'w');
        fwrite(fid, Data, 'char');
        fclose(fid);
        
        % import file data to Workspace
        fid = fopen(files(counter).name, 'r');
        Data = textscan(fid, '%s','Delimiter', '');
        Data = Data{1,1};
        fclose(fid);
        
        % read tag of file
        tmp_TAG = cell2mat(Data(find(contains(Data,'TAG	'))));
        % read timestamp of file (sart of measurement)
        tmp_D_Start = cell2mat(Data(4)) ;
        tmp_D_Start = strrep(tmp_D_Start,'DATE	LABEL	', '');
        tmp_D_Start = datetime(strrep(tmp_D_Start,'	Date', ''));
        tmp_T_Start = cell2mat(Data(5)) ;
        tmp_T_Start = strrep(tmp_T_Start,'TIME	LABEL	', '');
        tmp_T_Start = datetime(strrep(tmp_T_Start,'	Time', ''),...
            'Format','HH:mm:ss');
        Start.Timestamp = tmp_D_Start(1) + timeofday(tmp_T_Start(1));
        
        try
            ind = regexp(files(counter).name,'SOC.\d\d');
            SOC = str2num(string(extractBetween(...
                files(counter).name,ind(end)+3,ind(end)+5)))/100;
        catch
            SOC = [];
%             disp('-----no SOC-specification in file name-----')
        end
        
        % Start.OCP
        if ~isempty(strfind(tmp_TAG,'PWR')) | ...
                ~isempty(strfind(tmp_TAG,'EIS'))
            tmp_OCP = cell2mat(Data(find(contains(Data,'EOC'))));
            tmp_OCP = strrep(tmp_OCP,'EOC	QUANT	', '');
            tmp_OCP = str2double(strrep(tmp_OCP,'	Open Circuit (V)', ''));
            Start.OCP = tmp_OCP;
        end
        
        Data = strrep(Data, '	..........a', ' ');
        Data = strrep(Data, '	...........', ' ');
        Data = strrep(Data, '	...........', ' ');
        Data = cellfun(@str2num, Data , 'UniformOutput', false); % reduce Data to relevant data
        
        %fclose(fid);
        vec = vertcat(Data{:}); % store data in a matrix
        
        
        if ~isempty(strfind(tmp_TAG,'PWR'))
            %         mystruct(counter).Name =     files(counter).name;
            %         mystruct(counter).Pt =       vec (:,1);
            mystruct(counter).Time =     vec(:,2);
            mystruct(counter).U =     vec(:,3);
            mystruct(counter).I =    vec(:,4);
            %         mystruct(counter).U2 =     vec (:,5);
            %         mystruct(counter).PWR =     vec (:,6);
            %         mystruct(counter).Sig =     vec (:,7);
            %         mystruct(counter).Ach=       vec (:,8);
            %         mystruct(counter).Temp=       vec (:,9);
            %         mystruct(counter).IERange=       vec (:,10);
            
            TD=[mystruct(counter).Time, mystruct(counter).I,...
                mystruct(counter).U];
            Impedance = [0 0 0];
        end
        
        if ~isempty(strfind(tmp_TAG,'CORPOT'))
            %         mystruct(counter).Name =     files(counter).name;
            %         mystruct(counter).Pt =       vec (:,1);
            mystruct(counter).Time =     vec (:,2);
            mystruct(counter).U =     vec (:,3);
            %         mystruct(counter).U2 =    vec (:,4);
            %         mystruct(counter).Ach =     vec (:,5);
            %         try
            %             mystruct(counter).T=       vec (:,6);
            %         catch
            %             mystruct(counter).T=       [];
            %         end
            mystruct(counter).I(1:length(mystruct(counter).U),1) =   0;
            
            TD=[mystruct(counter).Time, mystruct(counter).I,...
                mystruct(counter).U];
            Impedance = [0 0 0];
            
            % Start.OCP
            Start.OCP = mystruct(counter).U(1);
        end
        
        if ~isempty(strfind(tmp_TAG,'EIS'))
            %         mystruct(counter).Name =     files(counter).name;
            %         mystruct(counter).Pt =       vec (:,1);
            mystruct(counter).Time =     vec (:,2);
            mystruct(counter).Freq =     vec (:,3);
            mystruct(counter).Zreal =    vec (:,4);
            mystruct(counter).Zimag =    vec (:,5);
            %         mystruct(counter).Zsig =     vec (:,6);
            %         mystruct(counter).Zmod =     vec (:,7);
            %         mystruct(counter).Zphy =     vec (:,8);
            %         mystruct(counter).IDC=       vec (:,9);
            %         mystruct(counter).VDC =      vec (:,10);
            %         mystruct(counter).IERange =  vec (:,11);
            mystruct(counter).U =        vec (:,10);
            mystruct(counter).I(1:length(mystruct(counter).U),1) =   0;
            
            TD=[mystruct(counter).Time, mystruct(counter).I,...
                mystruct(counter).U];
            Impedance = [mystruct(counter).Freq,...
                mystruct(counter).Zreal, mystruct(counter).Zimag];
        end
        
        filename = files(counter).name;
        [~,name,~] = fileparts(filename);
        save(name, 'Start', 'SOC', 'T', 'TD', 'Impedance');
        
    end
    
    delete *.txt;
    mat_files = dir([OutputFolder '\*.mat']);
    cd(CurrentFolder);
    
else
    disp('-----no files found-----')
end

