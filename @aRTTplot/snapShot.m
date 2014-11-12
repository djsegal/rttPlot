function snapShot( obj )

disposableFigure  =  figure( 'visible' , 'on' , ...
    'units'   , 'normalized' , 'position' , [ 0 0 1 1 ] , ...
    'menubar' , 'none'       , 'DefaultAxesFontSize', 14)  ;

if obj.tempIndex > 0
    
    curAxesPosition = [ 0.1 0.1 0.75 0.8 ] ;
    
else
    
    curAxesPosition = [ 0.1 0.1 0.80 0.8 ] ;
    
end
   
plotA = axes( 'position' , curAxesPosition ) ;
plotB = axes( 'position' , curAxesPosition ) ;

linkaxes([plotA,plotB],'xy')

if strncmp(get(obj.modeButton,'String'),'REGIONS',5)
   
    if obj.tempIndex > 0
        
        createRegionsPlot(obj,plotA)
        createTempsPlot(obj,plotB);

        title(plotA,'Radius, Time, and Temperature Plot','fontweight','bold')
        xlabel(plotA,'Time')
        ylabel(plotA,'Radius')
        
    else
        
        createRegionsPlot(obj,plotB)
        
        title(plotB,'Radius, Time, and Temperature Plot','fontweight','bold')
        xlabel(plotB,'Time')
        ylabel(plotB,'Radius')
        
    end
    
else
    
    if obj.tempIndex > 0
        createTempsPlot(obj,plotB);
    end
    createLinesPlot(obj,plotB)
    if obj.tempIndex <= 0
        axis(plotB,'auto');
    end
    
    title(plotA,'Radius, Time, and Temperature Plot')
    xlabel(plotA,'Time')
    ylabel(plotA,'Radius')
    
end



set(findall(disposableFigure,'type','text'),'fontWeight','bold')
    


if obj.tempIndex > 0
    
    colorbar( 'position' , [ 0.9 0.1 0.05 0.8 ] )
    
end


extensionList     = { ...
    'png' , 'eps' , {'jpg' , 'jpeg'} , ...
    'pdf' , 'svg' , {'tif' , 'tiff'} }  ; 

extList = {} ;

for i = 1 : length(extensionList) 

    if ~iscell( extensionList{i} )
        
        extList{end+1,1} = [ '*.' , extensionList{i} ] ;
        
        extList{end  ,2} =   upper( extensionList{i} ) ;
        
    else
        
        extList{end+1,1} = [ '*.' , extensionList{i}{1}  ...
            ,          ';' '*.' , extensionList{i}{2}  ] ;
        
        extList{end  ,2} =   upper( extensionList{i}{1} ) ;
        
    end
   
    
    
end

[fname,pathstr,extInd] = uiputfile(extList,'Setup Export File','matlab_export') ;

if extInd == 0
    close( disposableFigure )
    return
end

[~,fname,~] = fileparts(fname) ;

fname = [ pathstr , '/' , fname ] ;

ext = extList{ extInd , 2 } ;

switch lower(ext)
    case 'eps'
        printCmd = '-depsc' ;
    case 'png'
        printCmd = '-dpng' ;
    case {'jpeg','jpg'}
        printCmd = '-djpeg' ;
    case 'pdf'
        printCmd = '-dpdf' ;
    case {'tif' 'tiff'}
        printCmd = '-dtiff' ;
    case 'svg'
        printCmd = '-dsvg' ;
    case ''
        printCmd = '-dpng' ;
    otherwise
        printCmd = '-dpng' ;
        warning('SAVEFIGURE:unknownExtension','unrecognized extension... assuming png')
end





print( disposableFigure , printCmd , fname )

close( disposableFigure )



end

