function customZoom(obj)

% ===========================================
%  allow a way to choose xlimits and ylimits
% ===========================================

% ---------------------------------------------------
%  get default ranges , needed for multiple purposes
% ---------------------------------------------------

defaultChoices  =  cell( 1 , length(obj.defaultLimits  ) ) ;

for i = 1 : length(obj.defaultLimits)
    
    defaultChoices{i}  =   num2str( obj.defaultLimits(i) ) ;
    
end

defaultChoices{end+1}  =  '0' ;  %  useLinLin
defaultChoices{end+1}  =  '0' ;  %  resetVals

% ----------------------------------------
%  get given input for interactive prompt
% ----------------------------------------

if isempty( obj.customZoomChoices )
    
    givenInput  =         defaultChoices  ;
    
else
    
    givenInput  =  obj.customZoomChoices  ;
    
end

% -----------------------------------
%  setup input window and display it
% -----------------------------------

prompt  =  {  ...
    'Min Time [ns]'    ,  'Max Time [ns]'    ,  ...
    'Min Radius [cm]'  ,  'Max Radius [cm]'  ,  ...
    'Use { LIN | LIN } For Input'            ,  ...
    'Reset Custom Zoom Values'               }   ;

windowTitle     =  'Zoom' ;

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
            newRanges  =  str2double(curInput(1:end-2)')  ;
            
            done       =  true ;

        catch inputValidationError
            
            msgbox('Radii and Time Boundaries must be Real Numbers.')  ;
            
        end
        
    end
    
end

useLinLin      =  ~strncmp( strtrim(curInput(end-1)) , '0' , 2 )  ;

resetVals      =  ~strncmp( strtrim(curInput(end  )) , '0' , 2 )  ;

curInput{end}  =  num2str( useLinLin )  ;

% ===========================
%  reset values if requested
% ===========================

if resetVals
    
    obj.customZoomChoices = defaultChoices ;
    
    customZoom(obj)
    
    return
    
end

% ================================
%  return for a number of reasons
% ================================

tmpLims   =  [   ...
    max(  abs( obj.defaultLimits(1:2) )  )   ,    ...
    max(  abs( obj.defaultLimits(3:4) )  )   ]     ;

% --------------------------------------------
%  do initial tests to see if new data is bad
% --------------------------------------------

for i = 1 : 1  %  1 : 1 is not a bug , it's on purpose
    
    newBad  =  true   ;
    
    if          any( newRanges < 0 )           ,  break  ;  end
    
    if      newRanges(2) <= newRanges(1)       ,  break  ;  end
    if      newRanges(4) <= newRanges(3)       ,  break  ;  end
    
    if abs( newRanges(2) ) > 100 * tmpLims(1)  ,  break  ;  end
    if abs( newRanges(4) ) > 100 * tmpLims(2)  ,  break  ;  end
       
    if     useLinLin      && newRanges(1) < 0  ,  break  ;  end
    if     useLinLin      && newRanges(3) < 0  ,  break  ;  end
    
    if obj.timeScale == 1 && newRanges(1) < 0  ,  break  ;  end
    if obj.radiusScale==1 && newRanges(3) < 0  ,  break  ;  end
    
    if obj.timeScale    ==  2
        
        if abs(newRanges(1)) > 100*tmpLims(1)  ,  break  ;  end
    end
    
    if obj.radiusScale  ==  2
        
        if abs(newRanges(3)) > 100*tmpLims(2)  ,  break  ;  end
    end
    
    newBad  =  false  ;
    
end

% ------------------------------
%  do one final validation step
% ------------------------------

for i = [ 1 , 3 ]
   
    if  newRanges(i) < obj.defaultLimits(i)
        
        newRanges(i) = obj.defaultLimits(i) ;
        
    end
    
end
    
for i = [ 2 , 4 ]
    
    if  newRanges(i) > obj.defaultLimits(i)
        
        newRanges(i) = obj.defaultLimits(i) ;
        
    end
    
end

if  newRanges(2) <= newRanges(1)  ,  newBad = true  ;  end
if  newRanges(4) <= newRanges(3)  ,  newBad = true  ;  end

% ------------------------------------------
%  if new data was bad , revert to old data
% ------------------------------------------

if newBad 
    
    obj.customZoomChoices  =  defaultChoices ;
    
    axis( obj.defaultLimits ) 
    
    makeRegionLabels( obj )
    
    return

end

% ===============================
%  convert data to log if needed
% ===============================

if useLinLin
    
    curScales   = [    obj.timeScale   ,   -1   ,   obj.radiusScale   ] ;
    
    newPossVals = [ 9 + log10( min(obj.output_time) ) , -1 , obj.logEps ] ;
    
    for i = [ 1 , 3 ]
       
        if curScales(i) == 2
            
            newRanges(i:i+1) = log10( newRanges(i:i+1) ) ;
            
            if  newRanges(i) == -Inf
                
                newRanges(i) =  newPossVals(i) ;
                
            end
            
            if newRanges(i) > newRanges(i+1)
               
                newRanges(i:i+1)  =  fliplr( newRanges(i:i+1) ) ;
                
            end
                
        end
        
    end
        
end

% ============================
%  make actual changes to obj
% ============================

obj.customZoomChoices  =  curInput   ;

obj.curRanges          =  newRanges  ;

axis( obj.curRanges ) 

makeRegionLabels( obj )

end