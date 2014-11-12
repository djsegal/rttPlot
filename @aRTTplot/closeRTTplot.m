function closeRTTplot( obj )


% =========================
%  stop automatic updating
% =========================

if ~isempty( obj.autoTimer )
    
    stop( obj.autoTimer )
    
    delete( obj.autoTimer )
    
end


end