function customOpts(obj)


% ===========================================
%  allow a way to choose xlimits and ylimits
% ===========================================

% ---------------------------------------------------
%  get default ranges , needed for multiple purposes
% ---------------------------------------------------

givenInput  =  { ...
    num2str(obj.tmin ) , num2str(obj.tmax) , ...
    num2str(obj.Twait) , num2str(obj.Tnum) , ... 
    '0' } ;

% -----------------------------------
%  setup input window and display it
% -----------------------------------

prompt  =  {  ...
    'Min Temp [eV]'       ,   'Max Temp [eV]'       , ...  
    'Auto Wait Time [s]'  ,   'Auto Call Limit [#]' , ...
    'Reset Custom Zoom Values'               }   ;

windowTitle     =  'Options' ;

options.Resize  =  'on'   ;

% ------------------------------------
%  try to get newRanges from curInput
% ------------------------------------

done = false ;

while ~done
    
    curInput   =   inputdlg(  ...
        prompt , windowTitle , 1 , givenInput , options  )   ;
    
    if isempty(curInput)
        
        return
        
    else
        
        try
            newRanges  =  str2double(curInput(1:4)')  ;
            
            done       =  true ;

        catch inputValidationError
            
            msgbox('Temperature Boundaries must be Real Numbers.')  ;
            
        end
        
    end
    
end

resetVals      =  ~strncmp( strtrim(curInput(end  )) , '0' , 2 )  ;


% ===========================
%  reset values if requested
% ===========================

if resetVals
    
    obj.tmin   =  0.1 ;  % eV (default is 0.1 eV)
    obj.tmax   =  200 ;  % eV (default is 200 eV)
    
    obj.Twait  =  1e1 ;  % secs b/w calls for autoMode
    obj.Tnum   =  1e3 ;  % calls before autoMode is disabled
    
    customOpts(obj)
    
    return
    
end


% ===============
%  update values
% ===============

obj.tmin   =  newRanges(1) ;
obj.tmax   =  newRanges(2) ;
obj.Twait  =  newRanges(3) ;
obj.Tnum   =  newRanges(4) ;


% ===============================
%  update temp overlay if needed 
% ===============================

if ( obj.tmin ~= 0.1 || obj.tmax ~= 200 || obj.tempLimits == 2 )

    if obj.tempLimits == 1
        changeTempLimits(obj)
    else
        if obj.tempScale == 1
            caxis(obj.topLayer,       [ obj.tmin obj.tmax ]  )
        else % tempScale == 2
            caxis(obj.topLayer, log10([ obj.tmin obj.tmax ]) )
        end
    end
        
end


% ============================
%  update auto plot if needed
% ============================

if ( obj.Twait ~= 1e1 || obj.Tnum ~= 1e3  || ~isempty( obj.autoTimer ) )

    if ~isempty( obj.autoTimer )
        stop(obj.autoTimer)
        delete(obj.autoTimer)
        obj.autoTimer = [] ;
    end

    set(obj.autoRefreshButton,'value',1)
    autoPlot( obj )

end


end

