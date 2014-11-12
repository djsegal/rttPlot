function tempPlot = createTempsPlot(obj,curAxes)

% -------------------------------------------------------------------------
%                  Simpler Version of Following IF Tree
% -------------------------------------------------------------------------
%
%         workTime = obj.output_time*1.e9;
%         workRad  = obj.r1a;
%         workTemp = squeeze(obj.temp(obj.tempIndex,:,:));
%
%         if obj.timeScale   ~= 1; workTime = log10(workTime) ; end;
%         if obj.radiusScale ~= 1; workRad  = log10(workRad ) ; end;
%         if obj.tempScale   ~= 1; workTemp = log10(workTemp) ; end;
%
%         obj.tempOverlay = pcolor(obj.topLayer,workTime,workRad,workTemp);
%
% -------------------------------------------------------------------------

if obj.timeScale == 1
    if obj.radiusScale == 1
        if obj.tempScale == 1
            tempPlot = pcolor(curAxes,...
                obj.output_time*1.e9,obj.r1a,...
                squeeze(obj.temp(obj.tempIndex,:,:)));
        else
            tempPlot = pcolor(curAxes,...
                obj.output_time*1.e9,obj.r1a,...
                log10(abs(squeeze(obj.temp(obj.tempIndex,:,:)))));
        end
    else
        if obj.tempScale == 1
            tempPlot = pcolor(curAxes,...
                obj.output_time*1.e9,log10(obj.r1a),...
                squeeze(obj.temp(obj.tempIndex,:,:)));
        else
            tempPlot = pcolor(curAxes,...
                obj.output_time*1.e9,log10(obj.r1a),...
                log10(abs(squeeze(obj.temp(obj.tempIndex,:,:)))));
        end
    end
else
    if obj.radiusScale == 1
        if obj.tempScale == 1
            tempPlot = pcolor(curAxes,...
                log10(obj.output_time*1.e9),obj.r1a,...
                squeeze(obj.temp(obj.tempIndex,:,:)));
        else
            tempPlot = pcolor(curAxes,...
                log10(obj.output_time*1.e9),obj.r1a,...
                log10(abs(squeeze(obj.temp(obj.tempIndex,:,:)))));
        end
    else
        if obj.tempScale == 1
            tempPlot = pcolor(curAxes,...
                log10(obj.output_time*1.e9),log10(obj.r1a),...
                squeeze(obj.temp(obj.tempIndex,:,:)));
        else
            tempPlot = pcolor(curAxes,...
                log10(obj.output_time*1.e9),log10(obj.r1a),...
                log10(abs(squeeze(obj.temp(obj.tempIndex,:,:)))));
        end
    end
end

% -------------------------------------------------------------------------
%            SEE Above for Simpler Version of Preceding IF Tree
% -------------------------------------------------------------------------

% =============================
%  set various viewing options
% =============================

% ---------------------------
%  transparency of temp plot
% ---------------------------

if strncmp( get(obj.modeButton,'String') , 'REGIONS' , 5 )
    
    alpha( tempPlot , obj.scalVal )
    
else
    
    alpha( tempPlot , 1 )
    
end

% -------------------------
%  set cell shading method
% -------------------------

if strncmp( get(obj.tempShadingButton,'String') , 'SMOOTH' , 4 )
    
    shading( curAxes , 'interp' ) ;
    
else
    
    % ***********************************
    %    interp data gives bad results
    %  when zooming and using log(times)
    % ***********************************
    
    shading( curAxes , 'flat' ) ;
    
end

set( curAxes , 'visible' , 'off' )  %  somehow makes pcolor transparent

% --------------------------
%  set coloring information
% --------------------------

if obj.tempLimits == 1
    
    caxis( curAxes , 'auto' )
    
else % tempLimits == 2
    
    if obj.tempScale == 1
        
        caxis(  curAxes  ,         [ obj.tmin obj.tmax ]    )
        
    else % tempScale == 2
        
        caxis(  curAxes  ,  log10( [ obj.tmin obj.tmax ] )  )
        
    end
    
end

end