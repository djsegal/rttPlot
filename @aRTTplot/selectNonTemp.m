function selectNonTemp(obj,~,~)

% =======================================
%  treat a non-temp variable like a temp
%     i.e. use it to color a RT plot
% =======================================

% ----------------------------
%  get information from query
% ----------------------------

[ ~ , cycSkip , scalInd , nzones , ngroups ] = ...
    qwer.query(obj.mainFile,'scal');

[ cycles , output  ] = qwer.cycles(obj.mainFile,scalInd,cycSkip);

[ twoDim , eGroup , zBoundary , zBody ] = qwer.types(obj.mainFile);

varList = qwer.query(obj.mainFile);

% ------------------------------
%  parse information from query
% ------------------------------

varList   =  [ varList(zBody) , varList(zBoundary) ] ;

tempList  =  {  'te2a'   ,   'tn2a'   ,   'tr2a'   } ;

delIndex = find(~cellfun(@isempty,strfind(varList,'r1a')));
varList(delIndex) = [];
zBoundary(delIndex-length(zBody)) = [];

for i = 1 : length( tempList ) 
    
    delIndex    =    find(   ~cellfun(  @isempty  ,  ...
        strfind( varList , tempList{i} )  )   )   ;
    
    zBody(  delIndex)  =  [] ;
    varList(delIndex)  =  [] ;
    
end

% 
% 
% delIndex = find(~cellfun(@isempty,strfind(varList,'te2a')));
% varList(delIndex) = [];
% zBody(delIndex) = [];
% 
% delIndex = find(~cellfun(@isempty,strfind(varList,'tr2a')));
% varList(delIndex) = [];
% zBody(delIndex) = [];
% 
% delIndex = find(~cellfun(@isempty,strfind(varList,'tn2a')));
% varList(delIndex) = [];
% zBody(delIndex) = [];

% -----------------------------------
%  prompt user for non-temp variable
%     (remembers prev selection)
% -----------------------------------

prevVarName = get(obj.otherVar,'string');

if ~strncmp(prevVarName,'not selected',10)
    
    initVal = find(~cellfun(@isempty,strfind(varList,prevVarName{1})));
    
else
    
    initVal = 1;
    
end

[ listIndex , nonTempOkCancel ]  =  listdlg(  ...
    'PromptString'  , 'Select Variables :' , 'ListString'   , varList , ...
    'SelectionMode' , 'single'             , 'InitialValue' , initVal )  ;

if nonTempOkCancel == 0
    
    if strncmp(get(obj.otherVar,'string'),'not selected',10)
        
        set(obj.other,'value',0)
        
    end
    
    return
    
end

% ----------------------------------------------
%  find var's type and index in respective list
% ----------------------------------------------

origIndex  =  listIndex ;

xStati     =  [  4 , 3 , 1 , 2  ]  ;

curSubGrpLengths  =  [        ...
    length(zBody) , length(zBoundary) , length(twoDim) , length(eGroup) ] ;

for i = 1 : length( curSubGrpLengths )
   
    if listIndex <= curSubGrpLengths(i)
        
        xStatus = xStati(i) ;
        
        break
        
    end
    
    listIndex = listIndex - curSubGrpLengths(i) ;
    
end

% ---------------------------------------------
%  get var's index in the actual variable pool
% ---------------------------------------------

switch xStatus
    
    case 1  ,  varIndex  =  twoDim(     listIndex  )  ;
        
    case 2  ,  varIndex  =  eGroup(     listIndex  )  ;
        
    case 3  ,  varIndex  =  zBoundary(  listIndex  )  ;
        
    case 4  ,  varIndex  =  zBody(      listIndex  )  ;
        
    otherwise
        
        err( ' : check selectNonTemp ' )
        
end

% ------------------------------
%  get cur var's data from qwer
% ------------------------------

nonTemp = qwer.data(varIndex,xStatus,4,[],nzones,ngroups,cycles,[],[],output(:,3),[],cycSkip);

obj.temp(4,:,:,:) = nonTemp';

% ------------------------------------
%  finalize selection and update plot
% ------------------------------------

set(obj.otherVar,'string',varList(origIndex))

changeTemp(obj,obj.other)

end