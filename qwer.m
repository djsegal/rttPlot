% loadXY -> loadXYZ ... allows 2d and 3d
%asdf
%asdf

% removed variable sorter from queryXYZ

% keep the nfdout bug inhouse, dont take care of it in other scripts

% make loadXY and loadRTT into one function, then split that function
% into two other functions: loadInfo, data
% loadInfo: loads time information
% data: loads data matrices

% 'if isempty(vars) % RTT plots don't keep track of all vars'

% maybe change find to increase performance (check on new version of matlab)

%vars = {'scal'};
%vars = {'scal' 'jmx' 'r1a' 'te2a' 'tr2a' 'tn2a'};

% allow the varargin conventions in the other plots to make them more
% like matlab functions (e.g. filename, variable, ...)

% for data, x is variable youre look at, y is the other variable
%   also, mention that correct dims loop is always last

% data et al should work when first cycle ~= 1
%       in other words, nfdout works no matter what

classdef qwer
    
    properties
        filename
        variable_info
        output_info
    end
    
    % only contains the original qwer script
    methods ( Hidden )
        
        function obj = qwer( varargin )
            %% This is the function that gets run automatically
            %  qwer loads the bucky.h5 variable names
            %  and time indicies for use by other scripts.
            
            %% check if the input is a filename
            
            if ~isempty(varargin) && length(varargin{1}) > 3 ...
                    && strncmp(varargin{1}(end-2:end),'.h5',3)
                obj.filename = varargin{1};
            else
                obj.filename = 'bucky.h5';
            end
            
            %% Load the hdf file
            
            fileinfo = hdf5info(obj.filename);
            cycles   = fileinfo.GroupHierarchy.Groups(1);
            
            %% First, populate a vector containing the position
            %  of 'scal' in the data file.
            
            scalvar = zeros(length(cycles.Groups),1);
            for i = 1:length(cycles.Groups)
                for j = 1:length(cycles.Groups(i).Datasets)
                    
                    vname = cycles.Groups(i).Datasets(j).Name;
                    vname = vname(length(cycles.Groups(i).Name)+...
                        2:length(cycles.Groups(i).Datasets(j).Name));
                    
                    if isequal(vname,'scal')
                        scalvar(i) = j;
                        break
                    end
                    
                end
            end
            
            %% Process the output time and cycle data
            
            time   = zeros( length(cycles.Groups) , 1 );
            cycle  = zeros( length(cycles.Groups) , 1 );
            for i  = 1:length(cycles.Groups)
                scal = hdf5read(cycles.Groups(i).Datasets(scalvar(i)));
                time(i,1) = scal(2);
                cycle(i,1) = scal(3);
            end
            
            [cycle index] = sort(cycle);
            output = cell( length(cycles.Groups) , 3 );
            for i  = 1:length(index)
                output(i,1) = {time(index(i))};
                output(i,2) = {cycle(i)};
                output(i,3) = {index(i)};
            end
            
            %% Process the variable names. We use the first cycle because it
            %  should contain the complete set of stored variables.
            
            % beginning of variable names
            beginning = ...
                regexp(cycles.Groups(1).Datasets(1).Name,'\/(\w+)$')+1;
            
            variable  = cell(length(cycles.Groups(cell2mat(output(1,3))).Datasets),2);
            for i = 1:length(cycles.Groups(cell2mat(output(1,3))).Datasets)
                vname = cycles.Groups(1).Datasets(i).Name;
                vname = vname(beginning:end);
                variable(i,1) = {vname};
                variable(i,2) = {cycles.Groups(1).Datasets(i).Dims};
            end
            
            obj.variable_info = [{'Variable Name'} {'Array Dimensions'}];
            obj.output_info = [{'Simulation Time'} {'Cycle Number'} {'HDF File Index'}];
            
            %% Send variables to Matlab's main workspace
            
            assignin('base','fileinfo',fileinfo)
            assignin('base','variable',variable)
            assignin('base','variable_info',obj.variable_info)
            assignin('base','output',output)
            assignin('base','output_info',obj.output_info)
            
        end
        
    end
    
    methods ( Static )
       
        function [ vars , cycSkip , scalInd , varargout ]  =   query( varargin )
            %% query function for aXYplot
            
            % varargout = scalInd nzones nblank
            
            %% Check if the first input is a filename
            if ~isempty(varargin) && ischar(varargin{1}) && length(varargin{1}) > 3
                if strncmp(varargin{1}(end-2:end),'.h5',3)
                    file = varargin{1};
                    varargin(1) = [];
                elseif strncmp(varargin{1},'bucky',5)
                    file = [ varargin{1} '.h5' ];
                    varargin(1) = [];
                else
                    file = 'bucky.h5';
                end
            else
                file = 'bucky.h5';
            end
            
            %% Load the hdf file

            fileinfo = hdf5info(file);
            
            % the first cycle in the 'bucky#.h5' file
            cycle1   = fileinfo.GroupHierarchy.Groups(1).Groups(1);
            
            % the second cycle in the 'bucky#.h5' file (check for radiation)
            try
                cycle2   = fileinfo.GroupHierarchy.Groups(1).Groups(2);
            catch peopleDoThisAllTheTimeError
                % like I say, people Do This All The Time (1 cyc. h5 files)
            end
            
            
            %% Check for radiation files (Added 1 Year After Prev. Code)
            
            origLength = length(cycle1.Datasets);  % Possibly w/  Rad Vars
            tempLength = length(cycle2.Datasets);  % Possibly w/o Rad Vars
            
            cycSkip    =   0;      %   number of cycles b/w Rad Vars
            if origLength ~= tempLength
                
                for i = 3 : length(fileinfo.GroupHierarchy.Groups(1).Groups)
                    
                    curLength = length(...
                        fileinfo.GroupHierarchy.Groups(1).Groups(i).Datasets);
                    
                    if curLength == origLength
                        cycSkip = (i-1) - 1 ; % num of cycs to skip
                        break
                    end
                    
                end
                
                if cycSkip == 0
                    cycSkip = -1;
                end
                
            end
            
            %% Load information about the variables
            
            %  if varargin is empty, no variables were asked about and
            %  general information about every variable will be given.
            %  otherwise, only the indices of the inputted variables are given
            
            %  NOTE: when varargin is empty, vars is an Nx2 cell array
            %          and when it is empty, vars is an N vector of indices
            
            removeScal = 0; % don't remove scal from list at end of query
            
            if isempty(varargin) % *** used in aXYplot and D3plot ***
                
                if cycSkip ==  0
                    % numVars =        length(cycle1.Datasets)
                    vars      = {zeros(length(cycle1.Datasets),2)};
                else
                    vars      = {zeros(length(cycle1.Datasets),3)};
                end
                
                % beginning of variable names
                beginning = ...
                    regexp(cycle1.Datasets(1).Name,'\/(\w+)$')+1;
                
                for j = 1:length(cycle1.Datasets)
                    vname = cycle1.Datasets(j).Name;
                    vars(j,1) = { vname(beginning:end) };
                    vars(j,2) = { cycle1.Datasets(j).Dims };
                end
                
                scalInd = find(strncmp('scal',vars,4));
                
                if cycSkip ~=  0
                    
                    for k = 1:length(cycle2.Datasets)
                        vname = cycle2.Datasets(k).Name;
                        vars(k,3) =  { vname(beginning:end) };
                    end
                    
                    scalInd(2) = find(strncmp('scal',vars(:,3),4));
                    
                end
                
            else                 % *** used primarily in aRTTplot ***
         
                if cycSkip ==  0
                    vars = zeros( length(varargin) , 1 );
                else
                    vars = zeros( length(varargin) , 2 );
                end
                
                % if varargin's first element (excluding filenames) is
                %     a cell array, replace varargin with its contents.
                %     this assumes varargin will only have one element
                if iscell(varargin{1})
                    varargin = varargin{1};
                end
                
                % find scalInd in inputted vars and add it if neccesary
                
                scalLoc = find(strncmp('scal',varargin,4));
                if isempty(scalLoc)
                    varargin{end+1} = 'scal';
                    scalLoc  = length(varargin);
                    removeScal = 1; %   remove scal from list when finished
                end
                
                % find indices of vars listed in varargin
                
                varsFound = 0;
                for i = 1:length(cycle1.Datasets)
                    vname = cycle1.Datasets(i).Name;
                    vname = vname(length(cycle1.Name)+2:length(cycle1.Datasets(i).Name));
                    for j = 1:length(varargin)
                        if isequal(vname,varargin{j})
                            vars(j,1) = i;
                            varsFound = varsFound + 1;
                            break
                        end
                    end
                    if ( varsFound == length(varargin)  ), break, end
                end
                
                % find scalInd in pool of all vars
                scalInd = vars(scalLoc,1);
                
                if cycSkip ~=  0
                    
                    % find indices of vars listed in varargin
                    varsFound = 0;
                    for i = 1:length(cycle2.Datasets)
                        vname = cycle2.Datasets(i).Name;
                        vname = vname(length(cycle2.Name)+2:length(cycle2.Datasets(i).Name));
                        for j = 1:length(varargin)
                            if isequal(vname,varargin{j})
                                vars(j,2) = i;
                                varsFound = varsFound + 1;
                                break
                            end
                        end
                        if ( varsFound == length(varargin)  ), break, end
                    end
                    
                    % find scalInd in pool of all vars
                    scalInd(2) = vars(scalLoc,2);
                    
                end
                
            end
            %% If needed, Process various information from scal
%             vars
            if nargout < 3
                if removeScal
                    vars(length(varargin),:) = [];  
                    if length(varargin) > scalLoc
                        vars(scalLoc,2) = 0;   
                    end
                end
                return
            end
            
            scal = hdf5read( cycle1.Datasets(scalInd(1)) );
            
            %  nzones       =     jmx   - 1     % number of spatial zones
            varargout{1}    =   scal(5) - 1;
            
            %  ngroups      =     nfg           % number of energy groups
            varargout{2}    =   scal(7);
            
            %% Clean up process by deleting scal from vars if it was added
            
            if removeScal
                vars(length(varargin),:) = [];  
                    if length(varargin) > scalLoc
                        vars(scalLoc,2) = 0;  
                    end
            end
            
        end
        
        function [          cycs  , varargout ]  =  cycles( varargin )
            %% get cycle information
            
            %% Process varargin
            
            %% Check if the first input is a filename
            if ~isempty(varargin) && ischar(varargin{1}) && length(varargin{1}) > 3
                if strncmp(varargin{1}(end-2:end),'.h5',3)
                    file = varargin{1};
                    varargin(1) = [];
                elseif strncmp(varargin{1},'bucky',5)
                    file = [ varargin{1} '.h5' ];
                    varargin(1) = [];
                else
                    file = 'bucky.h5';
                end
            else
                file = 'bucky.h5';
            end
            
            % varargin{1} is the index of 'scal'.  used for increasing speed.
            if isempty(varargin)
                [ scalarIndex cycSkip ] = qwer.query(file,'scal') ;
            else
                scalarIndex = varargin{1};
                cycSkip     = varargin{2};
            end
            
            %% Load the hdf file
            
            fileinfo = hdf5info(file);
            
            cycs = fileinfo.GroupHierarchy.Groups(1);
            
            %% If needed, process the output time and cycle data

            % quit function early if there isn't a second output
            if nargout < 2 , return, end
            
            time  = zeros ( length(cycs.Groups) , 1 );
            cycle = zeros ( length(cycs.Groups) , 1 );
            
            if cycSkip < 1
                
                scal = hdf5read(cycs.Groups(1).Datasets(scalarIndex(1)));
                time(1,1) = scal(2);
                cycle(1,1) = scal(3);
                
                if cycSkip == 0
                    k = 1;
                else            % if cycSkip == -1
                    k = 2;
                end
                
                for i = 2:length(cycs.Groups)
                    scal = hdf5read(cycs.Groups(i).Datasets(scalarIndex(k)));
                    time(i,1) = scal(2);
                    cycle(i,1) = scal(3);
                end
                
            else
                
                disp 'havent done this yet (part 2)'
                
            end
            
            % varargout = { time , cycle , index } , sorted by cycle number
            [ varargout{1}(:,1:2) , varargout{1}(:,3) ] = sortrows([time,cycle],2);
            
        end
        
        function [                  varargout ]  =   types( varargin )
            
            % outputMode determines what varargout contains:
            %   if outputMode = 1,
            %       varargout={twoDimVars,groupVars,boundaryVars,bodyVars}
            %   if outputMode = 2,
            %       varargout={var1Status,...,varNStatus}
            outputMode = 1; % set the default mode
            
            
            % ===============================
            %  get needed info from varargin
            % ===============================
            
            % the following if condition corresponds to a
            %   plotting program's use of the function
            %   e.g. varargin = { vars , zones , groups }
            
            % for standard usage (the else condtion), the algorithm
            %   below is used to allow for flexable input:
            
            %     1) check varargin's first input for a filename
            %     2) check to see if varargin has any inputs that
            %          aren't filenames (these are treated as vars)
            %     3) if any vars exist, use var1 to decipher the
            %          form of varargin (only var1 is needed):
            %            (i)   varargin = { file , { var1 ,..., varN } }
            %            (ii)  varargin = { file , ( var1 ,..., varN ) }
            %            (iii) varargin = { file , { ind1 ,..., indN } }
            %            (iv)  varargin = { file , ( ind1 ,..., indN ) }
            
            % NOTE: either ( file ) or { var1,...,varN } can be missing
            %         * (        file       )  -->   'bucky.h5'
            %         * { var1 , ... , varN }  -->    allVars
            
            
            % *-------------------*  Plotting  Usage  *-------------------\
            
            if nargin == 3 && size(varargin{1},2) == 2 && ...
                    isscalar(varargin{2}) && isscalar(varargin{3})
                
                % the other algorithm (see:else) ultimately gets
                %   these values (e.g. vars, zones, and groups)
                vars   = varargin{1};
                zones  = varargin{2};
                groups = varargin{3};
                
                % *---------------*  Plotting  Usage  *-------------------/
                
                
                
            else % *--------------*  Standard  Usage  *-------------------\
                
                % Check if the first input is a filename
                if ~isempty(varargin) && ischar(varargin{1}) && length(varargin{1}) > 3
                    if strncmp(varargin{1}(end-2:end),'.h5',3)
                        file = varargin{1};
                        varargin(1) = [];
                    elseif strncmp(varargin{1},'bucky',5)
                        file = [ varargin{1} '.h5' ];
                        varargin(1) = [];
                    else
                        file = 'bucky.h5';
                    end
                else
                    file = 'bucky.h5';
                end
                
                % check if there are any vars
                if isempty(varargin)
                    [    vars , ~ , ~ , zones , groups ] = qwer.query(file);
                else
                    
                    outputMode = 2; % change the mode of output
                    
                    [ allVars , ~ , ~ , zones , groups ] = qwer.query(file);
                    
                    % if varargin's first element (excluding filenames) is
                    %     a cell array, replace varargin with its contents.
                    %     this assumes varargin will only have one element
                    if iscell(varargin{1})
                        varargin = varargin{1}(:);
                    end
                    
                    % get vars from allVars and varargin
                    vars  =  cell(length(varargin),2);
                    if ischar(varargin{1})  % varargin contains strings of vars
                        for i = 1:length(varargin)
                            vars(i,:) = {allVars(find(strncmp(varargin(i),allVars,4)),:)};
                        end
                    else                    % varargin contains indices of vars
                        for i = 1:length(varargin)
                            vars(i,:) = {allVars(varargin{i},:)};
                        end
                    end
                    
                end
                
            end
            
            % *-------------------*  Standard  Usage  *-------------------/
            
            
            % ==============================
            %  create the desired varargout
            % ==============================
            
            % --------------------------------------------------------\
            if outputMode == 1  %                                      \
                %                                                      <}
                %  Create lists of indices for all the variable types  /
                % ----------------------------------------------------/
                
                % varargout has four empty vectors, which will become the
                %   lists holding the indices of the following var types:
                %     twoDimVars , boundaryVars , bodyVars , groupVars
                varargout = cell(4,1);
                
                % NOTE: using a 3 point variance window, there might be an
                %   error later on in the program.  however, an error is
                %   better than completely ignoring a variable altogether
                for i = 1:size(vars,1)
                    
                    if length(vars{i,2}) == 2
                        varargout{1}(end+1) = i;        %   **2-D**    Vars
                    elseif vars{i,2} >= groups - 3 && vars{i,2} <= groups + 3
                        varargout{2}(end+1) = i;        %  **Group**   Vars
                    elseif vars{i,2} >= zones - 3 && vars{i,2} <= zones + 3
                        
                        if ~isempty(regexp(vars{i,1},'[1]\D'))
                            % boundary variables have a 1 in their name
                            
                            varargout{3}(end+1) = i;    % **Boundary** Vars
                            
                        else  % ~isempty(regexp(variable{i,1},'[2]\D'))
                            % body variables have a 2 in their name
                            
                            varargout{4}(end+1) = i;    %   **Body**   Vars
                            
                        end
                        
                    end
                    
                end
                
                % ----------------------------------------------------\
            else % if outputMode == 2                                  \
                %                                                      <)
                %         Find the variable types of the given vars    /
                % ----------------------------------------------------/
                
                varargout{1} = zeros(size(vars,1),1);
                for i = 1:size(vars,1)
                    if length(vars{i,2}{2}) == 2
                        varargout{1}(i) = 1;
                    elseif vars{i,2}{2} >= groups - 3 && vars{i,2}{2} <= groups + 3
                        varargout{1}(i) = 2;
                    elseif vars{i,2}{2} >=  zones - 3 && vars{i,2}{2} <=  zones + 3
                        % boundary variables have a 1 in their name
                        %   body   variables have a 2
                        if ~isempty(regexp(vars{i,1}{1},'[1]\D'))
                            varargout{1}(i) = 3;
                        else  % ~isempty(regexp(variable{i,1},'[2]\D'))
                            varargout{1}(i) = 4;
                        end
                    else
                        varargout{1}(i) = Inf; % error
                    end
                    
                end
                
            end
            
        end
        
        function [         xData  , varargout ]  =    data( varargin )
            
            xData = [];
            
            %% Process varargin
            
            % the first element in varargin can be a logical variable
            % that determines the way the output is presented
            %  (1): standard
            %  (2): send it to main matlab workspace
            %  (3): both (1) and (2)
            if ~isempty(varargin) && islogical(varargin{1})
                outputMode = double(varargin{1})+2;
                varargin(1) = [];
            else
                outputMode = 1;
            end
            
            % assume varargin has the following elements, in order:
            %       ( after xSelect has been removed )
            %
            % |-------|-------|----|-----|------|
            % |xStatus|yStatus|vars|zones|groups|
            % |---1---|---2---|--3-|--4--|---5--|
            %
            % |------|----|----|----|---|--------|
            % |cycles|SEL4|SEL5|SEL6|ind|skipCycs|
            % |---6--|--7-|--8-|--9-|-0-|---11---|
            %
            % where SEL4 means selected zones for the data
            
            % full varargin ( xSelect + 10 )
            if length(varargin) >= 11 && isfloat( varargin{end} )
                
                % extract xSelect from varargin
                
                xSelect = varargin{1};
                
                if isempty(xSelect) , return , end
                
                varargin(1) = [];
                
                % allow first inputs to be multiple xSelections
                if ischar(xSelect)
                    xSelect = { xSelect };
                    while ~isempty(varargin) && ischar(varargin{1}) ...
                            && str2double(varargin{1}(end)) ~= 5
                        xSelect(end+1) = varargin(1);
                        varargin(1) = [];
                    end
                end
                
            else
                
                % Check if the first input is a filename
                if ~isempty(varargin) && ischar(varargin{1}) && length(varargin{1}) > 3
                    if strncmp(varargin{1}(end-2:end),'.h5',3)
                        file = varargin{1};
                        varargin(1) = [];
                    elseif strncmp(varargin{1},'bucky',5)
                        file = [ varargin{1} '.h5' ];
                        varargin(1) = [];
                    else
                        file = 'bucky.h5';
                    end
                else
                    file = 'bucky.h5';
                end
                
                %% set up xSelect
                
                if isempty(varargin)
                    varargin{1} = 'all';
                end
                
                xSelect = varargin{1};
                
                if isempty(xSelect) , return , end
                
                varargin(1) = [];
                
                % allow first inputs to be multiple xSelections
                if ischar(xSelect)
                    xSelect = { xSelect };
                    while ~isempty(varargin) && ischar(varargin{1}) ...
                            && str2double(varargin{1}(end)) ~= 5
                        xSelect(end+1) = varargin(1);
                        varargin(1) = [];
                    end
                end
                
                [ varargin{3} , ~ , ~ , varargin{4} , varargin{5} ] = qwer.query(file);
                [ varargin{6} varargin{9} ] = qwer.cycles(file);
                
                varargin{9} = varargin{9}(:,3);
                
                if length(xSelect) == 1 && strncmp(xSelect{1},'all',3)
                    xSelect =  num2cell(1:size(varargin{3},1));
                    if outputMode == 1
                        outputMode = 3;
                    end
                else
                    % transform elements in xSelect from strings to indices
                    for i = 1:length(xSelect)
                        xSelect{i} = find(strncmp(xSelect{i},...
                            varargin{3},length(xSelect{i})));
                    end
                end
                
                if length(xSelect) == 1
                    varargin{1} = qwer.types(file,xSelect);
                else
                    types = qwer.types(file,xSelect);
                    varargin{1} = sort(unique(types));
                    xWork = xSelect;
                    xSelect = cell(1,length(varargin{1}));
                    for i = 1:length(xWork)
                        for j = 1:length(varargin{1})
                            if types(i) == varargin{1}(j)
                                xSelect{j}(end+1) = xWork(i);
                                break;
                            end
                        end
                    end
                    if any(types==Inf) % for 'jmx' and 'scal'
                        specialVars = find(types==Inf);
                        if length(specialVars) > 1
                            oldLength = length(varargin{1});
                            for i = 1:length(specialVars)-1
                                varargin{1}(end+1) = Inf;
                                xSelect{end+1} = xSelect{oldLength}(2);
                                xSelect{oldLength}(2) = [];
                            end
                        end
                    end
                    
                    
                    
                    % make xData
                    
                    %                     xData = {};
                    %                     xData(1,1) = {' # '};
                    %                     xData(2,1) = {'---'};
                    %
                    %                     for i = 1:length(xSelect)
                    %                         xData{1,i+1} = [ ' out_' num2str(i) ' ' ];
                    %                     end
                    %
                    %                     xData(2,2:end) = {'-------'};
                    
                    for i = 1:length(xSelect)
                        for j = 1:length(xSelect{i})
                            xData{j+2,i+1} = varargin{3}{xSelect{i}{j},1};
                        end
                    end
                    
                    for i = 3:size(xData,1)
                        xData(i,1) = {[' ' num2str(i-2) ' ']};
                    end
                    
                    xxx = max(cellfun('length', xData)) ;
                    for i = 1:length(xSelect)
                        xxx(i+1) = max(xxx(i+1),7);
                    end
                    
                    xData(1,1) = {[ blanks(floor(xxx(1)/2)) '#' blanks(ceil(xxx(1)/2)-1)]};
                    xData(2,1) = { repmat('-',1,xxx(1)) };
                    for i = 3:size(xData,1)
                        tmp = (xxx(1)-length(xData{i,1}))/2;
                        xData{i,1} = [ blanks( ceil(tmp)) ...
                            xData{i,1} blanks(floor(tmp)) ];
                    end
                    
                    for i = 1:length(xSelect)
                        for j = 1:length(xSelect{i})
                            tmp = (xxx(i+1)-length(xData{j+2,i+1}))/2;
                            xData{j+2,i+1} = [ blanks(floor(tmp)) ...
                                xData{j+2,i+1} blanks( ceil(tmp)) ];
                        end
                    end
                    
                    for i = 1:length(xSelect)
                        xData{1,i+1} = [ 'out_' num2str(i) ];
                        tmp = (xxx(i+1)-length(xData{1,i+1}))/2;
                        xData{1,i+1} = [ blanks(floor(tmp)) ...
                            xData{1,i+1} blanks( ceil(tmp)) ];
                        xData(2,i+1) = {repmat('-',1,xxx(i+1))};
                    end
                    
                    for i = 1:length(xSelect)
                        tmp = xxx(i+1)/2;
                        for j = size(xData,1):-1:3
                            if isempty(xData{j,i+1})
                                xData{j,i+1} = [ blanks(floor(tmp)) 'x' ...
                                    blanks(ceil(tmp)-1)];
                            else
                                break
                            end
                        end
                    end
                    
                    
                    
                    %                     oldLength = size(xData,1);
                    %                     xData(oldLength+1,:) = {'-----'};
                    %                     for i = 1:size(xData,2)
                    %                         xData{oldLength+2,i} = [ 'out' num2str(i) ];
                    %                     end
                    %
                    
                    
                    %                     oldLength2 = size(xData,2)
                    %                     for j = 1:oldLength
                    %                        xData(j,oldLength2+1) = {num2str(j)};
                    %                     end
                    %                     xData(oldLength+1,oldLength2+1) = {'-'};
                    %                     xData(oldLength+2,oldLength2+1) = {'X'};
                    %                     for j = oldLength
                    %                     xData = varargin{3}(cell2mat(xSelect(:)),1);
                    %                     assignin('base','asdffdsa',xData)
                    %xData = cellfun(@(x) varargin{3}(cell2mat(x),1),xSelect,'UniformOutput',0);
                    
                end
                varargin{2} = varargin{1};
                varargin{7} = [];
                varargin{8} = [];
                varargin{10} = [];
                varargin{11} = -1;
                
            end
            
            % dataHelper is a function in that is used so the original
            % variable names could be used instead of varargin{1},...
            if isempty(xData)
                [ xData varargout{1:nargout-1}  ] = qwer.dataHelper(xSelect,...
                    varargin{1},varargin{2},varargin{3},varargin{4},...
                    varargin{5},varargin{6},varargin{7},varargin{8},...
                    varargin{9},varargin{10},varargin{11});
            else % when xData contains info about variables for users
                [ varargout{1:length(xSelect)}  ] = qwer.dataHelper(xSelect,...
                    varargin{1},varargin{2},varargin{3},varargin{4},...
                    varargin{5},varargin{6},varargin{7},varargin{8},...
                    varargin{9},varargin{10},varargin{11});
            end
            
            %             for i = 1:length(xDataExtra)
            %                varargout{i} = xDataExtra{i};
            %             end
            %
            
            %% Special forms of data output
            
            switch outputMode
                
                case 2 % first input: false
                    
                    for i = 1:length(varargout)
                        
                        assignin('base',['out_' num2str(i)],varargout{i})
                    end
                    
                case 3 % first input: true
                    
                    for i = 1:length(xSelect)
                        if size(varargout{i},2) == 1
                            for j = 1:length(xSelect{i})
                                assignin( 'base' , strtrim(xData{j+2,i+1}) , ...
                                    permute(varargout{i}(:,:,:,j),[1,3,2,4]) )
                            end
                        else
                            for j = 1:length(xSelect{i})
                                assignin( 'base' , strtrim(xData{j+2,i+1}) , ...
                                    varargout{i}(:,:,:,j))
                            end
                        end
                    end
                    
                    xData = [];
                    
            end
            
        end
        
        function [         xData  , varargout ]  =  dataHelper( xSelect  , ...
                xStatus , yStatus , vars , zones , groups    ,  cycles   , ...
                selZones , selGroups , selCycles , switchInd ,  skipCycles )
            
            % don't update data if there is no other variable
            if yStatus == -1
                xData = [];
                return
            end
            
            %% Allow multiple xSelects
            
            if iscell( xSelect ) %% || iscell( xStatus )
                
                if length(yStatus) == 1
                    xData = qwer.dataHelper ( xSelect{1} , xStatus(1) , ...
                        yStatus , vars , zones, groups , cycles , ...
                        selZones , selGroups , selCycles, switchInd, skipCycles );
                    for i = 2:length(xSelect)
                        varargout{i-1} = qwer.dataHelper ( xSelect{i} , xStatus(i) , ...
                            yStatus , vars , zones, groups , cycles , ...
                            selZones , selGroups , selCycles, switchInd, skipCycles );
                    end
                else
                    xData = qwer.dataHelper ( cell2mat(xSelect{1}) , xStatus(1) , ...
                        yStatus(1) , vars , zones, groups , cycles , ...
                        selZones , selGroups , selCycles, switchInd, skipCycles );
                    for i = 2:length(xSelect)
                        varargout{i-1} = qwer.dataHelper ( cell2mat(xSelect{i}) , xStatus(i) , ...
                            yStatus(i) , vars , zones, groups , cycles , ...
                            selZones , selGroups , selCycles, switchInd, skipCycles );
                    end
                end
                
                return
                
            end
            
            %% Get the dimensions of the inputted variables
            
            if isempty(vars) % RTT plots don't keep track of all vars
                varDims = cell(length(xSelect),1);
                for i = 1:length(xSelect)
                    varDims{i} = cycles.Groups(1).Datasets(xSelect(i)).Dims;
                end
            elseif iscell(vars)
                varDims = vars(xSelect,2);
            end
            
            %% Load data from cycles with hdf5read
            
            %length(strmatch('asa',asdf))

            switch xStatus
                
                case 1  % 2D Vars
                 
                    111
                    xData = zeros( length(selCycles) , zones , groups , length(xSelect) );
                    
                    for i = 1:length(xSelect)
                        
                        curVar = varDims{i}; % maybe varDims{i}(2)
                        if curVar(2) == zones + 2
                            for j = 1:length(selCycles)
                                work = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i)))';
                                xData(j,:,:,i) = work(2:end-1,:);
                            end
                        elseif curVar(2) == zones + 1
                            for j = 1:length(selCycles)
                                work = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i)))';
                                xData(j,:,:,i) = work(1:end-1,:);
                            end
                        else % correct dimensions
                            for j = 1:length(selCycles)
                                xData(j,:,:,i) = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i)))';
                            end
                        end
                        
                    end
                    
                case 2  % Group Vars
                    222
                    xData = zeros( length(selCycles) ,   1   , groups , length(xSelect) );
                    
                    for i = 1:length(xSelect)
                        if varDims{i} == groups + 1 % error
                            for j = 1:length(selCycles)
                                work = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i)));
                                xData(j,:,:,i) = [ work(1) ; ( work(2:end-2)+.5*diff(work(2:end-1)) ) ; work(end) ];
                            end
                        else
                            for j = 1:length(selCycles)
                                xData(j,:,:,i) = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i)));
                            end
                        end
                    end
                    
                case 3  % Boundary Vars
                    
                    % for the following if statement,
                    % first  condition:  boundary y variable  |yStatus == 3
                    % second condition: xkem or xknm          |vars{xSelect} == zones
                    
                    switch yStatus
                        
                        case 3 % Boundary
                            
                            111
                            
                            xData = zeros( length(selCycles) , zones+1 ,  1  , length(xSelect) );
                            
                            for i = 1:length(xSelect)
                                if varDims{i} == zones
                                    
                                    for j = 1:length(selCycles)
                                        work = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i)));
                                        
                                        % xkem1b needs a repeat of the first value
                                        xData(j,:,:,i) = [ work(1) ; work ];
                                        
                                        % this would change if xkep1b was a var, possibly:
                                        %   obj.Xdata(i,:) = [ work ; work(end) ];
                                    end
                                    
                                else
                                    
                                    for j = 1:length(selCycles)
                                        xData(j,:,:,i) = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i)));
                                    end
                                    
                                end
                            end
                            
                        case 5 % Both
                            
                            222
                            
                            xData(:,:,2) = qwer.dataHelper ( ...
                                xSelect , xStatus , 4 , ...
                                vars , zones, groups , cycles , ...
                                selZones , selGroups , selCycles , [] );
                            
                            xData(:,end+1,2) = xData(:,end,2);
                            
                            xData(:,:,1) = qwer.dataHelper ( ...
                                xSelect , xStatus , 3 , ...
                                vars , zones, groups , cycles , ...
                                selZones , selGroups , selCycles , [] );
                            
                            return
                            
                        otherwise
                            
                            333
                            
                            xData = zeros( length(selCycles) , zones ,   1   , size(xSelect,1) );
                            
                            for i = 1:size(xSelect,1)
                                if varDims{i} ==  zones + 1
                                    
                                    if skipCycles < 1
                                        
                                        work = hdf5read(cycles.Groups(selCycles(1)).Datasets(xSelect(i,1)));
                                        xData(1,:,:,i) = [ work(1) ; ( work(2:end-2)+.5*diff(work(2:end-1)) ) ; work(end) ];
                                        
                                        if skipCycles == 0
                                            k = 1;
                                        else            % if cycSkip == -1
                                            k = 2;
                                        end
                                        
                                        % assume length(xSelect) == 1
                                        for j = 2:length(selCycles)
                                            
                                            work = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i,k)));
                                            xData(j,:,:,i) = [ work(1) ; ( work(2:end-2)+.5*diff(work(2:end-1)) ) ; work(end) ];
                                            
                                        end
                                        
                                    else
                                        
                                        disp 'havent done this yet part 3'
                                        
                                    end
                                    
                                else
                                    
                                    for j = 1:length(selCycles)
                                        xData(j,:,:,i) = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i)));
                                    end
                                    
                                end
                            end
                            
                    end
                    
                case 4  % Body Vars
                    
                    444
                    
                    xData = zeros( length(selCycles) , zones , 1 , size(xSelect,1) );
                    
                    if skipCycles < 1
                        
                        if varDims{i} == zones + 1
                            work = hdf5read(cycles.Groups(selCycles(1)).Datasets(xSelect(i,1)));
                            xData(1,:,:,i) = work(2:end);
                        else
                            xData(1,:,:,i) = hdf5read(cycles.Groups(selCycles(1)).Datasets(xSelect(i,1)));
                        end
                        
                        if skipCycles == 0
                            k = 1;
                        else            % if cycSkip == -1
                            k = 2;
                        end
                        
                        for i = 1:size(xSelect,1)
                            if varDims{i} == zones + 1
                                for j = 2:length(selCycles)
                                    work = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i,k)));
                                    xData(j,:,:,i) = work(2:end);
                                end
                            else
                                for j = 2:length(selCycles)
                                    xData(j,:,:,i) = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(i,k)));
                                end
                            end
                        end
                        
                    else
                        
                        disp 'havent done this part 4'
                        
                    end
                    
                case 5  % Boundary and Body Vars
                    
                    555
                    xData(:,:,:,switchInd:length(xSelect)) = ...
                        qwer.dataHelper ( xSelect(switchInd:end) ,...
                        4 , yStatus , vars , zones, groups , ...
                        cycles , selZones , selGroups , selCycles , [] );
                    
                    if yStatus == 3
                        xData(:,end+1,:,switchInd:end) = xData(:,end,:,switchInd:end);
                    end
                    
                    xData(:,:,:,1:switchInd-1) = qwer.dataHelper ( ...
                        xSelect(1:switchInd-1) , 3 , yStatus , ...
                        vars , zones, groups , cycles , ...
                        selZones , selGroups , selCycles , [] );
                    
                    return
                    
                otherwise % used for 'jmx' and 'scal'
                    
                    666
                    
                    xData = zeros(length(selCycles),cycles.Groups(1).Datasets(xSelect(1)).Dims);
                    
                    if skipCycles < 1
                        
                        xData(1,:,:) = hdf5read(cycles.Groups(selCycles(1)).Datasets(xSelect(1)));
                        
                        if skipCycles == 0
                            k = 1;
                        else            % if cycSkip == -1
                            k = 2;
                        end
                                
                        % assume length(xSelect) == 1
                        for j = 2:length(selCycles)
                            xData(j,:,:) = hdf5read(cycles.Groups(selCycles(j)).Datasets(xSelect(k)));
                        end
                        return
                        
                    else
                        
                        disp 'havent done this yet part 1'
                        
                    end
                    
            end
            
            %% Trim data if needed
            
            if ~isempty(selZones) && selZones(end) > size(xData,2)
                boundary vars have one more value than body vars
                selZones(end) = [];
            end
            
            if size(xData,3) == 1
                if ~isempty(selZones)
                    xData                  = xData(:,selZones,    1    ,:);
                end
            elseif size(xData,2) == 1
                if ~isempty(selGroups)
                    xData                  = xData(:,   1    ,selGroups,:);
                end
            else
                if ~isempty(selZones)
                    if ~isempty(selGroups)
                        xData              = xData(:,selZones,selGroups,:);
                    else
                        xData              = xData(:,selZones,    :    ,:);
                    end
                elseif ~isempty(selGroups)
                    xData                  = xData(:,   :    ,selGroups,:);
                end
            end
            
        end

        function [ vars , cycSkip , scalInd , varargout ] =    qwery( varargin )
            
            [ vars , cycSkip , scalInd , varargout{1:nargout-2} ] = qwer.query(varargin{:});
            
        end
        
    end
    
end
