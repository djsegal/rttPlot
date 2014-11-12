function  badIndices  =  makeLabelText_findBad(  ...
    x , y , z , xx , zz , ylimits , zlimits , curIndices )

% ==================
%  find bad indices
% ==================

nx  =  diff( curIndices ) + 1   ;
nz  =  diff(   zlimits  ) + 1   ;

% -----------------------------------------------
%    if a one region plot has gotten this far
%  it is the outer region (connected to nothing)
% -----------------------------------------------

if nz == 1
    
    badIndices = zlimits(1) ;
    
    return
    
end

% -------------------------------------------------
%  check if any region labels are in bad locations
% -------------------------------------------------

badIndices = [] ;

yy     =  zeros(  nz  ,  1  )  ;

nextY  =  zeros(  nx  ,  1  )  ;
prevY  =  ones(   nx  ,  1  )  ;

prevY  =  prevY * ylimits(1)   ;

for i = 1 : nz
    
    for j = 1 : nx
        
        jOff      =   j + ( curIndices(1) - 1 ) ;
        
        nextY(j)   =   y(  z( zz(i) , j ) - 1  ,  jOff  ) ;
        
    end
    
    prevYY  =  interp1( x(curIndices(1):curIndices(2)) , prevY , xx(i) )  ;
    nextYY  =  interp1( x(curIndices(1):curIndices(2)) , nextY , xx(i) )  ;
    
    prevY   =  nextY ;
    
    yy(i)   =  0.5 * ( ...
        max(  ylimits(1)  , prevYY ) + ...
        min(  ylimits(2)  , nextYY ) );
    
    yDelta  =  [ (0.1)*(nextYY-prevYY) , (0.2)*diff(ylimits) ]   ;
    
    if      yy(i)  <  prevYY      +  yDelta(1)  ||  ...
            yy(i)  >  nextYY      -  yDelta(1)  ||  ...
            yy(i)  <  ylimits(1)  +  yDelta(2)  ||  ...
            yy(i)  >  ylimits(2)  -  yDelta(2)
        
        badIndices(end+1) = zlimits(1) + ( i - 1 )  ; 
        
    end
    
end

end

