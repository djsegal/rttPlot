function plotMult(obj)


% ==============================================
%  modified from saveFigure (on matlab central)
% ==============================================


% ======================
%  set columns of plots
% ======================

cols = 2;


% ==============
%  folder stuff
% ==============

origFile   = obj.mainFile ;
usedFolder = uigetdir ;

if usedFolder == 0 , return , end
    
    
% ===============================================
%  check if folder is a redBucky cluster of data
% ===============================================

if exist([usedFolder,'/','0']) == 7
    dataMode = 0;
else
    dataMode = 1;
end


% ==========================
%  create new figure window
% ==========================

f = figure;
set(f,'doublebuffer', 'on')

d = dir(usedFolder);

if dataMode == 0
    
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    
else
    
    nameFolds = {d(:).name}';
    
    for i = length(nameFolds) : -1 : 1
        
        if length( nameFolds{i} ) < 3 , continue , end
        
        if ~strncmp( nameFolds{i}(end-2:end) , '.h5' , 3 )
            nameFolds(i) = [] ;
        end
        
    end
    
end

for i = length(nameFolds) : -1 : 1
    if nameFolds{i}(1) == '.'
        nameFolds(i) = [];
    end
end


% ==================================
%  determine required rows of plots
% ==================================

rows = ceil(length(nameFolds)/cols) ;


% ===========================================
%  increase figure width for additional axes
% ===========================================

fpos = get(gcf, 'position');
scrnsz = get(0, 'screensize');
fwidth = min([fpos(3)*cols, scrnsz(3)-20]);
fheight = fwidth/cols*.75; % maintain aspect ratio
set(gcf, 'position', [10 fpos(2) fwidth fheight])


% ================
%  setup all axes
% ================

buf = .15/cols; % buffer between axes & between left edge of figure and axes
awidth = (1-buf*cols-.08/cols)/cols; % width of all axes
aidx = 1;
rowidx = 0;
while aidx <= length(nameFolds)
    for i = 0:cols-1
        if aidx+i <= length(nameFolds)
            
            start = buf + buf*i + awidth*i;
            apos{aidx+i} = [start 1-rowidx-.92 awidth .85];
            a{aidx+i} = axes('position', apos{aidx+i});
            b{aidx+i} = axes('position', apos{aidx+i});
            linkaxes([a{aidx+i},b{aidx+i}],'xy')
            
        end
    end
    rowidx = rowidx + 1; % increment row
    aidx = aidx + cols;  % increment index of axes
end


% ============
%  make plots
% ============

for i = 1 : length(nameFolds)
    
    if dataMode == 0
        curFile = [ usedFolder , '/' , nameFolds{i} , '/bucky.h5' ] ;
    else
        curFile = [ usedFolder , '/' , nameFolds{i} ] ;
    end
    
    openBuckyFile( obj , curFile )
    
    if strncmp(get(obj.modeButton,'String'),'REGIONS',5)
        
        if obj.tempIndex > 0
            createRegionsPlot(obj,a{i})
            createTempsPlot(obj,b{i});
        else
            createRegionsPlot(obj,b{i})
        end
        
    else
        
        if obj.tempIndex > 0
            createTempsPlot(obj,a{i});
        end
        createLinesPlot(obj,a{i})
        if obj.tempIndex <= 0
            axis(a{i},'auto');
        end
        
    end  
    
    if dataMode == 0
        title( b{i} , [ 'Job ' , num2str(i) ] )
        formatAxes(obj,a{i},b{i})
    else
        title( b{i} , nameFolds{i} , 'interpreter' , 'none' )
    end
    
end


% ======================================================
%  determine the position of the scrollbar & its limits
% ======================================================

swidth = max([.03/cols, 16/scrnsz(3)]);
ypos = [1-swidth .01 swidth .98];
ymax = 0;
ymin = -1*(rows-1);


% =======================================================
%  build the callback that will be executed on scrolling
% =======================================================

clbk = '';

for i = 1:length(a)
    
    line = ['set(',num2str(a{i},'%.13f'),',''position'',[', ...
        num2str(apos{i}(1)),' ',num2str(apos{i}(2)),'-get(gcbo,''value'') ', num2str(apos{i}(3)), ...
        ' ', num2str(apos{i}(4)),'])'];
    
    clbk = [clbk,line,','];
    
    line = ['set(',num2str(b{i},'%.13f'),',''position'',[', ...
        num2str(apos{i}(1)),' ',num2str(apos{i}(2)),'-get(gcbo,''value'') ', num2str(apos{i}(3)), ...
        ' ', num2str(apos{i}(4)),'])'];
    
    if i ~= length(a)
        line = [line,','];
    end
    
    clbk = [clbk,line];
    
end


% ===================
%  create the slider
% ===================

uicontrol('style','slider', ...
    'units','normalized','position',ypos, ...
    'callback',clbk,'min',ymin,'max',ymax,'value',0);


% =================
%  finish plotMult
% =================

openBuckyFile( obj , origFile )

if ( dataMode == 0 )  ,  linkaxes( [a{:},b{:}] , 'xy' )  ,  end


end