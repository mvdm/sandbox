function S = LoadSpikes(cfg_in)
% S = LoadSpikes(cfg)
%
% Loads MClust *.t files containing spike timestamps
%
% input cfg fields:
%
% cfg.fc: cell array containing filenames to load
%   if no file_list field is specified, loads all *.t files in current dir
% cfg.load_questionable_cells = 0; % load *._t files if set to 1
% cfg.min_cluster_quality = 5; % minimum cluster quality
% cfg.useClustersFile = 1;
% cfg.tsflag = 'sec';
%
% output:
%
% S: spike data ts struct
%
% MvdM 2014-06-17 based on ADR LoadSpikes(), 25 edit to use cfg_in

cfg.tsflag = 'sec';
cfg.load_questionable_cells = 0;
cfg.min_cluster_quality = 5;
cfg.useClustersFile = 1;

ProcessConfig; % this takes fields from cfg_in and puts them into cfg

mfun = mfilename;

if ~isfield(cfg,'fc')
        
        cfg.fc = FindFiles('*.t');
        
        if cfg.load_questionable_cells
           fprintf('%s: WARNING: loading questionable cells\n',mfun);
           cfg.fc = cat(1,cfg.fc,FindFiles('*._t'));
        end
        
else
        
        if ~isa(cfg.fc,'cell')
            error('LoadSpikes: cfg.fc should be a cell array.');
        end
        
end

cfg.fc = sort(cfg.fc);
nFiles = length(cfg.fc);

fprintf('%s: Loading %d files...\n',mfun,nFiles);

% for each tfile
% first read the header, then read a tfile 

S = ts; % initialize new ts struct

for iF = 1:nFiles

	tfn = cfg.fc{iF};
    
	if ~isempty(tfn)
        
		tfp = fopen(tfn, 'rb','b');
		if (tfp == -1)
			error(['LoadSpikes: Could not open tfile ' tfn]);
		end
		
		ReadHeader(tfp);    
		%S.t{iF} = fread(tfp,inf,'uint64');	% read as 64 bit ints
        S.t{iF} = fread(tfp,inf,'uint32');	% read as 64 bit ints
		
		% set appropriate time units
		switch cfg.tsflag
			case 'sec'
				S.t{iF} = S.t{iF}/10000;
			case 'ts'
				S.t{iF} = S.t{iF};
			case 'ms'
				S.t{iF} = S.t{iF}*10000*1000;
			otherwise
				error('LoadSpikes: invalid tsflag.');
        end
		
        % add filenames
        [~,fname,fe] = fileparts(tfn);
		S.label{iF} = cat(2,fname,fe);
		
		fclose(tfp);
		
	end 		% if tfn valid
end		% for all files

if cfg.useClustersFile
    if isfield(cfg,'min_cluster_quality');
        
        warning('off','MATLAB:unknownElementsNowStruc');
        
        for iC = 1:length(S.label)
            
            curr_fn = S.label{iC};
            
            % get tt name and cell number of this neuron
            tok = regexp(curr_fn,'(.*)\_([0-9]+)','tokens');
            
            % load clusters
            clu_fn = cat(2,tok{1}{1},'.clusters');
            
            if exist(clu_fn,'file')
                load(clu_fn,'-mat');
            else
                error(sprintf('File %s does not exist.',clu_fn));
            end
            
            % get rating
            cellno = str2num(tok{1}{2});
            
            if exist('MClust_Clusters','var')
                clu_name = MClust_Clusters{cellno}.name;
            elseif exist('Clusters','var')
                clu_name = Clusters{cellno}.name;
            else
                error('what clusters??');
            end
            
            if ischar(clu_name(1))
                S.usr.rating(iC) = str2num(clu_name(1)); % first character of name should be rating
            else
                error(sprintf('Cluster %d has no rating (name is %s).',cellno,clu_name));
            end
            
        end % of filenames to process
        
        warning('on','MATLAB:unknownElementsNowStruc');
        
        % select only cells that meet criterion
        
        keep_idx = find(S.usr.rating <= cfg.min_cluster_quality);
        
        S.t = S.t(keep_idx);
        S.label = S.label(keep_idx);
        S.usr.rating = S.usr.rating(keep_idx);
        
    end % of min_cluster_quality conditional
end

% check if ExpKeys available
keys_f = FindFiles('*keys.m');
if ~isempty(keys_f)
    try
    run(keys_f{1});
    catch
       disp('Failed to load keys file.'); 
    end
    S.cfg.ExpKeys = ExpKeys;
end

% add sessionID
[~,S.cfg.SessionID,~] = fileparts(pwd);

% housekeeping
S.cfg.history.mfun = cat(1,S.cfg.history.mfun,mfun);
S.cfg.history.cfg = cat(1,S.cfg.history.cfg,{cfg});