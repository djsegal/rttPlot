function autoZoom( obj , varargin )

% ===================================================
%  Modifed from    GINPUTC   : similar to ginput
%           and MOUSE_FIGURE : mouse-friendly figure
% ===================================================

% ------------------------------------------------------------------
%  Name          :  Jiro Doke
%  Date          :  October 19, 2012
%
%  GINPUTC behaves similarly to GINPUT, except you can
%  customize the cursor color, line width, and line style.
% ------------------------------------------------------------------

% ------------------------------------------------------------------
%  Name          :  Rody P.S. Oldenhuis
%  E-mail        :  oldenhuis@gmail.com
%
%  MOUSE_FIGURE() starts a plot with zooming and panning activated.
%
%  Scroll        :  zoom in/out
%  Left   click  :  pan
%  Double click  :  reset view to default view
%  Right  click  :  set new default view
% ------------------------------------------------------------------

% -------------------------------------
%  varargin   =       [ ]   -OR-
%                obj,curMode,src,event
% -------------------------------------

% ==================================
%  call to autoZoom from a function
% ==================================

if isempty( varargin )
    
    % ------------
    %  initialize
    % ------------
    
    obj.prevZoomPt  =  [] ;

    curEvent.Character = 27 ;
    curEvent.Modifier  = '' ;
    
    autoZoom(obj,5,[],curEvent)
    
    % ---------------------------------
    %  define zooming with scrollwheel
    %   and panning with mouseclicks
    % ---------------------------------
    
    set(   obj.fig     ,       ...
        'WindowButtonUpFcn'     , {@(src,event)autoZoom(obj,1,src,event)} , ...
        'WindowButtonDownFcn'   , {@(src,event)autoZoom(obj,2,src,event)} , ...
        'WindowButtonMotionFcn' , {@(src,event)autoZoom(obj,3,src,event)} , ...
        'WindowScrollWheelFcn'  , {@(src,event)autoZoom(obj,4,src,event)} , ...
        'KeyPressFcn'           , {@(src,event)autoZoom(obj,5,src,event)} , ...
        'ResizeFcn'             , {@(src,event)autoZoom(obj,6,src,event)} )  ;
    
    obj.pointsLayer = axes('Visible', 'off',...
        'Parent', obj.fig, 'Units', 'normalized', ...
        'Position', get(obj.textLayer,'Position') , ...
        'XLim', [0 1], 'YLim', [0 1], ...
        'HitTest', 'off', 'HandleVisibility', 'off');
    
    obj.allPoints = line(NaN, NaN, ...
        'Parent', obj.textLayer,'HandleVisibility', 'off', ...
        'HitTest', 'off', 'Color', [1 0 0], ...
        'Marker', 'o', 'MarkerFaceColor', [1 .7 .7], ...
        'MarkerEdgeColor', [1 0 0], 'LineStyle', '-');
    
    obj.showHidePtsControl = text(0, 1, 'HIDE', 'visible','off' , ...
        'Parent', obj.pointsLayer, 'HandleVisibility', 'callback', ...
        'FontName', 'FixedWidth', 'VerticalAlignment', 'top', ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [.5 1 .5] );
    
    obj.showHidePtsPanel = text(0, 0, 'No points', ...
        'Parent', obj.pointsLayer, 'HandleVisibility', 'off', ...
        'HitTest', 'off', 'FontName', 'FixedWidth', ...
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1 1 .5],'visible','off');
    
    autoZoom(obj,6,[],[])
    
    obj.ptCrosshairs = line(nan, nan, ...
        'Parent', obj.pointsLayer, 'color', 'k', ...
        'LineWidth', 1, 'LineStyle', '-', ...
        'HandleVisibility', 'off', 'HitTest', 'off');
    
    return
    
end

% ================================
%  get current mode and selection
% ================================

curMode    =  varargin{1} ;

curSelect  =  lower( get(obj.fig,'selectiontype') )  ;

% ===============================================
%   quit early if : there is no previous point
%                   mouse hasn't been clicked
%                   selction was a double-click
% ===============================================

if  strncmp( curSelect , 'open' , 5 )
    
    set(obj.fig,'selectiontype','normal')
    
    obj.prevZoomPt  =  [] ;
    
    return
    
end

% ====================
%  get current limits
% ====================

xlim  =  get( obj.graph , 'xlim' ) ;
ylim  =  get( obj.graph , 'ylim' ) ;

% =====================================================
%  curMode == 1 : release mouse button ( pan release )
% =====================================================

if curMode == 1
    
    obj.prevZoomPt  =  [] ;
    
end

% =================================================
%  curMode == 2 : mouse click ( non-dragging pan )
% =================================================

if curMode == 2
    
    switch  curSelect
        
        case 'normal'
            
            % -----------------------------
            %  start panning on left click
            % -----------------------------
            
            obj.prevZoomPt  =  get( obj.graph , 'CurrentPoint' ) ;
            
        case 'alt'
            
            % ---------------------------
            %  reset view on right click
            % ---------------------------
            
            axis( obj.graph , obj.defaultLimits )
            
    end
    
    % ----------------------------------------------------
    %  tooltipClickFcn() :  toggle display of the tooltip
    % ----------------------------------------------------
    
    if isequal(gco, obj.showHidePtsControl)
        if strcmp(get(obj.showHidePtsControl, 'String'), 'SHOW')
            set(obj.showHidePtsControl, 'String', 'HIDE');
            set(obj.showHidePtsPanel, 'Visible', 'on');
        else
            set(obj.showHidePtsControl, 'String', 'SHOW');
            set(obj.showHidePtsPanel, 'Visible', 'off');
        end
    end
    
    % ----------------------------------------------------
    %  tooltipClickFcn() :  toggle display of the tooltip
    % ----------------------------------------------------
    
end

% ============================================
%  curMode == 3 : move mouse ( dragging pan )
% ============================================

if curMode == 3
    
    % -------------------------------------
    %  adjust limits and save new position
    % -------------------------------------
    
    if ~isempty( obj.prevZoomPt )
        
        cursorPt1      =  get(obj.graph, 'CurrentPoint')  ;
        
        delta_points  =  cursorPt1  -  obj.prevZoomPt  ;
        
        new_xlim = xlim - delta_points(1);
        new_ylim = ylim - delta_points(3);
        
        set( obj.graph , 'Xlim' , new_xlim ) ;
        set( obj.graph , 'Ylim' , new_ylim ) ;
        
        obj.prevZoomPt = get( obj.graph , 'CurrentPoint' ) ;
        
    end
    
    % -------------------------------------------------------------------
    %  mouseMoveFcn() : update cursor location based on pointer location
    % -------------------------------------------------------------------
    
    cursorPt2  =  get(obj.pointsLayer, 'CurrentPoint')  ;
    
    if (    cursorPt2(1) < 0 || cursorPt2(1) > 1  || ...
            cursorPt2(3) < 0 || cursorPt2(3) > 1  )
        
        set( obj.ptCrosshairs , 'visible' , 'off' )
        
    else
        
        set( obj.ptCrosshairs , ...
            'visible' , 'on' , ...
            'XData', [0 1 nan cursorPt2(1) cursorPt2(1)], ...
            'YData', [cursorPt2(3) cursorPt2(3) nan 0 1]);
        
    end
    
    % -------------------------------------------------------------------
    %  mouseMoveFcn() : update cursor location based on pointer location
    % -------------------------------------------------------------------
    
    
    return
    
    
end

% ======================================
%  curMode == 4 : scroll wheel ( zoom )
% ======================================

if curMode == 4
    
    % -----------------------------------------------
    %  get the number of scolls and calc zoom factor
    %    ( varargin{2+2} in scrolls is the event )
    % -----------------------------------------------
    
    scrolls      =  varargin{1+2}.VerticalScrollCount ;
    
    zoomfactor   =  1 - scrolls/50 ;
    
    % -------------------------------------------
    %    get the current standard position and
    %  camera position , then save the [z]-value
    % -------------------------------------------
    
    cam_pos_Z    =  get( obj.graph , 'cameraposition' )  ;
    oldPos       =  get( obj.graph , 'CurrentPoint'   )  ;
    
    cam_pos_Z    =  cam_pos_Z(3)  ;
    oldPos(1,3)  =  cam_pos_Z     ;
    
    % ------------------------------------------------
    %  adjust the camera's position and viewing angle
    % ------------------------------------------------
    
    set( obj.allLayers    ,    ...
        'cameratarget'    ,  [ oldPos(1, 1:2) , 0 ] , ...
        'cameraposition'  ,    oldPos(1, 1:3)       )  ;
    
    try
        camzoom( zoomfactor ) ;  % ( equivalent to zooming in )
    catch
        disp(zoomfactor)
        error( 'zoomfactor error' )
    end
    
    % -----------------------------------------------
    %  correct camera-zoom not adjusting axes limits
    % -----------------------------------------------
    
    xtmp1  =  ( min(xlim) - oldPos(1,1) ) / zoomfactor ;
    xtmp2  =  ( max(xlim) - oldPos(1,1) ) / zoomfactor ;
    
    ytmp1  =  ( min(ylim) - oldPos(1,2) ) / zoomfactor ;
    ytmp2  =  ( max(ylim) - oldPos(1,2) ) / zoomfactor ;
    
    xlim   =  [ oldPos(1,1) + xtmp1 , oldPos(1,1) + xtmp2 ] ;
    ylim   =  [ oldPos(1,2) + ytmp1 , oldPos(1,2) + ytmp2 ] ;
    
    set( obj.graph , 'xlim' , xlim )
    set( obj.graph , 'ylim' , ylim )
    
    % -------------------------
    %  set new camera position
    % -------------------------
    
    newPos           =  get( obj.graph , 'CurrentPoint' ) ;
    oldCamTarget     =  get( obj.graph , 'CameraTarget' ) ;
    oldCamTarget(3)  =  cam_pos_Z ;
    
    newCamPos        =  oldCamTarget(1,1:3)  -  newPos(1,1:3)   ;
    newCamPos        =  oldCamTarget         +  newCamPos       ;
    
    % -----------------------------------------
    %     adjust camera target and position ,
    %  then reset axes to stretch-to-fill mode
    % -----------------------------------------
    
    set(  obj.allLayers   ,    ...
        'cameraposition'  ,    newCamPos(1, 1:3)    , ...
        'cameratarget'    ,  [ newCamPos(1, 1:2), 0 ] ) ;
    
    set(    obj.allLayers      ,             ...
        'cameraviewanglemode'  ,  'auto'  ,  ...
        'camerapositionmode'   ,  'auto'  ,  ...
        'cameratargetmode'     ,  'auto'  )   ;
    
end


% ==============================
%  updates points on the figure
% ==============================

if curMode == 5
    
    key = double(varargin{3}.Character);
    
    if isempty(key)   ,   return  ,   end

    if ~isempty( varargin{3}.Modifier ) || ...
        key == 27  ||  key == 8  ||  key == 127
       
        % delete (esc or return)

        if isempty(obj.xInputPts) , return , end
        
        while ~isempty(obj.xInputPts)
            
            obj.xInputPts(end) = [];
            obj.yInputPts(end) = [];
            
            obj.selectedPoints(end, :) = [];
            set(obj.allPoints, ...
                'XData', obj.selectedPoints(:, 1), ...
                'YData', obj.selectedPoints(:, 2));
            
            if key ~= 27   ,   break   ,   end    % remove all for esc
            
        end
        
    else
        
        %updatePoints(key);
        % This function captures the information for the selected point
        
        pt = get(obj.textLayer, 'CurrentPoint');
        
        if   obj.timeScale == 2  ,  pt(1) = 10^( pt(1) )  ;  end
        if obj.radiusScale == 2  ,  pt(3) = 10^( pt(3) )  ;  end
        
        obj.xInputPts = [obj.xInputPts; pt(1)];
        obj.yInputPts = [obj.yInputPts; pt(3)];
        
    end
    
    % ---------------------------------------------
    % begin displayCoordinates()
    % This function updates the coordinates display in the tooltip
    
    if isempty(obj.xInputPts)
        set(obj.showHidePtsControl,'visible','off')
        set(obj.showHidePtsPanel,'visible','off')
        return
    end
    
    set(obj.showHidePtsControl,'visible','on')
    if strcmp(get(obj.showHidePtsControl, 'String'), 'HIDE')
        set(obj.showHidePtsPanel,'visible','on')
    else
        set(obj.showHidePtsPanel,'visible','off')
    end
    
    str = sprintf('%d: %0.3f, %0.3f\n', [1:length(obj.xInputPts); obj.xInputPts'; obj.yInputPts']);
    str(end) = '';
    set(obj.showHidePtsPanel, 'String', str);
    
    % end displayCoordinates();
    % ---------------------------------------------
    
    if  isempty( varargin{3}.Modifier ) && ...
            key ~= 27  &&  key ~= 8  &&  key ~= 127
        
        cursorPt = get(obj.textLayer, 'CurrentPoint');
        obj.selectedPoints = [obj.selectedPoints; cursorPt([1 3])];
        set(obj.allPoints, ...
            'XData', obj.selectedPoints(:, 1), ...
            'YData', obj.selectedPoints(:, 2));
        
    end
    
    return
    
end


% =========================================
%  adjust points when figure changes shape
% =========================================

if curMode == 6
    
    % ---------------------------------------
    %    this function adjusts the position
    %  of tooltip when the figure is resized
    % ---------------------------------------
    
    sz = get(obj.showHidePtsControl, 'Extent');
    set(obj.showHidePtsPanel, 'Position', [0 sz(2)]);
    
    zoom(1)
    
    return
    
end

% ============================================
%  finish up any zoom that doesn't quit early
%       with a call to makeRegionLabels
% ============================================

makeRegionLabels( obj )

end
