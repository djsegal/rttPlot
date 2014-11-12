function sliderFork(obj,varargin)

if ~isempty(varargin)
    obj.scalVal  =  get(varargin{1},'Value')  ;
end

% ------------------------------------
%  change temp visibility for regions
% ------------------------------------

if strncmp(  get( obj.modeButton , 'String' )  ,  'REGIONS'  ,  5  )
    
    if obj.tempIndex > 0
        
        alpha(obj.tempOverlay,obj.scalVal)
        set(obj.topLayer,'visible','off')
        
    end
    
    return
    
end

% ----------------------------------
%  change line count for line plots 
%      (i.e. not region plots)
% ----------------------------------

lh=findall(obj.topLayer,'type','line');
delete(lh);

if obj.scalVal < .05
    
    obj.scalVal = 0;
    
elseif obj.scalVal > .95
    
    obj.scalVal = 1;
    
end

set(obj.sliderBar,'value',obj.scalVal);

obj.perVal = round( 1 + 20 * ( 1 - obj.scalVal ) ) ;

cla(obj.graph)
createLinesPlot(obj,obj.topLayer)

makeRegionLabels(obj)

end