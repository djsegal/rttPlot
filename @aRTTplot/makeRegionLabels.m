function makeRegionLabels(obj,varargin)

% ***************************************************
%    a lot of this function has weird structure.
%  this is b/c this funciton needs to work with zoom
%  which does a lot of bizarre stuff w/ double-click
% ***************************************************

% ==================================
%          setup curAxes
%  needed here or half the function 
%    gets skipped from zooms/pans
% ==================================

makeLayers( obj )

if strncmp(get(obj.modeButton,'String'),'LINES',5)
    
    axes(obj.topLayer)
    
else
    
    axes(obj.textLayer)
        
end

% ========================
%  fix double click zooms
% ========================

doubleClick = strcmp(get(obj.fig,'SelectionType'),'open') ;

if doubleClick
        
    axis( obj.defaultLimits )
    
    set( obj.fig , 'SelectionType' , 'normal'  )
     
end

% ======================================
%  do a general clear of the text layer
%       to set it up for new labels
% ======================================

cla(obj.textLayer)
    
% ==========================================================
%  if there are more than 9 regions, they don't have labels
%      (also interp1s needs at least 2 data points)
% ==========================================================

if       size(obj.linRegions,1) < 2 ||            ...
        length(obj.output_time) < 2 || size(obj.linRegions,1) > 9
    
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %  linRegions and logRegions have the same number of regions
    %       i.e. regionCount = size(obj.linRegions,1);
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    return
    
end

% ========================================
%  get the curRanges from the axis limits
% ========================================

[ timeBounds , radBounds ]        =         ...
    aRTTplot.getPanLimits(  axis  ,  obj.defaultLimits  )  ; 

obj.curRanges  =  [ timeBounds , radBounds ]  ;

axis( obj.curRanges ) 

% --------------------------------
%  remove remaining region labels
% --------------------------------

for i = length(obj.regionLabels) : -1 : 1
    
    if ishandle(  obj.regionLabels(i)  )
                
        delete(   obj.regionLabels(i)  )
        
    end
    
end

obj.regionLabels = [] ;

% =====================================
%  evenly spread text over entire plot
%    and center within each region
% =====================================

if obj.radiusScale == 1
    
    if obj.timeScale == 1
        
        obj.regionLabels  =  aRTTplot.makeLabelText(  obj.jmax     ,  ...
            (     obj.output_time*1.e9)    ,    (     obj.r1a  )   ,  ...
            (          timeBounds     )    ,    (     radBounds)   )   ;
        
    else
        
        obj.regionLabels  =  aRTTplot.makeLabelText(  obj.jmax     ,  ...
            log10(obj.output_time*1.e9)    ,    (     obj.r1a  )   ,  ...
            (          timeBounds     )    ,    (     radBounds)   )   ;
        
    end
    
else
    
    if obj.timeScale == 1
        
        obj.regionLabels  =  aRTTplot.makeLabelText(  obj.jmax     ,  ...
            (     obj.output_time*1.e9)    ,    log10(obj.r1a  )   ,  ...
            (          timeBounds     )    ,    (     radBounds)   )   ;
        
    else
        
        obj.regionLabels  =  aRTTplot.makeLabelText(  obj.jmax     ,  ...
            log10(obj.output_time*1.e9)    ,    log10(obj.r1a  )   ,  ...
            (          timeBounds     )    ,    (     radBounds)   )   ;
        
    end
    
end

% ================================================
%  special case for when there is no data on plot
% ================================================

if obj.regionLabels == -1

    set( obj.legendA , 'visible' , 'off' )
    set( obj.legendB , 'visible' , 'off' )
    
    obj.regionLabels = [] ;

    return
    
end

% =======================================
%  add thick lines for special case when 
%    only one data point is on the plot
% =======================================

if isempty( obj.regionLabels )

    if strncmp(get(obj.modeButton,'String'),'REGIONS',5)

        createLinesPlot( obj )
        
        set( findobj(obj.textLayer,'type','line') , 'LineWidth' , 5 ) ;
        
    end
    
end


% ====================================
%     manage the region legend that 
%  gets added for far-zoomed in plots
% ====================================

if ~strncmp(get(obj.modeButton,'String'),'REGIONS',5) 
    
    return
    
end


% =====================================
%  manage the rest of the legend cases
% =====================================

if isempty( obj.legendA ) 
    
    error('legend does not exist')
    
end

if isempty( obj.regionLabels ) 
    
    uistack( obj.legendA , 'top' )
    
    set( obj.legendA , 'visible' , 'on'  )
    set( obj.legendB , 'visible' , 'on'  )
    
else
    
    set( obj.legendA , 'visible' , 'off' )
    set( obj.legendB , 'visible' , 'off' )
        
end

end