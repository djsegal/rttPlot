function zlimits = makeLabelText_getZlimits(   ...
    x , y , z , xlimits , ylimits , curIndices  )

% ======================================
%  using time information , check which
%    regions are in the current plot
% ======================================

zlimits  =  [ -1 , -1 ]  ;

for h = 1 : 2
    
    % ------------------------------------------------
    %  find which regions are in the plot by checking
    %       them one-by-one in both directions
    % ------------------------------------------------
    
    switch h
        
        case 1  ,  workIndices  =  1 : +1 : size( z , 1 ) ;
            
        case 2  ,  workIndices  =  fliplr( workIndices )  ;
            
    end
    
    for i = workIndices
        
        inPlot  =  false ;
        
        % ------------------------------------------
        %  get the current region border at every x
        % ------------------------------------------
        
        yWork   =  zeros( size(y,2) , 1 ) ;
        
        switch h
            
            case 1
                
                for j = 1 : length( yWork )
                    
                    yWork(j) = y(    z( i , j ) - 1       ,  j  )  ;
                    
                end
                
            case 2
                
                if i == 1
                    
                    for j = 1 : length( yWork )
                        
                        yWork(j)  =  y(       1        ,  j  )  ;
                        
                    end
                    
                else
                    
                    for j = 1 : length( yWork )
                        
                        yWork(j)  =  y(  z( i-1 , j )-1  ,  j  )  ;
                        
                    end
                    
                end
                
        end
        
        % ------------------------------------------
        %  check if endpoints of region are in plot
        % ------------------------------------------
        
        for j = 1 : 2
            
            curZone = interp1( x , yWork , xlimits(j) ) ;
            
            if  curZone  >  ylimits(1)  &&  curZone  <  ylimits(2)
                
                inPlot = true ;
                
            end
            
        end
        
        % ---------------------------------
        %     check for non-monotonicity
        %     i.e. a region appearing in
        %  the plot between the two endpts
        % ---------------------------------
        
        if  curIndices(1) <     1      ,  curIndices(1) =     1      ;  end
        if  curIndices(2) > length(x)  ,  curIndices(2) = length(x)  ;  end
        
        if ~inPlot
            
            for j = curIndices(1)+1 : curIndices(2)-1
                
                if yWork(j) > ylimits(1) && yWork(j) < ylimits(2)
                    
                    inPlot = true ;
                    break
                    
                end
                
            end
            
        end
        
        % ----------------
        %  add new zlimit
        % ----------------
        
        if inPlot
            
            zlimits(h) = i ;
            break
            
        end
        
    end
    
end

% ============================
%  if zoomed-in plot contains
%   only one or two regions
% ============================

if  zlimits(1) ~= -1  &&  zlimits(2) == -1
    
    zlimits(2) = zlimits(1) ;
    
end

if  zlimits(2) ~= -1  &&  zlimits(1) == -1
    
    zlimits(2) = max( 1 , zlimits(2) - 1 ) ;
    
    zlimits(1) = max( 1 , zlimits(2) - 1 ) ;
    
end

if isequal( zlimits , [ -1 , -1 ] )
    
    % ------------------------------------
    %  check if curPt is in curRange of z
    % ------------------------------------
    
    curPt = mean( ylimits ) ;
    
    curRange = [ -1 -1 ] ;
    
    for i = 1 : +1 :  size( z , 1 )
        
        if i == 1
            curRange(1) = 0 ;
        else
            curRange(1) = y( z(i-1,1)-1 , curIndices(1) ) ;
        end
        
        curRange(2)     = y( z(i  ,1)-1 , curIndices(1) ) ;
        
        if curPt >= curRange(1) && curPt <= curRange(2)
            
            zlimits = [ i , i ] ;
            
            break
            
        end
        
    end
    
end

end

