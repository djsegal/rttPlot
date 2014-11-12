function  textBoxes  =  makeLabelText_fewPts(  ...
    x , y , z , xlimits , ylimits , zlimits , curIndices  )

% =======================================
%  for plots with no actual data on them
%  at this point , only works for nz = 1
%    however , nz can be as great as 3
%   at the end b/c of some caught regns
% =======================================

textBoxes  =  []  ;

xRange  =  diff(  xlimits   )  ;

nx      =  diff( curIndices )  +  1  ;

nz      =  diff(  zlimits   )  +  1  ;

xx      =  xlimits(1) + 0.6 * xRange ;

zz      =  round(   linspace( zlimits(1) , zlimits(2) , nz )   )  ;

% ------------------------------------------
%  last regn might have not been registered
%  NOTE: can first region ever get skipped?
% ------------------------------------------

if zz == -1

    textBoxes  =     -1      ;
    zz         =  size(z,1)  ;
    
end

% ------------------------
%  get interpolated point
% ------------------------

yLo  =  zeros( 1 , nx )  ;
yHi  =  zeros( 1 , nx )  ;

for j = 1 : nx
    
    jOff    =  curIndices(1) + ( j - 1 ) ;
    
    yHi(j)              =  y(  z( zz , jOff )-1  ,  jOff  ) ;
    
    if zz == 1 , yLo(j) =  y(        1           ,  jOff  ) ; ...
    else         yLo(j) =  y(  z( zz-1 , jOff )  ,  jOff  ) ; end

end

yLoOld  =  interp1( x(curIndices(1):curIndices(2)) , yLo , xx )  ;
yHiOld  =  interp1( x(curIndices(1):curIndices(2)) , yHi , xx )  ;

% --------------------------------------
%  check if it is okay to add the label
%        secondary checks are for
%     the first and the last regions
% --------------------------------------

yBuffer  =  0.05 * ( yHiOld - yLoOld ) ;  %   only label inside 90%

if yLoOld > ylimits(1) + yBuffer , return , end  %   primary   check
if yLoOld > ylimits(2)           , return , end  %  secondary  check

if yHiOld < ylimits(2) - yBuffer , return , end  %   primary   check
if yHiOld < ylimits(1)           , return , end  %  secondary  check

% =============================================
%   add the requested label and possibly even
%      get an extra label or two out of it
%  these labels are plotted vertically, though
% =============================================

% % --------------------------
% %  try to find extra labels
% % --------------------------
% 
% if  yHiOld  <  ylimits(2)   
%     
%     if zlimits(2) < size(z,1)  ,  zlimits(2) = zlimits(2) + 1  ;  end
%     
% end
% 
% if  yLoOld  >  ylimits(1)
%     
%     if zlimits(1) >      1     ,  zlimits(1) = zlimits(1) - 1  ;  end
%     
% end

% ===========================================
%   quit early for far zoomed-in plots that
%  are close to region boundaries with space
% ===========================================

nz      =  diff(  zlimits  )  +  1    ;

%     tried to fix a bug where you zoom-in super far 
%  by the last region boundary and it labels empty space
%
% if  nz ==  1  &&  zz == size(z,1)
%     
%     strTickLabels      =  get( gca , 'yticklabel' ) ; 
%     
%     numTickLabels      =  str2num( strTickLabels  )  ;            %#ok<ST2NM>
% 
%     [ ~ , modeCount ]  =  mode(    numTickLabels  )  ;
%     
%     if modeCount >= 2
%         
%         tmp1  =  str2num(  strTickLabels(  1  , end-1:end )  )  ; %#ok<ST2NM>
%         tmp2  =  str2num(  strTickLabels( end , end-1:end )  )  ; %#ok<ST2NM>
%         
%         % -------------------------------------------------------
%         %  if a decimal somehow got into the second to last slot
%         % -------------------------------------------------------
%         
%         if tmp1 < 1 || tmp2 < 1 
%             
%             return
%             
%         end
%         
%         if tmp1 == tmp2
%             
%             tmpStr  =  strTickLabels(  1  , 1:end-2 )  ;
%             
%             tmp3  =  str2num([ tmpStr , num2str( tmp1 - 1 ) ])  ; %#ok<ST2NM>
%             tmp4  =  str2num([ tmpStr , num2str( tmp1 - 0 ) ])  ; %#ok<ST2NM>
%             
%             ylimits(1)  =  tmp4  -  0.5 * ( tmp4 - tmp3 )  ;
%             ylimits(2)  =  tmp4  +  0.5 * ( tmp4 - tmp3 )  ; 
%             
%         end
%         
%         if  ( tmp2 - tmp1 )  <  3
%             
%             yAve  =  mean( ylimits ) ;
%             yDif  =  diff( ylimits ) ;
%                         
%             if yHiOld < yAve + 10 * yDif && yHiOld > yAve - 10 * yDif
%                 
%                 % --------------------------------------------
%                 %  this fix still lets a lot of stuff through
%                 % --------------------------------------------
%                 
%                 return
%                 
%             end
%             
%         end
%         
%     end
%     
% end

% --------------------------
%  prepare xx , yy , and zz
% --------------------------

oldZ  =  zz  ;

if nz == 1

    yy  =  0.5  *   sum( ylimits )  ;
        
else
    
    xx  =  xx   *   ones( nz , 1 )  ;
    
    yy  =          zeros( nz , 1 )  ;
    
    zz  =  zlimits(1) : zlimits(2)  ;
    
    for i = 1 : length(zz)
        
        if      zz(i)  >  oldZ
            
            yy(i)  =  mean( [ yHiOld , ylimits(2) ] )  ;
            
        elseif  zz(i)  <  oldZ
            
            yy(i)  =  mean( [ yLoOld , ylimits(1) ] )  ;
            
        else
            
            yy(i)  =  mean( [ yLoOld ,   yHiOld   ] )  ;
            
        end
        
    end
    
end

% ============
%  add labels
% ============

for i = 1 : length( xx )
    
    textBoxes = text( xx(i) , yy(i) , num2str( zz(i) ) , 'Color', 'k',...
        'HorizontalAlignment','center','BackgroundColor',[.5 .5 .5] );
    
end

end

