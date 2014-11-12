function changeMode(obj)

if strncmp(get(obj.modeButton,'String'),'REGIONS',5)
    
    set(obj.modeButton,'String','LINES')
    
    for i = length(obj.regionLabels) : -1 : 1
        
        if ishandle(  obj.regionLabels(i)  )
            
            delete(   obj.regionLabels(i)  )
            
        end
        
        obj.regionLabels(i) = [] ;
        
    end
    
    %     try
    %        delete( obj.legendA )
    %        delete( obj.legendB )
    %     catch
    %         % temporary fix because legendflex needs the area plot to label
    %     end
    
    %     try
    %         delete(obj.textLayer)
    %     catch
    %         % buckyPlot deletes obj.textLayer sometimes
    %     end
    
else
    
    set(obj.modeButton,'String','REGIONS')
    createRegionsPlot(obj,obj.graph)
    
    makeLayers( obj )
    
end

set(obj.sliderBar,'Value',obj.prevScalVal)

tmpScalVal      = obj.prevScalVal;
obj.prevScalVal = obj.scalVal;
obj.scalVal     = tmpScalVal;

notify(obj,'needUpdate');
formatAxes(obj,obj.allLayers)

uistack( obj.pointsLayer , 'top' )

end