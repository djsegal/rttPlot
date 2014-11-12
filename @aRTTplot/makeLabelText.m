function textBoxes = makeLabelText( z , x , y , xlimits , ylimits )

% ========================================
%  find which regions are in current plot
% ========================================

nl        =  100  ;  %  number in linspace for xwork & ywork

textBoxes  =  []  ;

% ===================================
%  start by finding the indices in x
%    corresponding to the xlimits
% ===================================

curIndices  =  [ -1 , -1 ]  ;

% ------------------------------------------
%  find lower time limit from left to right
% ------------------------------------------

for i = 1 : +1 : length(x)
    
    if x(i) >= xlimits(1)
        
        curIndices(1) = max(     1     , i-1 ) ;
        
        break
        
    end
    
end

% ------------------------------------------
%  find upper time limit from right to left
% ------------------------------------------

for i = length(x) : -1 : 1
    
    if x(i) <= xlimits(2)
        
        curIndices(2) = min( length(x) , i+1 ) ;
        break
        
    end
    
end

% ======================================
%  using time information , check which
%    regions are in the current plot
% ======================================

zlimits  =  aRTTplot.makeLabelText_getZlimits(  ...
    x , y , z , xlimits , ylimits , curIndices  ) ;

nz       =  diff(  zlimits  )  + 1   ;
zz       =  zlimits(1) : zlimits(2)  ;

% =====================================================
%  quit early for zoomed-in plots with few data points
% =====================================================

% ---------------------------------
%  plots with no actual data on it
% ---------------------------------

if diff(curIndices) <= 3
    
    % --------------------------------------------------
    %  no algorithm for more than one registered region
    %         ones that snuck through are allowed
    % --------------------------------------------------
    
    if nz ~=  1  ,  return  ,  end
    
    textBoxes   =   aRTTplot.makeLabelText_fewPts(      ...
        x , y , z , xlimits , ylimits , zlimits , curIndices  )  ;
    
    return
    
end

if  length(zz) == 1  &&  zz(1) == -1
    
    return
    
end

% =======================================
%  now that we have all this informaiton
%  find the optimal points to put labels
% =======================================

if nz == 1
    
    xx   =  xlimits(1) + 0.6 * diff(xlimits) ;
    
else
    
    dXX  =  diff(xlimits) * max( 0.1 , 1/(nz+1) )  ;
    
    xx   =  linspace( xlimits(1) + dXX , xlimits(2) - dXX , nz ) ;
    
end

% ===========================
%  get initial guesses of yy
% ===========================

yy   =  aRTTplot.makeLabelText_getInitYY( ...
    x , y , z , xx , ylimits , zz , curIndices ) ;

% -----------------------
%  plots with one region
% -----------------------

if nz == 1 && zlimits(1) ~= size( z , 1 )
    
    if zz(1) == -1
        
        textBoxes = -1 ;
        
        return
        
    end
    
    textBoxes  =  text( xlimits(1)+0.6*diff(xlimits) ,   mean(ylimits) ,  ...
        num2str( zz ) ,  'HorizontalAlignment'       ,  'center'       ,  ...
        'Color' , 'k' ,  'BackgroundColor'           ,  [.5 .5 .5]     )   ;
    
    return
    
end

% ==================
%  find bad indices
% ==================

badIndices  =  aRTTplot.makeLabelText_findBad(   ...
    x , y , z , xx , zz , ylimits , zlimits , curIndices ) ;

% =======================================
%  quit early if plot has no bad indices
% =======================================

if isempty( badIndices )
    
    textBoxes = zeros(nz,1) ;
    
    for i = 1 : nz
        
        textBoxes(i)  =   text(    xx(i)   ,   yy(i)  ,    ...
            num2str( zz(i) )  , 'HorizontalAlignment' ,  'center'  , ...
            'Color'  ,   'k'  , 'BackgroundColor'     , [.5 .5 .5] )  ;
        
    end
    
    return
    
end

% ============================================
%  find possible x indices to put bad indices
% ============================================

[ possInds , badIndices , maxDiff , xWork   , yWork ] = aRTTplot.makeLabelText_findLocs( ...
    x , y , z , xx , zz , xlimits , ylimits ,    zlimits    , ...
    curIndices     ,      badIndices        ,      nl       )  ;

% ============================================
%  fix one-region zoom-ins of the last region
% ============================================

if  zlimits(1) == zlimits(2)  &&  zlimits(1) == size(z,1)
    
    if yWork(1,round(0.6*nl),2) > ylimits(1) + 0.75 * diff(ylimits)
        
        yy(1)   = mean(ylimits) ;
        
    end
    
end

% ==================================
%  fix bad xx locations , if needed
% ==================================

if ~isempty(possInds)
    
    [ xx , yy ] = aRTTplot.makeLabelText_fixBad( ...
        badIndices , nl , xWork , yWork , xx , yy , zz , maxDiff , ...
        xlimits , ylimits , zlimits , possInds , curIndices ) ;
    
end

% =======================
%  add the region labels
% =======================

textBoxes = zeros(nz,1) ;

for i = 1 : nz
    
    textBoxes(i)  =  ...
        text( xx(i) , yy(i) , num2str( zz(i) ) , 'Color', 'k',...
        'HorizontalAlignment','center','BackgroundColor',[.5 .5 .5] );
    
end

end