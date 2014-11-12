function [ timeBounds , radBounds ] = getPanLimits( curLims , defLims )

% ===========================
%  clean up lims for panning
% ===========================

timeBounds  =  curLims(1:2)  ;
radBounds   =  curLims(3:4)  ;

if  timeBounds(1) < defLims(1)
    timeBounds(1) = defLims(1) ;
end

if  timeBounds(2) > defLims(2)
    timeBounds(2) = defLims(2) ;
end

if  radBounds( 1) < defLims(3)
    radBounds( 1) = defLims(3) ;
end

if  radBounds( 2) > defLims(4)
    radBounds( 2) = defLims(4) ;
end

if timeBounds(2) < timeBounds(1)
    timeBounds = defLims(1:2) ;
end

if radBounds( 2) < radBounds( 1)
    radBounds  = defLims(3:4) ;
end

end

