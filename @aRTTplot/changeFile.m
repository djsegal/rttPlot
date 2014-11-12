% function changeFile(obj,varargin)            %
% 
% if isempty(varargin)
%     [filename, pathname] = uigetfile({'*.h5'},'File Selector');
% else
%     filename = varargin{1};
% end
% 
% if ~filename
%     return
% else
%     obj.mainFile = filename;
% end
% 
% if isempty(varargin)
%     
%     for i = length(obj.regionLabels) : -1 : 1
%         
%         if ishandle(  obj.regionLabels(i)  )
%             
%             delete(   obj.regionLabels(i)  )
%             
%         end
%         
%         obj.regionLabels(i) = [] ;
%         
%     end
%     
%     %     try
%     %         delete(obj.textLayer)
%     %     catch
%     %         % buckyPlot deletes obj.textLayer sometimes
%     %     end
%     
%     %                 try
%     %                     delete(obj.topLayer)
%     %                 catch
%     %
%     %                 end
% end
% 
% set(obj.fig,'Name','RTT Plot');
% 
% [ varIndices , cycSkip , scalInd , nzones , ngroups ] = ...
%     qwer.query(obj.mainFile,'jmx','r1a','te2a','tr2a','tn2a');
% %             qwer.cycles
% %             qwer.data( xSelect xstatus ystatus vars zones groups cycles times )
% [ cycles , output  ] = qwer.cycles(obj.mainFile,scalInd);
% obj.output_time = output(:,1);
% 
% [ obj.jmax , obj.r1a , obj.temp ] = qwer.data({varIndices(1),varIndices(2),varIndices(3:5)},[0,3,4],4,[],nzones,ngroups,cycles,[],[],output(:,3),[]);
% obj.jmax = obj.jmax';
% obj.r1a = obj.r1a';
% obj.temp = permute(obj.temp,[4 2 1 3]);
% 
% %             obj.jmax = qwer.data(varIndices(1),0,0,[],nzones,ngroups,cycles,[],[],output(:,3),[])';
% %             obj.r1a  = qwer.data(varIndices(2),3,4,[],nzones,ngroups,cycles,[],[],output(:,3),[])';
% %             obj.temp = permute( ...
% %                 qwer.data(varIndices(3:5),4,4,[],nzones,ngroups,cycles,[],[],output(:,3),[]) , ...
% %                 [ 4 2 1 3 ] );
% 
% obj.origTimes = length(obj.output_time); % number of times found in the main hdf5 file
% 
% makeRegions(obj)
% %
% %             %% Create Figure with regions map preloaded
% %
% %             %background sidebar
% %             %sidebar = uipanel('Units', 'normalized','Position',[.825 -.5 .2 2]);
% %
% %             colormap(jet)
% %             %obj.graph = axes('Units','normalized','Position',[.075,.1,.675,.825],'visible','on');
% %             hold all;
% %
% %             obj.topLayer    = axes('Units','normalized','Position',get(obj.graph,'Position'),'visible','off');
% %             obj.textLayer   = axes('Units','normalized','Position',get(obj.graph,'Position'),'visible','off');
% %
% %             hold off;
% %
% %             % allows both layers to zoom together
% %             linkaxes([obj.graph,obj.topLayer],'xy')
% %
% %             %createRegionsPlot(obj,obj.graph)
% %
% 
% 
% % Warn users that plots with more than 9 regions won't have labels
% %             if size(jmax,1) > 9
% %                 errorbox1 = msgbox(['There are more than 9 regions. ' , ...
% %                     'The additional regions will not be plotted and ' , ...
% %                     'every region will be unlabeled.'],'warning');
% %             end
% 
% customEpsilon = min(obj.r1a(2,:))/50; % smallest recognized value ( ~0 )
% %lgep = log10(customEpsilon); % global variable                ( ~log(0) )
% 
% obj.r1a(1,:) = customEpsilon; % smallest recognized value
% 
% if isempty(varargin)
%     if strncmp(get(obj.modeButton,'String'),'REGIONS',5)
%         createRegionsPlot(obj,obj.graph)
%     end
%     notify(obj,'needUpdate');
%     formatAxes(obj,obj.graph,obj.topLayer,obj.textLayer)
% end
% 
% end