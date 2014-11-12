function createLinesPlot(obj,varargin)

% ===================================
%  varargin needed for a zooming fix
% ===================================

% ---------------------------------------
%  get curAxes and hold lines properties
% ---------------------------------------

if ~isempty(varargin)
    
    curAxes = varargin{1} ;
    
    axes( curAxes ) ;
    
else
    
    curAxes = gca ;
    
end

hold all

% ----------------------------
%  set up which lines to plot
% ----------------------------

indicesList = cell(4,1);

curRegion = 1;

if mod(1,obj.perVal) ~= 0
    
    indicesList{1} = 1;
    
end

for i = 1:size(obj.r1a,1)
    
    if mod(i,obj.perVal) == 0
        
        if i >= obj.jmax(curRegion,1)
            
            curRegion = curRegion + 1 ;
            indicesList{curRegion} = [ i ] ;
            
        else
            
            indicesList{curRegion}(end+1) = i ;
            
        end
        
    end
    
end

if mod(size(obj.r1a,1),obj.perVal) ~= 0
    indicesList{end}(end+1) = i;
end

% -----------------------------
%  plot the desired zone lines
% -----------------------------

if obj.radiusScale == 1
    
    if obj.timeScale == 1
        
        for i = 1:length(indicesList)
            
            if isempty(indicesList{i}) , continue , end
            
            plot( curAxes ,        obj.output_time * 1.e9   , ...
                obj.r1a(indicesList{i},:) , 'color' , obj.colorList{i} ) ;
            
        end
        
    else
        
        for i = 1:length(indicesList)
            
            if isempty(indicesList{i}) , continue , end
            
            plot( curAxes , log10( obj.output_time * 1.e9 ) , ...
                obj.r1a(indicesList{i},:) , 'color' , obj.colorList{i}) ;
            
        end
        
    end
    
else
    
    if obj.timeScale == 1
        
        for i = 1:length(indicesList)
            
            if isempty(indicesList{i}) , continue , end
            
            plot( curAxes ,        obj.output_time * 1.e9    , ...
                log10( obj.r1a(indicesList{i},:) ) , 'color' , obj.colorList{i} ) ;
            
        end
        
    else
        
        for i = 1:length(indicesList)
            
            if isempty(indicesList{i}) , continue , end
            
            plot( curAxes , log10( obj.output_time * 1.e9 )  , ...
                log10( obj.r1a(indicesList{i},:) ) , 'color' , obj.colorList{i} ) ;
            
        end
        
    end
    
end

end