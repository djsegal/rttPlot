function [ xx , yy , newInd ] =  makeLabelText_fixBad( badInds , nl ,   ...
    xWork   ,  yWork   , prevXX  , prevYY  , zz  , maxDiff ,  ...
    xlimits ,  ylimits , zlimits , possInds , curInds )

% =======================
%  fix bad region labels
% =======================

alpha     =  .1     ;  %  priority towards x or y spacing

xx        =  prevXX  ;
yy        =  prevYY  ;

nx        =  diff(    curInds  ) + 1  ;
nb        =  length(  badInds  )      ;

actInds   =  badInds - ( zlimits(1) - 1 )  ;  % actual indices

ratio1    =  possInds ;  % just to get structure
ratio2    =  possInds ;  % just to get structure
ratio3    =  possInds ;  % just to get structure
% ratio4    =  possInds ;  % just to get structure

newInd    =  zeros( nb , 1 ) ;
bndsInds  =  cell(  nb , 1 ) ;

% ------------------------------------------------------
%  alpha is used to get a corrected y-value that biases
%     towards region boundaries and away from ylimits
% ------------------------------------------------------

gamma  =  0.5  ;

% ===================================================
%  judge the placement of new xx positions based on:
%     (1) distance from intended position
%     (2) difference between yHi and yLo there
%     (3) relative distance b/w other xx positions
% ===================================================

% =================================================
%  get ratio1 :  dist from intended / max possible
% =================================================

for i = 1 : nb
    
    k = actInds(i) ;
    
    for j = 1 : length( possInds{i} )
        
        curXX = xWork( possInds{i}(j) ) ;
        
        ratio1{i}(j)  =  ( xx(k) - curXX )  ;
        
        if curXX(1) < xx(k)
            
            ratio1{i}(j)  =  ratio1{i}(j) / ( xx(k) - xlimits(1) ) ;
            
        else
            
            ratio1{i}(j)  =  ratio1{i}(j) / ( xx(k) - xlimits(2) ) ;
            
        end
        
    end
    
end

% ==============================================
%  get ratio2 : ratio b/w cur diff and max diff
% ==============================================

for i = 1 : nb
    
    for j = 1 : length( possInds{i} )
        
        ratio2{i}(j) = diff( squeeze( yWork(i,possInds{i}(j),:) ) ) ;
        
        ratio2{i}(j) = ratio2{i}(j) / maxDiff(i) ;
        
    end
    
end

% ======================================
%   get ratio3 : closeness of spacing
%    b/w possible indices -AND- both 
%  good indices and ylimit crossing pts
% ======================================

% % ----------------------------------------
% %  build up list of established xx values
% % ----------------------------------------
% 
% goodXX  =  xx(  ~ismember( zz , zz(actInds) )  )  ;
% 
% % -----------------------------------------
% %  build up a base un-normalized raw score
% % -----------------------------------------
% 
% for i = 1 : nb
%     
%     for j = 1 : length( possInds{i} )
%         
%         curXX = xWork( possInds{i}(j) ) ;
%                 
%         ratio3{i}(j) = 0 ;
%         
%         for k = 1 : length(goodXX)
%                         
%             ratio3{i}(j) = ratio3{i}(j) + ( curXX - goodXX(k) )^2  ;
%             
%         end
%         
%     end
%     
% end

% ------------------------------------------------------
%  find the points where gaps start and end in possInds
% ------------------------------------------------------

for i = 1 : nb
    
    bndsInds{i}(end+1) = 1 ;
    
    if possInds{i}(1) > 2          %   xlimits(1) already added
       
        bndsInds{i}(end+1)  =  possInds{i}(1) - 1 ;
        
    end
    
    for j = 2 : length( possInds{i} )
   
        if possInds{i}(j-1) == possInds{i}(j)-1
            
            continue
            
        end
        
        bndsInds{i}(end+1)     = possInds{i}(j-1) + 1 ;
        
        if possInds{i}(j-1)   ~= possInds{i}(j  ) - 2
            
            bndsInds{i}(end+1) = possInds{i}(j  ) - 1 ;
            
        end
        
    end
    
    if possInds{i}(end) < nl - 2   %   xlimits(2) already added
        
        bndsInds{i}(end+1) = possInds{i}(end) + 1 ;
        
    end
    
    bndsInds{i}(end+1) = nl ;
    
end

% --------------------------------------------------------
%  update ratio3 taking into account bndsInds information
% --------------------------------------------------------

for i = 1 : nb
    
   for j = 1 : length( possInds{i} )
             
       for k = 2 : length( bndsInds{i} )

           if bndsInds{i}(k) > possInds{i}(j)
              
               break
               
           end
           
       end
       
       curXX    =  xWork( possInds{i}(j  ) ) ;
       
       tmpXX_1  =  xWork( bndsInds{i}(k-1) ) ;
       tmpXX_2  =  xWork( bndsInds{i}(k  ) ) ;
           
       ratio3{i}(j) =  ...
           (  curXX - tmpXX_1  )^4  +  ...
           (  curXX - tmpXX_2  )^4  ;
       
   end
   
   ratio3{i} = -log( ratio3{i} ./ max(ratio3{i}) ) ;
   
   ratio3{i} =       ratio3{i} ./ max(ratio3{i})   ;
    
end


% ===================================
%  combine the 3 ratios and re-order
%   possInds{i} for i = 1 , ... , nb
% ===================================

for i = 1 : nb
    
    k = actInds(i) ;
    
    aaa  = ratio3{i}.*exp(ratio2{i}-ratio1{i}) ;
    
    [ maxmax , maxind ] = max(aaa) ;
    
    newInd(i) =  possInds{i}( maxind ) ;
    
    if yWork(i,newInd(i),1) == ylimits(1) ,  gamma = gamma + 0.15 ;  end
    if yWork(i,newInd(i),2) == ylimits(2) ,  gamma = gamma - 0.15 ;  end
    
    xx(k)      =    xWork(  newInd(i)  )  ;
    
    yy(k)      =    yWork(i,newInd(i),1)  +  gamma *   ...
        (           yWork(i,newInd(i),2)  -  yWork(i,newInd(i),1)    ) ;
    
end

% =========================================
%   check the first n best inds and then
%  pick one taking separation into account
% =========================================

%  not implented yet.  TODO

end

