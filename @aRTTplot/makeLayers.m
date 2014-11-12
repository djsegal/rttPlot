function makeLayers( obj )


% ========================================
%  make the extra RTT layers if necessary
% ========================================

madeCount  =  0  ;


% ==================================
%  try to make the two extra layers
% ==================================

hold all;

if ~strncmp( 'axes' , get(obj.topLayer ,'type') , 5 )
    
    obj.topLayer    =  axes(  ...
        'Units'     ,  'normalized'   ,  'visible'   ,  'off'  ,  ...
        'Position'  ,  get(obj.graph  ,  'Position'  )         )   ;
    
    madeCount  =  madeCount  +  1  ;
    
end

if ~strncmp( 'axes' , get(obj.textLayer,'type') , 5 )
    
    obj.textLayer   =  axes(  ...
        'Units'     ,  'normalized'   ,  'visible'   ,  'off'  ,  ...
        'Position'  ,  get(obj.graph  ,  'Position'  )         )   ;
    
    madeCount  =  madeCount  +  1  ;
    
end

hold off;


% =====================
%  link axes if needed
% =====================

if madeCount > 0
    
    linkaxes( [ obj.graph , obj.topLayer , obj.textLayer ] , 'xy' )
    
end


end

