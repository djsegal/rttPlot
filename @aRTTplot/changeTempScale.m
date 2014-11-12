function changeTempScale(obj)

% ==================================
%  change tempScale and update plot
% ==================================

if strncmp( get(obj.tempScaleButton,'String') , 'LIN' , 3 )

    set( obj.tempScaleButton , 'String' , 'LOG' )
    obj.tempScale = 2;

else

    set( obj.tempScaleButton , 'String' , 'LIN' )
    obj.tempScale = 1;

end

if obj.tempIndex > 0

    notify( obj , 'needUpdate' ) ;
    
end

end