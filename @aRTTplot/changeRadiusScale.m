function changeRadiusScale(obj)

% =================================
%  change radScale and update plot
% =================================

if strncmp(get(obj.radScaleButton,'String'),'LIN',3)
    
    set(obj.radScaleButton,'String','LOG')
    obj.radiusScale = 2;
    %      r1a(1,:) = nearZero;
    
else
    
    set(obj.radScaleButton,'String','LIN')
    obj.radiusScale = 1;
    %      r1a(1,:) = 0;
    
end

% % scale changes reset limits unless custom zoom is activated
% if obj.zoomStatus ~= 1
%       xlim([0 1])
%       ylim([0 1])
% end

if strncmp(get(obj.modeButton,'String'),'REGIONS',5)
    
    createRegionsPlot(obj,obj.graph)
    
end
    
notify( obj , 'needUpdate' ) ;

formatAxes( obj , -1 , obj.allLayers ) ;


if obj.radiusScale == 2
   
    obj.curRanges(3:4) = log10( obj.curRanges(3:4) ) ;

    if  obj.curRanges(3) == -Inf
        
        obj.curRanges(3)  = obj.logEps ;
        
    end
    
else
 
    if  obj.curRanges(3) == obj.logEps
       
        obj.curRanges(3)  = 0 ;
        
    else
        
        obj.curRanges(3)  = 10 ^ obj.curRanges(3) ;
        
    end
    
    obj.curRanges(4) = 10 ^ obj.curRanges(4) ;
    
end


curYData = get( obj.allPoints , 'YData' ) ;

if ~isempty( curYData )
    
    if obj.radiusScale == 2
        
        obj.selectedPoints(:, 2)  =  log10(curYData) ;
        
    else
        
        obj.selectedPoints(:, 2)  =  10.^( curYData) ;
        
    end
    
    set( obj.allPoints , 'YData' , obj.selectedPoints(:, 2) );

end


axis(obj.defaultLimits)
zoom('reset')
axis(obj.curRanges)

makeRegionLabels(obj)
% 
% delete( obj.allPoints ) ;
% 
% [   obj.xInputPts   , obj.yInputPts ,     ...
%     obj.pointsLayer , obj.allPoints ]  =  ...
%     makePoints( 'LineWidth' , 1 , 'ShowPoints'  , true , ...
%     'xx' , obj.xInputPts , 'yy' , obj.yInputPts ) ;

end