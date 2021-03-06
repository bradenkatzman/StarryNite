function [error ,correctflags,computedclasses,model] = ...
    compute_singlemodel_classificationerror( classtags, alldaughterdata,allbackdata,...
    allforwarddata,trulyambigious,FullyDivLooking,...
    FNDivLooking,FullyFPLooking,DirtyFPLooking,DivFPLooking)
%train a classifier model based on data and labels and return the model and its errors

distributiontypemain='kernel';
%distributiontypemain='normal';
correct=0;
correctflags=ones(size(classtags));
computedclasses=zeros(size(classtags));
model=[];

%replace zero padding of uncalculable vectors with nan for classifier use
allbackdata(DivFPLooking,:)=nan;
allbackdata(FullyFPLooking,:)=nan;
allbackdata(logical(FullyDivLooking),:)=nan;

allforwarddata(FullyFPLooking,:)=nan;
allforwarddata(DivFPLooking,:)=nan;
allforwarddata(logical(FNDivLooking),:)=nan;
allforwarddata(DirtyFPLooking,:)=nan;
allforwarddata(logical(FullyDivLooking),:)=nan;
%insert adding of top class field here;

topclass=double(trulyambigious);
topclass(logical(FullyDivLooking))=2;
topclass(logical(FNDivLooking))=3;
topclass(logical(FullyFPLooking))=4;
topclass(logical(DirtyFPLooking))=5;
topclass(logical(DivFPLooking))=5;

%{
topclass=topclass+FullyDivLooking*2;
topclass=topclass+FNDivLooking*3;
topclass=topclass+FullyFPLooking*4;
topclass=topclass+DirtyFPLooking*5;
topclass=topclass+DivFPLooking*5;
%}
data=[topclass,alldaughterdata,allbackdata,allforwarddata];

%data=[alldaughterdata,allbackdata,allforwarddata];

% if a set of measures is totally missing for a class (or only 1)
%fill this in with a few random numbers to allow fitting
%these should not effect real classification since the top class field will
%result in zero probability for this class if by chance they are computable
%during live calculation in any case this fix should occur only on
%very sparse training sets 
classes=unique(classtags);
for i=1:length(classes)
    for j=1:size(data,2)
        if(length(find(~isnan(data(classtags==classes(i),j))))<2||...
                var(data(classtags==classes(i)&~isnan(data(:,j)),j))<=0)
            data(classtags==classes(i),j)=rand(size(data(classtags==classes(i),j)));
        end
    end
end
%distinguish categorical variable of topological class type from others 
distributiontype={'mvmn'};

for i=1:size(data,2)-1
    distributiontype{i+1}=distributiontypemain;
end

%distributiontype=distributiontypemain;
testclass=NaiveBayes.fit(data,classtags,'distribution',distributiontype);
data=[topclass,alldaughterdata,allbackdata,allforwarddata];
%data=[alldaughterdata,allbackdata,allforwarddata];

testpred=predict(testclass,data,'HandleMissing','on');
model.classifiermodel=testclass;

testconfusion=confusionmat(classtags,testpred)
for i=1:size(testconfusion,1)
    correct=correct+testconfusion(i,i);
end
wrong=testpred~=classtags;


correctflags(wrong)=0;
computedclasses=testpred;

error=size(alldaughterdata,1)-correct;

end


