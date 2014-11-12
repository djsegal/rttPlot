function openBuckyFile( obj , varargin )


% ===============
%  get main file
% ===============

if     length( varargin ) == 1
    
    % ---------------------------
    %  if called from a function
    % ---------------------------
    
    obj.mainFile = varargin{1} ;
    
elseif length( varargin ) == 2
    
    % -------------------------
    %  if called from a button
    % -------------------------
    
    try
        [ FileName , PathName , FilterIndex ]  =  ...
            uigetfile( {'*.h5'} , 'File Selector' , obj.mainFile ) ;
    catch
        [ FileName , PathName , FilterIndex ]  =  ...
            uigetfile( {'*.h5'} , 'File Selector' ) ;
    end

    if ( ~FilterIndex )  ,  return  ,  end
    
    obj.mainFile = [ PathName , FileName ] ;
    
end

curFile = obj.mainFile ;


% ====================================
%  use qwer to get needed information
% ====================================

[ varIndices , cycSkip , scalInd , nzones , ngroups ] = ...
    qwer.query(curFile,'jmx','r1a','te2a','tr2a','tn2a');

[ cycles , output  ] = qwer.cycles(curFile,scalInd,cycSkip);

[ obj.jmax , obj.r1a , obj.temp ] = qwer.data( ...
    { varIndices(1,:) , varIndices(2,:) , varIndices(3:5,:) } , ...
    [0,3,4] , 4 , [] , nzones , ngroups , cycles , ...
    [] , [] , output(:,3) , [] , cycSkip ) ;


% =============================
%  parse information from qwer
% =============================

obj.r1a          =  obj.r1a'     ;

obj.jmax         =  obj.jmax'    ;

obj.output_time  =  output(:,1)  ;

obj.temp         =  permute(obj.temp,[4 2 1 3]) ;

obj.origTimes    =  length(obj.output_time) ;

%  get logEps

obj.logEps         =  min(log10(obj.r1a(1,isfinite(log(obj.r1a(1,:))))))  ;

if isempty(obj.logEps)

    obj.logEps     =  min(log10(obj.r1a(2,isfinite(log(obj.r1a(2,:))))))  ;
    
else
    
    obj.logEps     =  min( ...
        obj.logEps ,  min(log10(obj.r1a(2,isfinite(log(obj.r1a(2,:))))))) ;
    
end

% ===================================================
%  Create Regions Layer and add Text and Temp Layers
% ===================================================

makeRegions( obj )

if     length( varargin ) == 1 , return , end

createRegionsPlot(obj,obj.graph)

formatAxes( obj , -2 , obj.allLayers )


% ====================================
%  needed for auto-zoom functionality
% ====================================

zoom(1)

curRegns  =  cellstr(  num2str( (1:size(obj.jmax,1))' )  )  ;

if strncmp(get(obj.modeButton,'String'),'REGIONS',5)
 
    [   obj.legendA  , obj.legendB ] = legendflex( obj     , ...
        obj.basePlot , curRegns      , 'ref'     , obj.fig , ...
        'bufferunit' , 'Normalized'  , 'anchor'  , [7 7]   , ...
        'buffer'     , [ +.707 +.9 ] , 'curVis'  , 'off'   )  ;
    
else
    
    changeMode(obj)
    
    [   obj.legendA  , obj.legendB ] = legendflex( obj     , ...
        obj.basePlot , curRegns      , 'ref'     , obj.fig , ...
        'bufferunit' , 'Normalized'  , 'anchor'  , [7 7]   , ...
        'buffer'     , [ +.707 +.9 ] , 'curVis'  , 'off'   )  ;
    
    changeMode(obj)

end

%             customEpsilon = min(obj.r1a(2,:))/50; % smallest recognized value ( ~0 )
%             %lgep = log10(customEpsilon); % global variable                ( ~log(0) )
%
%             obj.r1a(1,:) = customEpsilon; % smallest recognized value

autoZoom(obj)


% ================================================
%  wrap up a file opening with a call to makePlot
% ================================================

notify( obj , 'needUpdate' )  ;


end

