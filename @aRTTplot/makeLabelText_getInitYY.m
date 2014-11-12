function yy = makeLabelText_getInitYY( x , y , z , xx , ylimits , zz , curInds )

% ======================
%  modifiable variables
% ======================

alpha    =  0.50 ;
delta    =  0.15 ;

% ======================
%  initialize variables
% ======================

indList  =  curInds(1) : curInds(2) ;

nx       =  length( indList ) ;
nyy      =  length(    xx   ) ;

yLo      =  zeros( nx ,  1  ) ;
yHi      =  zeros( nx ,  1  ) ;

yy       =  zeros( 1  , nyy ) ;

% ===============
%  get yy values
% ===============

for i = 1 : nyy
    
    % -------------------------
    %  get y bounds over range
    % -------------------------
    
    for j = 1 : nx
        
        jOff  =  indList(j) ;
        
        try
            
            yLo(j)  =  y(  z( zz(i) - 1 , jOff )  ,  jOff  ) ;
            
        catch
            
            yLo(j)  =  y(             1           ,  jOff  ) ;
            
        end
        
        yHi(j)      =  y(  z( zz(i) , jOff ) - 1  ,  jOff  ) ;
        
    end
    
    % ----------------------------
    %  get yy interpolated values
    % ----------------------------
    
    yyLo  =  max(  ylimits(1) , interp1( x(indList) , yLo , xx(i) )  ) ;
    yyHi  =  min(  ylimits(2) , interp1( x(indList) , yHi , xx(i) )  ) ;
    
    % ------------------------------------------------
    %  try to fix yy a little so that it is on screen
    % ------------------------------------------------
    
    curA  =  alpha ; 

    if yyLo == ylimits(1)  ,  curA = curA + delta  ;  end
    if yyHi == ylimits(2)  ,  curA = curA - delta  ;  end
    
    yy(i) = yyLo + curA * ( yyHi - yyLo )  ;
    
end

end