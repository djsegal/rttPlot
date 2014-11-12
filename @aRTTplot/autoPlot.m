function autoPlot( obj )

if get(obj.autoRefreshButton,'value') == 0
    stop(obj.autoTimer)
    delete(obj.autoTimer)
    obj.autoTimer = [];
    return
end

obj.autoTimer = timer ;

obj.autoTimer.BusyMode = 'drop' ;
obj.autoTimer.ExecutionMode = 'fixedSpacing' ;
obj.autoTimer.Period = 10 ;
obj.autoTimer.StartDelay = 0 ;
obj.autoTimer.TasksToExecute = Inf ;
obj.autoTimer.TimerFcn = {@(src,event)reloadData(obj)} ;
           
start( obj.autoTimer )

end

