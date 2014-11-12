function makePlot(obj,varargin)                       
    
%             varargin{2}

% needed for zooming

obj.xyLimits = [xlim ; ylim];

cla(obj.topLayer)

% ---------------------------------
%  create tempOverlay and colorbar
% ---------------------------------

if obj.tempIndex > 0
    
    obj.tempOverlay = createTempsPlot(obj,obj.topLayer);
    
    ch=findall(gcf,'tag','Colorbar');
    delete(ch);
    
    if obj.tempIndex ~= 4
        
        set(obj.evLabel,'Visible','on')
        
        if obj.isBuckyPlot
            colorbar('peer',obj.topLayer,'position',[ .765 .08 .022 .87 ]);
        else
            colorbar('peer',obj.topLayer,'position',[ .765 .03 .022 .9 ]);
        end
        
    else
        
        set(obj.evLabel,'Visible','off')
        
        if obj.isBuckyPlot
            colorbar('peer',obj.topLayer,'position',[ .765 .08 .022 .87 ]);
        else
            colorbar('peer',obj.topLayer,'position',[ .765 .03 .022 .92 ]);
        end
        
    end
    
end
   
% ---------------
%  title section
% ---------------

if strncmp( obj.tempTitle , 'none' , 4 )
    
    titleString = 'Region vs Time Plot' ;
    
else
   
    titleString = 'Time, Zone, and Temperature (';
    
    if obj.tempScale == 1
        titleString = strcat(titleString,obj.tempTitle,') Plot');
    else
        titleString = strcat(titleString,'log(',obj.tempTitle,')) Plot');
    end
    
end
    
title(obj.graph,titleString,'fontsize',13,'FontWeight','bold','Interpreter','none');

% --------------------------
%  add lines and/or regions
% --------------------------

if strncmp(get(obj.modeButton,'String'),'LINES',5)
    cla(obj.graph)
    createLinesPlot(obj,obj.topLayer)
end

formatAxes(obj,obj.allLayers)
makeRegionLabels(obj)

% BUG: zoomStatus = 0 after min=9999 and xyLimits are still set wrong

% keep the same zoom limits through different plots
% (not for different time and radius scales, though
% if obj.xyLimits ~= [0 1 ; 0 1] & obj.zoomStatus ~= 1
%     xlim(obj.xyLimits(1,:))
%     ylim(obj.xyLimits(2,:))
% end

end