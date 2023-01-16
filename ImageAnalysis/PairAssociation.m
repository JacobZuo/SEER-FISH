function [MSAssociationPlot,MSpValue,CAAssociationPlot,CApValue,FAAssociationPlot,FApValue,CAvsMSRatioPlot,CAvsMSpValue,FAvsMSRatioPlot,FAvsMSpValue] = PairAssociation(CellInfoAll)

AssociationNum=zeros(30);
RandomAssociationNum=zeros(30);
Association=zeros(30);
RandomTest=100;


for DistanceID=2
    Distance=DistanceID*5;
    for Index=16:30
        DistMatrix=dist(CellInfoAll{Index}(:,3:4)');
        for i=1:size(StrainNamesSort,1)

            AssociationNum(i,i,Index,DistanceID)=sum(sum(DistMatrix(CellInfoAll{Index}(:,1)==i,CellInfoAll{Index}(:,1)==i)<=Distance & DistMatrix(CellInfoAll{Index}(:,1)==i,CellInfoAll{Index}(:,1)==i) > (Distance-5)));
            for j=i+1:size(StrainNamesSort,1)
                AssociationNum(i,j,Index,DistanceID)=sum(sum(DistMatrix(CellInfoAll{Index}(:,1)==i,CellInfoAll{Index}(:,1)==j)<=Distance & DistMatrix(CellInfoAll{Index}(:,1)==i,CellInfoAll{Index}(:,1)==j) > (Distance-5)));
                AssociationNum(j,i,Index,DistanceID)=AssociationNum(i,j,Index,DistanceID);
            end
        end

        for RandomTestIndex=1:RandomTest

            RandomIndex=CellInfoAll{Index}(randperm(size(CellInfoAll{Index},1)),1);

            for i=1:size(StrainNamesSort,1)
                RandomAssociationNum(i,i,Index,RandomTestIndex,DistanceID)=sum(sum(DistMatrix(RandomIndex==i,RandomIndex==i)<=Distance & DistMatrix(RandomIndex==i,RandomIndex==i) > (Distance-5)));
                for j=i+1:size(StrainNamesSort,1)
                    RandomAssociationNum(i,j,Index,RandomTestIndex,DistanceID)=sum(sum(DistMatrix(RandomIndex==i,RandomIndex==j)<=Distance & DistMatrix(RandomIndex==i,RandomIndex==j) > (Distance-5)));
                    RandomAssociationNum(j,i,Index,RandomTestIndex,DistanceID)=RandomAssociationNum(i,j,Index,RandomTestIndex,DistanceID);
                end
            end
            DisplayBar(RandomTestIndex,RandomTest);

        end

        Association(:,:,Index,DistanceID)=AssociationNum(:,:,Index,DistanceID)./mean(RandomAssociationNum(:,:,Index,:,DistanceID),4);

        disp(['Distance ',num2str(Distance),' um, Index ',num2str(Index)])
        
    end
end

DistanceID=2;

for i=1:size(StrainNamesSort,1)
    for j=i:size(StrainNamesSort,1)

        MSMeasure(1:10)=sum(AssociationNum(i,j,1:10,1:DistanceID),4);
        MSRandom(1:10)=sum(mean(RandomAssociationNum(i,j,1:10,:,1:DistanceID),4),5);
        [~,MSpValue(i,j)]=ttest(MSMeasure(MSMeasure>0),MSRandom(MSMeasure>0));
        MSpValue(j,i)=MSpValue(i,j);
        MSAssociationPlot(i,j)=log2(mean(MSMeasure(MSMeasure>0)./MSRandom(MSMeasure>0),'omitnan'));
        MSAssociationPlot(j,i)=MSAssociationPlot(i,j);

        if mean(MSMeasure)<1
            MSAssociationPlot(i,j)=0;
            MSAssociationPlot(j,i)=0;
        end

        if sum(MSMeasure>0)<5
            MSAssociationPlot(i,j)=0;
            MSAssociationPlot(j,i)=0;
        end

        if mean(MSRandom)<0.1
            MSAssociationPlot(i,j)=0;
            MSAssociationPlot(j,i)=0;
        end
       
        CAMeasure(1:10)=sum(AssociationNum(i,j,11:20,1:DistanceID),4);
        CARandom(1:10)=sum(mean(RandomAssociationNum(i,j,11:20,:,1:DistanceID),4),5);
        [~,CApValue(i,j)]=ttest(CAMeasure(CAMeasure>0),CARandom(CAMeasure>0));
        CApValue(j,i)=CApValue(i,j);
        CAAssociationPlot(i,j)=log2(mean(CAMeasure(CAMeasure>0)./CARandom(CAMeasure>0),'omitnan'));
        CAAssociationPlot(j,i)=CAAssociationPlot(i,j);
        
        if mean(CAMeasure)<1
            CAAssociationPlot(i,j)=0;
            CAAssociationPlot(j,i)=0;
        end
        
        if sum(CAMeasure>0)<5
            CAAssociationPlot(i,j)=0;
            CAAssociationPlot(j,i)=0;
        end

        if mean(CARandom)<0.1
            CAAssociationPlot(i,j)=0;
            CAAssociationPlot(j,i)=0;
        end

        FAMeasure(1:10)=sum(AssociationNum(i,j,21:30,1:DistanceID),4);
        FARandom(1:10)=sum(mean(RandomAssociationNum(i,j,21:30,:,1:DistanceID),4),5);
        [~,FApValue(i,j)]=ttest(FAMeasure(FAMeasure>0),FARandom(FAMeasure>0));
        FApValue(j,i)=FApValue(i,j);
        FAAssociationPlot(i,j)=log2(mean(FAMeasure(FAMeasure>0)./FARandom(FAMeasure>0),'omitnan'));
        FAAssociationPlot(j,i)=FAAssociationPlot(i,j);

        if mean(FAMeasure)<1
            FAAssociationPlot(i,j)=0;
            FAAssociationPlot(j,i)=0;
        end
        if sum(FAMeasure>0)<5
            FAAssociationPlot(i,j)=0;
            FAAssociationPlot(j,i)=0;
        end
        if mean(FARandom)<0.1
            FAAssociationPlot(i,j)=0;
            FAAssociationPlot(j,i)=0;
        end

        [~,CAvsMSpValue(i,j)]=ttest2(CAMeasure(CAMeasure>0)./CARandom(CAMeasure>0),MSMeasure(MSMeasure>0)./MSRandom(MSMeasure>0));
        CAvsMSpValue(j,i)=CAvsMSpValue(i,j);
        CAvsMSRatioPlot(i,j)=log2(mean(CAMeasure(CAMeasure>0)./CARandom(CAMeasure>0),'omitnan')./mean(MSMeasure(MSMeasure>0)./MSRandom(MSMeasure>0),'omitnan'));
        CAvsMSRatioPlot(j,i)=CAvsMSRatioPlot(i,j);

        [~,FAvsMSpValue(i,j)]=ttest2(FAMeasure(FAMeasure>0)./FARandom(FAMeasure>0),MSMeasure(MSMeasure>0)./MSRandom(MSMeasure>0));
        FAvsMSpValue(j,i)=FAvsMSpValue(i,j);
        FAvsMSRatioPlot(i,j)=log2(mean(FAMeasure(FAMeasure>0)./FARandom(FAMeasure>0),'omitnan')./mean(MSMeasure(MSMeasure>0)./MSRandom(MSMeasure>0),'omitnan'));
        FAvsMSRatioPlot(j,i)=FAvsMSRatioPlot(i,j);

    end
end

end