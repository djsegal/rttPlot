% currently, 'fig' is a property in genPlot
% zoomStatus doesn't change if customZoom is active between plot class changes
% makeRTTplot just makes the sidebar (maybe rename)

% for other vars ontop of regions plot, disable manual temp limits

% listing = dir(mbucky*****.h5)
% copyfile(), delete()

% clear variables (ones that have to get remade everytime regardless)

% mytimes(j,1) = {num2str(time(index(j)),'%12.5e')};

% function y = functionOfLargeMatrix(x)
% x(2) = 2;  % this line will make the code way slower
% y = x(1);  % this line will not dramatically change anything

classdef aRTTplot < genPlot
    
    
    properties
        
        % variables for manual selection of tempLimit
        tmin = 0.1 % eV (default is 0.1 eV)
        tmax = 200 % eV (default is 200 eV)
        
        Twait = 1e1 % 10    secs b/w calls for autoMode
        Tnum  = 1e3 % 1000  calls before autoMode is disabled
        
        tempTitle = 'none'
        tempOverlay
        logEps = log10(0.000330920069000000)
        xyLimits
        
        radiusScale = 1;    % linear is default
        timeScale = 1; % linear is default
        tempScale = 1; % linear is default
        tempLimits = 1; % auto is default
        tempIndex = 0; % nothing selected
        scalVal = .75;
        prevScalVal = 1;
        perVal = 1;
        
        origTimes
        totalTimes
        saveSelect
        %         zoomStatus = 0;
        curRanges
        
        colorList = { ...
            
        [.4 .4 .4] , [.3 0 .7] , [.8 .2 .2] , [0 .75 .3] , ...
        [.6 .6  0] , [0 .5 .5] , [.6 .3 0]  ,              ...
        ...
        [.4 .4 .4] , [.3 0 .7] , [.8 .2 .2] , [0 .75 .3] , ...
        [.6 .6  0] , [0 .5 .5] , [.6 .3 0]                 ...
        
        } ;
    
    output_time
    linRegions
    logRegions
    r1a
    temp
    jmax
    
    jmaxCopy
    r1aCopy
    
    pushButtons
    
    evLabel
    
    defaultLimits
    
    %     zoom
    % set(zoom,'Value',obj.zoomStatus) % might have to give buttons to plot
    %         nzones
    %         ngroups
    
    modeButton
    radScaleButton
    timeScaleButton
    tempScaleButton
    tempLimitsButton
    tempShadingButton
    
    otherVar
    nonTempData
    
    sliderBar
    basePlot
    noTemp
    te2a
    tr2a
    tn2a
    other
    
    legendA = []
    legendB = []
    regionLabels = []
    
    customZoomChoices = [] ;
    
    zoomStatus
    prevZoomPt
    
    allLayers
    
    autoTimer       =   [] ;
    
    end
    
    properties (Hidden)
        
        RTTsidebar
        %graph
        topLayer
        textLayer
        
        pointsLayer
        allPoints
        showHidePtsControl
        showHidePtsPanel
        xInputPts       =   [] ;
        yInputPts       =   [] ;
        selectedPoints  =   [] ;
        ptCrosshairs    =   [] ;
        
        openFileButton
        plotMultButton
        reloadDataButton
        autoRefreshButton
        snapShotButton
        restartPlotButton
        customZoomButton
        customOptsButton
        
        isBuckyPlot
        
    end
    
    events
        
        needUpdate
        
        hasZoomed
        
    end
    
    
    % ====================
    %  constructor method
    % ====================
    
    methods        
        
        function obj = aRTTplot(varargin)
            
            
            % ----------------------------
            %  set up basic plotting area
            % ----------------------------
            
            obj = obj@genPlot(varargin) ;
            
            if nargin <= 1
                
                % input file is { bucky.h5 -OR- varargin }
                
                obj.isBuckyPlot   =   false  ;
                
                
            else
                
                obj.isBuckyPlot   =   true   ;
                
                obj.fig      =  varargin{1}  ;
                obj.sidebar  =  varargin{2}  ;
                obj.graph    =  varargin{3}  ;
                
            end
            
            makeRTTplot( obj , obj.isBuckyPlot )
            
            set( obj.fig , 'Name' , 'RTT Plot' ,  'DeleteFcn' , @(src,event)closeRTTplot(obj) )
           
            makeLayers( obj )
            
            obj.allLayers = [ obj.graph , obj.topLayer , obj.textLayer ] ;
            
            colormap(jet)
            
            addlistener(obj,'needUpdate',@makePlot) ;
            
            if exist( obj.mainFile , 'file') == 2
               
                openBuckyFile( obj ) ;
                
            else
                
                openBuckyFile( obj , [] , [] ) ;
                
                if ~exist( obj.mainFile , 'file') == 2
                    return
                end
                
            end
            
            % undocumented feature in matlab ( i.e. a hack )
            % %turn blocking off to allow setting the zoom state (true by default)
            % set(zoom.ModeHandle,'Blocking',false);
            
            set( pan(obj.fig),'ActionPostCallback',@obj.makeRegionLabels)
            set(zoom(obj.fig),'ActionPostCallback',@obj.makeRegionLabels)
            
            % connect zoom and pan by right clicking
            
            hCMZ = uicontextmenu;
            uimenu('Parent',hCMZ,'Label','Switch to pan',...
                'Callback','pan(gcbf,''on'')');
            set(zoom(gcf),'UIContextMenu',hCMZ);
            
            hCMZ = uicontextmenu;
            uimenu('Parent',hCMZ,'Label','Switch to zoom',...
                'Callback','zoom(gcbf,''on'')');
            set(pan(gcf),'UIContextMenu',hCMZ);
            
%             autoZoom(obj)
            
            % Warn users that plots with more than 9 regions won't have labels
            %             if size(jmax,1) > 9
            %                 errorbox1 = msgbox(['There are more than 9 regions. ' , ...
            %                     'The additional regions will not be plotted and ' , ...
            %                     'every region will be unlabeled.'],'warning');
            %             end
%             
%             [   obj.xInputPts   , obj.yInputPts ,     ...
%                 obj.pointsLayer , obj.allPoints ]  =  ...
%                 makePoints( 'LineWidth' , 1 , 'ShowPoints' , true ) ;
            
        end
         
    end
    
    
    % =================
    %  general methods
    % =================
    
    methods
        
        createRegionsPlot(obj,curAxes)
        
        createLinesPlot(obj,varargin)
        
        tempPlot = createTempsPlot(obj,curAxes)
        
        formatAxes(obj,varargin)
        
        makeRegionLabels(obj,varargin)
        
        autoZoom(obj,varargin)
        
        closeRTTplot(obj)
        
    end
    
    
    % ================
    %  button methods
    % ================
    
    methods
        
        openBuckyFile(obj,varargin)
        
        reloadData(obj)
        
        selectNonTemp(obj,~,~)
        
        customZoom(obj)
        
        customOpts(obj)
        
        restartPlot(obj)
        
        snapShot(obj)
        
        autoPlot(obj)
        
        plotAlot(obj,src,~)  % unused,  should be moved to XYplot
        
    end
    
    
    % ==============
    %  make methods
    % ==============
    
    methods
        
        makeRTTplot(obj,isBuckyPlot)
        
        makeRegions(obj)
        
        makePlot(obj,varargin)
        
        makeLayers( obj )
        
    end
    
    
    % ================
    %  change methods
    % ================
    
    methods
        
        changeMode(obj)
        
        changeRadiusScale(obj)
        
        changeTimeScale(obj)
        
        changeTempScale(obj)
        
        changeTemp(obj,src)
        
        changeTempLimits(obj)
        
        changeTone(obj)
        
        sliderFork(obj,varargin)
        
        changeFile(obj,varargin)
        
    end
    
    
    % ====================
    %  downloaded methods
    % ====================
    
    methods

        plotMult(obj)
        
        varargout   =  legendflex(varargin)
        
    end
    
    
    % ================
    %  static methods
    % ================
    
    methods (Static)
        
        textBoxes   =  makeLabelText( z , x , y , xlimits, ylimits )
        
        zlimits     =  makeLabelText_getZlimits(  ...
            x , y , z , xlimits , ylimits , curIndices  )
        
        textBoxes   =  makeLabelText_fewPts(      ...
            x , y , z , xlimits , ylimits , zlimits , curIndices  )
        
        badIndices  =  makeLabelText_findBad(  ...
            x , y , z , xx , zz , ylimits , zlimits , curIndices )
        
        [ possInds  ,  badInds  , maxDiff , xWork   , yWork ] = makeLabelText_findLocs( ...
            x , y , z , xx , zz , xlimits , ylimits ,    zlimits    , ...
            curIndices     ,      badIndices        ,      nl       )
        
        [ xx , yy ] =  makeLabelText_fixBad( badInds , nl ,   ...
            xWork   ,  yWork   , prevXX  , prevYY  , zz  , maxDiff ,  ...
            xlimits ,  ylimits , zlimits , possInds , curInds )
        
        yy          =  makeLabelText_getInitYY( ...
            x , y , z , xx , ylimits , zz , curInds )
        
        [timeBounds , radBounds]  =  getPanLimits( curLims , defLims )
        
    end
    
    
end

