function changeTone(obj)     

if strncmp( get(obj.tempShadingButton,'String') , 'SMOOTH' , 4 )

    set( obj.tempShadingButton , 'String' ,  'FLAT'  )

    shading(   obj.topLayer    ,             'flat'  ) ;

else

    set( obj.tempShadingButton , 'String' , 'SMOOTH' )

    shading(   obj.topLayer    ,            'interp' ) ;

end

end