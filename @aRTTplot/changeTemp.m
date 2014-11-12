function changeTemp(obj,src)

prevIndex = obj.tempIndex;

switch src
    
    % ------------------------------------------
    %  fork depending on what button was pushed
    % ------------------------------------------
    
    case obj.noTemp
        
        obj.tempTitle  = 'none';
        obj.tempIndex  =   0   ;
        
    case obj.te2a
        
        obj.tempTitle  = 'elec';
        obj.tempIndex  =   1   ;
        
    case obj.tr2a
        
        obj.tempTitle  = 'rad';
        obj.tempIndex  =   2   ;
        
    case obj.tn2a
        
        obj.tempTitle  = 'ion';
        obj.tempIndex  =   3   ;
        
    case obj.other
        
        % --------------------------------------------------------
        %  if the toggle button is pressed before the push button
        % --------------------------------------------------------
        
        if strncmp(get(obj.otherVar,'string'),'not selected',12)
            
            selectNonTemp(obj,777,777)
            return
            
        end
        
        % ------------------------
        %  setup selected nonTemp
        % ------------------------
        
        set(src,'value',1)
        obj.tempTitle  = get(obj.otherVar,'string');
        
        % ---------------------------
        %  check if plot is all zero
        % ---------------------------
        
        if any(  any( obj.temp(4,:,:,:) )  )
            
            obj.tempIndex  =  +4  ;
            
        else
            
            obj.tempIndex  =  -4  ;
            
        end
        
    otherwise
        
        disp('error with changeTemp (1)')
        
end

% ---------------------------
%  de-select previous button
% ---------------------------

if abs(obj.tempIndex) ~= abs(prevIndex)
    
    set( src , 'value' , 1 )
    
    switch prevIndex
        
        case 0
            
            set(  obj.noTemp  , 'value' , 0  )
            
        case 1
            
            set(  obj.te2a    , 'value' , 0  )
            
        case 2
            
            set(  obj.tr2a    , 'value' , 0  )
            
        case 3
            
            set(  obj.tn2a    , 'value' , 0  )
            
        case 4
            
            set(  obj.other   , 'value' , 0  )
            
        otherwise
            
            % % used to restartPlot
            %disp('error with changeTemp (2)')
            
    end
    
elseif abs(obj.tempIndex) ~= 4
    
    % -------------------------------
    %  if you click a button twice ,
    %  the plot is reverted to regns
    % -------------------------------
    
    obj.tempTitle  = 'none';
    obj.tempIndex  =   0   ;
    set(obj.noTemp,'value',1)
    
end

notify(obj,'needUpdate');

end