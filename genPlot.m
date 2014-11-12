% vectorization speeds up matrix operations
% (http://www.cs.ubc.ca/~murphyk/Software/matlabTutorial/html/speedup.html)

% for buckyPlot, have: change sidebar/background color scheme , grid on/off
%                      change main file     , change directory
% 
%        for change dir: if you addpath, which bucky.h5 gets loaded?


% tic toc

% change logeps to customEps

% Some functions, like mvnpdf() for example, interpret an n-by-d matrix, 
% not as n-times-d elements but as n, d-dimensional vectors. If this is 
% not what we are after, we can convert the matrix into a vector using 
% the (:) operator, pass it to the function, and reshape the output 
% back into the original size with the reshape() function.

% if you fork, dont delete the main file without comparing the two

% B2 = A(A < 0.2);

% A = meshgrid(1:6,1:5)'
% B = A - repmat(mean(A,1),size(A,1),1);     % center each column
% C = bsxfun(@minus, A, mean(A,1))           % center each column (the better way)
% check = isequal(B,C)
% D =  bsxfun(@rdivide,A,sqrt(sum(A.^2,1)))  % make each column have unit norm

% profile on
% profile viewer

% mat2cell and cellfun

% In your mfile, just do
% addpath('../anotherdir');
% or if you want to make it robust, do
% addpath(fullfile(pwd,'..','anotherdir'));

% help which mfilename fullfile addpath

% slice, isosurface

% grid on;      % option in buckyPlot
% smooth3();

% ability to plot 2d variables against: zone number, cycle number, ...
% zone radius, log zone radius, time, log time

classdef genPlot < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        mainFile;  % = 'bucky.h5';
        origFolder = pwd;      
        dataFolder;
        fig;
        
        graph;

        sidebar
        
    end
    
    properties (Dependent = true)
        
        saveFiles;
        
    end
    
    methods
        
        function obj = genPlot( varargin )
                        
            assignin('base','asdf',varargin)
            
            otherBuckyInp = false;
            
            if      length(varargin   ) == 1 && ...
                    length(varargin{1}) == 1 && ischar(varargin{1}{1}(1))
                
                varargin{1} = varargin{1}{1};
                otherBuckyInp = true;
                
            end
            
            if ~isempty(varargin) && ischar(varargin{1}) && length(varargin{1}) > 3
                if strncmp(varargin{1}(end-2:end),'.h5',3)
                    obj.mainFile = varargin{1};
                    %                     varargin(1) = [];
                elseif strncmp(varargin{1},'bucky',5)
                    obj.mainFile = [ varargin{1} '.h5' ];
                    %                     varargin(1) = [];
                else
                    obj.mainFile = 'bucky.h5';
                end
            else
                obj.mainFile = 'bucky.h5';
                
            end
            
            if isempty(varargin) || isempty(varargin{1}) || otherBuckyInp
                
                obj.fig = figure('Units','normalized','Position',[.06,.05,.88,.85]);
                
                obj.graph = axes('Units','normalized','Position',[.06,.08,.66,.84]);
                
                obj.sidebar = uipanel('Units', 'normalized','Position',[.75 -.5 .5 2]);
                
            end


            set(obj.fig,'toolbar','figure')
            
            deleteToolTips = ...
                { 'Edit Plot' , 'Insert Colorbar' , 'Insert Legend' } ;
            
            for i = 1:length(deleteToolTips)
                tth = findall(gcf,'ToolTipString',deleteToolTips{i});
                set(tth,'Visible','off')
            end

            %
            %             imageOfBucky = imread('imageOfBucky.jpg');
            %             image(imageOfBucky);
            
        end
                
        function folder = get.dataFolder(obj) 

            if strcmpi(obj.origFolder((end-5):end),'matlab')
                
                cd(obj.origFolder(1:(end-6)))
                
                if ( exist('src','dir') > 0 ) % bucky programs require a source folder
                    folder = obj.origFolder(1:(end-6));
                else
                    folder = obj.origFolder;
                end
                
                cd(obj.origFolder);
                
            else
                
                folder = obj.origFolder;
                
            end
          
        end
        
        function files  = get.saveFiles(obj)
            
            cd(obj.dataFolder)
            
            files = ls('bucky****.h5'); % is a string
            files = sort(regexp(files,'\t|\n','split')'); % make into array
            files = files(~cellfun('isempty',files)); % remove empty spaces
            
            for i = 1:length(files)
                if (strcmpi(obj.mainFile,files(i)) == 1)
                    files(i) = []; % remove mainFile from saveFiles
                    break
                end
            end
            
            cd(obj.origFolder)
            
        end
        
        function changeFile(obj,newFile)
           
            obj.mainFile = strtrim(newFile);
            
        end
                
    end
    
    methods (Static)
        
        
        
    end
    
    methods (Abstract)
       
        
        
    end
    
end

