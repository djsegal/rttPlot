function changeTimeScale(obj)

% ==================================
%  change timeScale and update plot
% ==================================

if strncmp( get(obj.timeScaleButton,'String') , 'LIN' , 3 )

    set( obj.timeScaleButton , 'String' , 'LOG' )
    obj.timeScale = 2;

else

    set( obj.timeScaleButton , 'String' , 'LIN' )
    obj.timeScale = 1;

end

if strncmp( get(obj.modeButton,'String') , 'REGIONS' , 5 )

    createRegionsPlot( obj , obj.graph )

end
    
notify( obj , 'needUpdate' ) ;



if obj.timeScale == 2
    
    obj.curRanges(1:2) = log10( obj.curRanges(1:2) ) ;
    
    if  obj.curRanges(1) == -Inf
        
        obj.curRanges(1) =  9 + log10( min(obj.output_time) ) ;
        
    end
    
else
    
    if obj.curRanges(1)  == 9 + log10( min(obj.output_time) )
        
        obj.curRanges(1)  = 0 ;
        
    else
        
        obj.curRanges(1)  = 10 ^ obj.curRanges(1) ;
        
    end
    
    obj.curRanges(2) = 10 ^ obj.curRanges(2) ;
    
end


curXData = get(obj.allPoints,'XData') ;

if ~isempty( curXData )
    
    if obj.timeScale == 2
        
        obj.selectedPoints(:, 1)  =  log10(curXData) ;
        
    else
        
        obj.selectedPoints(:, 1)  =  10.^(curXData) ;
        
    end
    
    set( obj.allPoints , 'XData' , obj.selectedPoints(:, 1) );
    
end

pause(.01)  % needed to stop a seg fault
axis(obj.defaultLimits)
zoom('reset')
axis(obj.curRanges)

formatAxes( obj , -1 , obj.allLayers ) ;

makeRegionLabels(obj)
% 
% delete( obj.allPoints ) ;
% 
% [   obj.xInputPts   , obj.yInputPts ,     ...
%     obj.pointsLayer , obj.allPoints ]  =  ...
%     makePoints( 'LineWidth' , 1 , 'ShowPoints'  , true , ...
%     'xx' , obj.xInputPts , 'yy' , obj.yInputPts ) ;

end