function restartPlot( obj )


% =============================
%  start by disabling autoPlot
% =============================

if ~isempty(obj.autoTimer)
    
    stop(obj.autoTimer)
    delete(obj.autoTimer)
    obj.autoTimer = [] ;
    
end

set(obj.autoRefreshButton,'Value',0) ;


% =============================================
%  reset vars to values assigned in aRTTplot.m
% =============================================


obj.radiusScale = 1;    % linear is default
obj.timeScale = 1; % linear is default
obj.tempScale = 1; % linear is default
obj.tempLimits = 1; % auto is default
obj.tempIndex = -1; % not equal to any used tempIndex

% variables for manual selection of tempLimit
obj.tmin = 0.1 ; % eV (default is 0.1 eV)
obj.tmax = 200 ; % eV (default is 200 eV)

obj.tempTitle = 'none' ;

obj.prevScalVal = 1;
obj.perVal = 1;

%obj.legendA = [] ;
%obj.legendB = [] ;
%obj.regionLabels = [] ;

obj.customZoomChoices = [] ;


% =============================================
%  change mode before changing other variables
% =============================================

if strncmp(get(obj.modeButton,'String'),'LINES',5)
    obj.scalVal      =  1.00  ;
    obj.prevScalVal  =  0.75  ;
    changeMode(obj)
else
    obj.scalVal      =  0.75  ;
    obj.prevScalVal  =  1.00  ;
    changeMode(obj)
    changeMode(obj)
end


% ==================================
%  reset regions/lines part of plot
% ==================================

if strncmp( get(obj.radScaleButton,'String') , 'LOG' , 3 )
    changeRadiusScale(obj)
end

if strncmp( get(obj.timeScaleButton,'String') , 'LOG' , 3 )
    changeTimeScale(obj)
end

%createRegionsPlot(obj,obj.graph)         %  prob not needed

%formatAxes( obj , -2 , obj.allLayers )   %  prob not needed


% =================================
%  reset temp overlay part of plot
% =================================

set( obj.other , 'value' , 0 )
set( obj.te2a  , 'value' , 0 )
set( obj.tr2a  , 'value' , 0 )
set( obj.tn2a  , 'value' , 0 )
set(obj.otherVar,'string','not selected');

if strncmp( get(obj.tempLimitsButton,'String') , 'MAN' , 3 )
    changeTempLimits(obj)
end

if strncmp( get(obj.tempShadingButton,'String') , 'FLAT' , 4 )
    changeTone(obj)
end

if strncmp( get(obj.tempScaleButton,'String') , 'LOG' , 3 )
    changeTempScale(obj)
end

changeTemp(obj,obj.noTemp)

% notify(obj,'needUpdate');        called in changeTemp


end