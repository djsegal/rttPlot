function formatAxes(obj,varargin)

% =======================================
%  update default limits for plots where
%    rad/time scales were just changed
% =======================================

if  varargin{1}(1) == -1 || varargin{1}(1) == -2

    % --------------
    %  setup y-axis
    % --------------
    
    if obj.radiusScale == 1
        
        minRadius = 0;
        maxRadius = 1.02*max(obj.r1a(:));
        
    else
        
        minRadius = obj.logEps;
        maxRadius = 1.02*log10(max((obj.r1a(:))))-.02*obj.logEps;
        
    end
    
    % --------------
    %  setup x-axis
    % --------------
    
    if obj.timeScale == 1
        
        minTime  =  0  ;
        maxTime  =  10^9 * max(obj.output_time)  ;
        
    else
        
        minTime  =  9 + log10( min(obj.output_time) )  ;
        maxTime  =  9 + log10( max(obj.output_time) )  ;
        
    end
    
    % ----------------------
    %  update defaultLimits
    % ----------------------
    
    obj.defaultLimits  =  [ minTime , maxTime , minRadius , maxRadius ]  ;
    
    % ---------------------------------
    %  do initial setting of curRanges
    %      and pop off varargin{1}
    % ---------------------------------
    
    if varargin{1} == -2
        
        obj.curRanges = obj.defaultLimits ;
        
    end
    
    varargin(1)  = [] ;
    
end

% ==============
%  setup labels
% ==============

if obj.radiusScale == 1
    
    ylabel( obj.graph , 'Radius [cm]'                 , 'fontsize' , 11 )
    
else
    
    ylabel( obj.graph , 'log( Radius ) [cm]'          , 'fontsize' , 11 )
    
end

if obj.timeScale == 1
    
    xlabel( obj.graph , 'Simulation Time [ns]'        , 'fontsize' , 11 )
    
else
    
    xlabel( obj.graph , 'log( Simulation Time ) [ns]' , 'fontsize' , 11 )
    
end

% =========================================
%  set the axes for every axis in varargin
% =========================================

for i = 1 : length(varargin)
    
    try
        
        axis(  varargin{i}  ,  obj.curRanges  )
        
    catch
        
        % obj.textLayer gets deleted for 'LINES' mode
        
    end
    
end

end