function [ possInds , badInds , maxDiff , xWork , yWork ] = makeLabelText_findLocs( ...
    x , y , z , xx , zz , xlimits , ylimits , zlimits , ...
    curInds , badInds , nl )

% ============================================
%  find possible x indices to put bad indices
% ============================================

badTol    =  3   ;  %  difNewMx > badTol * diffOld

alpha     =  0.8 ;  %  a parameter used to decide midDiff

nx        =  diff( curInds ) + 1   ;
nz        =  diff( zlimits ) + 1   ;

nb        =  length( badInds ) ;

xWork     =  linspace( xlimits(1) , xlimits(2) , nl ) ;

yWork     =  zeros( nb , nl  , 2 )  ;

yLo       =  zeros( 1  , nx )  ;
yHi       =  zeros( 1  , nx )  ;

oldDiff   =  zeros( nb ,  1 )  ;
midDiff   =  zeros( nb ,  1 )  ;
maxDiff   =  zeros( nb ,  1 )  ;

possInds  =  cell(  nb  , 1 )  ;

tmpInds   =  curInds(1) : curInds(2) ;
actInds   =  badInds - ( zlimits(1) - 1 )  ;  % actual Inds

% =================================================
%  loop over bad Inds to get possible x-Inds
% =================================================

for i = 1 : nb
    
    % ======================
    %  create special index
    % ======================
    
    k = actInds(i) ;
    
    % =======================
    %  setup upper and lower
    %    region boundaries
    % =======================
    
    for j = 1 : nx
        
        jOff  =  tmpInds(j) ;
        
        try
            
            yLo(j)  =  y(  z( zz(k) - 1 , jOff )  ,  jOff  ) ;
            
        catch
            
            yLo(j)  =  y(             1           ,  jOff  ) ;
            
        end
        
        yHi(j)      =  y(  z( zz(k) , jOff ) - 1  ,  jOff  ) ;
        
    end
    
    % =====================
    %  get old differences
    % =====================
    
    yLoOld  =  interp1( x(tmpInds) , yLo , xx(k) ) ;
    yHiOld  =  interp1( x(tmpInds) , yHi , xx(k) ) ;
    
    yLoOld  =  max( ylimits(1) , yLoOld )  ;
    yHiOld  =  min( ylimits(2) , yHiOld )  ;
    
    oldDiff(i)  =  max(  [ 0 , yHiOld - yLoOld ]  )  ;
    
    % ========================
    %  start algorithm to get
    %  better label locations
    % ========================
    
    yWork(i,:,1) = interp1( x(tmpInds) , yLo , xWork ) ;
    yWork(i,:,2) = interp1( x(tmpInds) , yHi , xWork ) ;
    
    for j = 1 : nl
        
        for h = 1 : 2
            
            if yWork(i,j,h) < ylimits(1) , yWork(i,j,h) = ylimits(1) ; end
            if yWork(i,j,h) > ylimits(2) , yWork(i,j,h) = ylimits(2) ; end
            
        end
        
    end
    
    % ====================================
    %  find the min and max diff in order
    %    to get a point inbetween them
    % ====================================

    yWorkDiff  =  diff( permute(yWork(i,:,:),[3 2 1]) ) ;
    
    maxDiff(i) =  -Inf ;
    
    minDiff    =  +Inf ;
    
    for j = 1  : +1 : nl
        
        if isnan( yWorkDiff(j) )  ,  continue  ,  end
        
        if yWorkDiff(j) >= oldDiff(i) && maxDiff(i) < yWorkDiff(j)
            
            maxDiff(i)   = yWorkDiff(j) ;
            
        end
        
    end
    
    if maxDiff(i) == -Inf         ,  continue  ,  end
    
    for j = nl : -1 : 1
        
        if isnan( yWorkDiff(j) )  ,  continue  ,  end
        
        if yWorkDiff(j) >= oldDiff(i) && minDiff    > yWorkDiff(j)
            
            minDiff  =  yWorkDiff(j) ;
            
        end
        
        if minDiff == 0           ,    break   ,  end
        
    end
    
    % =============================================
    %    if minDiff and maxDiff are the same for
    %  a one region zoomed-in plot , it means that
    %       no region boundaries are present
    % =============================================
    
    if  nz == 1  &&  minDiff == maxDiff(i)
        
        possInds = [] ;
        
        return
        
    end
    
    % =======================================================
    %  get largest spread of values from minDiff and maxDiff
    % =======================================================
    
    midDiff(i)  =  minDiff + alpha * ( maxDiff(i) - minDiff ) ;
    
    minDiff     =  max(  minDiff  ,  badTol  *  oldDiff(i)  ) ;
    
    if minDiff == 0
        
        diffToBeat = eps ;
        
    else
        
        diffToBeat = max( minDiff , midDiff(i) ) ;
        
    end
    
    % -----------------------
    %  find possible indices
    % -----------------------
    
    onRun      =  false  ;
    prevIndex  =    0    ;
    
    for j = 1 : nl
        
        if isnan( yWorkDiff(j) )  ,  continue  ,  end
        
        if yWorkDiff(j) <= diffToBeat
            
            if onRun
                
                possInds{i}  =  [ possInds{i} , prevIndex:j-1 ] ;
                
            end
            
            onRun      =  false ;
            prevIndex  =    0   ;
            
        elseif ~onRun
            
            onRun      =  true  ;
            prevIndex  =    j   ;
            
        end
        
    end
    
    if onRun
        
        possInds{i}  =  [ possInds{i} , prevIndex:j-1 ] ;
        
    end
    
end

% ========================
%  fix up the last region
% ========================

if  isempty(possInds{end})  &&  maxDiff(end) == 0
   
    possInds{end}  =  1  ;
    
end

% -------------------------------------
%  one regn zoom-ins for the last regn
%    get fixed inside makeLabelText
% -------------------------------------

if  zlimits(1) == zlimits(2)  &&  zlimits(1) == size(z,1)
        
    if isempty( possInds{1} )  ,  possInds(1) = []  ;  end
     
    return
    
end

% ===================================================
%  remove possInds that were found to be pretty good
% ===================================================

for i = length(possInds) : -1 : 1
    
    if isempty( possInds{i} )
        
        yWork(i,:,:)  =  []  ;
        badInds( i )  =  []  ;
        maxDiff( i )  =  []  ;
        possInds(i )  =  []  ;
        
    end    
    
end
