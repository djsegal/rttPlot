function createRegionsPlot(obj,curAxes)

% -------------------------------------------
%  buckyPlot calls this function, therefore, 
%    short circuit function for bad input
% -------------------------------------------

if strncmp(get(obj.modeButton,'String'),'LINES',5)

    return

end

% -------------------------
%  create the region areas 
%  using {lin/log} Regions
% -------------------------

cla(curAxes)

if obj.radiusScale == 1

    if obj.timeScale == 1

        obj.basePlot = area(curAxes,...
            obj.output_time*1.e9       ,obj.linRegions',...
            'LineStyle','none','BaseValue',0);

    else

        obj.basePlot = area(curAxes,...
            log10(obj.output_time*1.e9),obj.linRegions',...
            'LineStyle','none','BaseValue',0);

    end

else

    if obj.timeScale == 1

        obj.basePlot = area(curAxes,...
            obj.output_time*1.e9       ,obj.logRegions',...
            'LineStyle','none','BaseValue',obj.logEps);

    else

        obj.basePlot = area(curAxes,...
            log10(obj.output_time*1.e9),obj.logRegions',...
            'LineStyle','none','BaseValue',obj.logEps);

    end
    
end

% ========================================
%     change the colors of the regions
%  ASSUME there are fewer than 10 Regions
% ========================================

for i = 1:length(obj.basePlot)

    set(obj.basePlot(i),'facecolor',obj.colorList{i});

end

end