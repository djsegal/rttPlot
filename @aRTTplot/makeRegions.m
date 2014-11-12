function makeRegions(obj)                      

% =============================================
%  the commented code and the uncommented code 
%      in this function do the same thing
% =============================================


%  for j = 1:size(obj.jmax,2)
%
%      for i = 1:size(obj.jmax,1)
%
%          obj.linRegions(i,j)  =        obj.r1a(obj.jmax(i,j)-1,j)  ;
%          obj.logRegions(i,j)  =  log10(obj.r1a(obj.jmax(i,j)-1,j)) ;
%
%          for k = 1:i-1
%              obj.linRegions(i,j)  =  obj.linRegions(i,j) - obj.linRegions(k,j) ;
%              obj.logRegions(i,j)  =  obj.logRegions(i,j) - obj.logRegions(k,j) ;
%          end
%
%      end
%
%  end


obj.linRegions = obj.r1a(sub2ind(size(obj.r1a),obj.jmax-1,...
    repmat(1:size(obj.jmax,2),size(obj.jmax,1),1)));

obj.logRegions = log10(obj.r1a(sub2ind(size(obj.r1a),obj.jmax-1,...
    repmat(1:size(obj.jmax,2),size(obj.jmax,1),1))));

obj.linRegions =([obj.linRegions(1,:);diff(obj.linRegions,1,1)]);
obj.logRegions =([obj.logRegions(1,:);diff(obj.logRegions,1,1)]);


end