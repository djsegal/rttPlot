function changeTempLimits(obj)

if strncmp(get(obj.tempLimitsButton,'String'),'AUTO',3)
    
    set(obj.tempLimitsButton,'String','MAN')
    obj.tempLimits = 2;
    
    if obj.tempScale == 1
        caxis(obj.topLayer,       [ obj.tmin obj.tmax ]  )
    else % tempScale == 2
        caxis(obj.topLayer, log10([ obj.tmin obj.tmax ]) )
    end
    
else
    
    set(obj.tempLimitsButton,'String','AUTO')
    obj.tempLimits = 1;
    caxis(obj.topLayer, 'auto' )
    
end

end