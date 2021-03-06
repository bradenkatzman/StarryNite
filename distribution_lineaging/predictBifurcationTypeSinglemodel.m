
function predicted_class = predictBifurcationTypeSinglemodel(...
    alldaughterdata,allforwarddata,allbackdata,d1length,d2length,...
    FNbackcand1lengths,FNbackcand2lengths,bestFNForwardLengthD1,...
    bestFNForwardLengthD2,bestFNBackCorrect,trackingparameters,bestIndex, count)
%given all data about bifurcation broken into 3 blocks
%classify bifurcation with topology of bifurcation determining which blocks
%are present/relevant

global computedclassificationvector;
global refclassificationvector;
global removed;
global simpleFNcorrect;

minsize=min(d1length,d2length);

smallcutoff=trackingparameters.smallcutoff;
%calculate which class this example falls in
FullyDivLooking=(d1length>=smallcutoff&d2length>=smallcutoff)&(~(FNbackcand1lengths>0)&~(FNbackcand2lengths>0));
FNDivLooking=(d1length>=smallcutoff&d2length>=smallcutoff)&(FNbackcand1lengths>0|FNbackcand2lengths>0);
small=minsize'<smallcutoff;
anysmalllacksforwardFN=(d1length)<smallcutoff&~(bestFNForwardLengthD1>0)|(d2length<smallcutoff&~(bestFNForwardLengthD2>0));
hasbackwardFN=(FNbackcand1lengths>0)|(FNbackcand2lengths>0);
FullyFPLooking=small&anysmalllacksforwardFN&~hasbackwardFN;
DirtyFPLooking=small&anysmalllacksforwardFN&hasbackwardFN;
DivFPLooking=  small&~anysmalllacksforwardFN&~hasbackwardFN;
trulyambigious=small&~anysmalllacksforwardFN&hasbackwardFN;

allbackdata(DivFPLooking,:)=nan;
allbackdata(FullyFPLooking,:)=nan;
allbackdata(logical(FullyDivLooking),:)=nan;

allforwarddata(FullyFPLooking,:)=nan;
allforwarddata(DivFPLooking,:)=nan;
allforwarddata(logical(FNDivLooking),:)=nan;
allforwarddata(DirtyFPLooking,:)=nan;
allforwarddata(logical(FullyDivLooking),:)=nan;
%insert adding of top class field here;
 %{
topclass=trulyambigious;
topclass=topclass+FullyDivLooking*2;
topclass=topclass+FNDivLooking*3;
topclass=topclass+FullyFPLooking*4;
topclass=topclass+DirtyFPLooking*5;
topclass=topclass+DivFPLooking*5;
%}
topclass=double(trulyambigious);
topclass(logical(FullyDivLooking))=2;
topclass(logical(FNDivLooking))=3;
topclass(logical(FullyFPLooking))=4;
topclass(logical(DirtyFPLooking))=5;
topclass(logical(DivFPLooking))=5;

%data=[topclass,alldaughterdata,allbackdata,allforwarddata];

 data=[topclass,alldaughterdata(trackingparameters.bifurcationclassifier.daughterkeep),...
        allbackdata(trackingparameters.bifurcationclassifier.backkeep),...
        allforwarddata(trackingparameters.bifurcationclassifier.forwardkeep)];
%{
     data=[alldaughterdata(trackingparameters.bifurcationclassifier.daughterkeep),...
        allbackdata(trackingparameters.bifurcationclassifier.backkeep),...
        allforwarddata(trackingparameters.bifurcationclassifier.forwardkeep)];
%}
    
 predicted_class=predict(trackingparameters.bifurcationclassifier.classifiermodel,data,'HandleMissing','on');


%store computed class
computedclassificationvector=[computedclassificationvector,predicted_class];

%classifier sometimes fails in unexplored parts of space
if(isnan(predicted_class))
    'Nan returned as class label, unexpected or nan input input vector'
    predicted_class=0;
end


%'short circut reall classiification with oracle'
%compute cheating answer online
if( trackingparameters.trainingmode)
    
    cleanlybad=(removed(count-1,11)+removed(count-1,12)>=minsize');
    cleanlybad=cleanlybad&minsize<=smallcutoff;
   % slightlybad=(removed(count-1,11)+removed(count-1,12)>=minsize*.5');
   % slightlybad=slightlybad&minsize<=smallcutoff;
    realdiv=logical(removed(count-1,8));
    %    FNback=(simpleFNcorrect(count-1)==1)&~realdiv&~cleanlybad;
    FNback=(removed(count-1,23)|bestFNBackCorrect|(simpleFNcorrect(count-1)==1))&~realdiv&~cleanlybad;
    %fn back corect should be superset so was redundant above and can be taken out  
  %  FNback=(removed(count-1,23)|(simpleFNcorrect(count-1)==1))&~realdiv&~cleanlybad;
  
    % FNback=removed(count-1,23);%bestFNBackCorrect;%
    
   % other=(~cleanlybad&~FNback&~realdiv);
    
    
    predicted_class=0; %other=
    if(realdiv)
        predicted_class=1;   %div
    end
    %fn back
    if(~realdiv&FNback)
        predicted_class=2; %FN=
    end
    
    %fn back and correct
    %classtags(~realdiv&FNback&bestFNBackCorrect)=2; %FN=
    %fn back and backcorrect or other and fnbackcorrect
    %classtags(~realdiv&((FNback&bestFNBackCorrect)|(~realdiv&~FNback&~cleanlybad&bestFNBackCorrect)))=2; %FN=
    if (cleanlybad)
        predicted_class=3;
    end
    
end    %training mode end

%if predicted 2 and no fn option is other (only happens in training mode)
if(predicted_class==2&bestIndex==-1)
    predicted_class=0;
end

refclassificationvector=[refclassificationvector,predicted_class];


end

