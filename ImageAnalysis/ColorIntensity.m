function [CellIntensityAll] = ColorIntensity(BW_Image_Filtered,FITCImage,TRITCImage,CY5Image,Index)

CellRegion=regionprops(BW_Image_Filtered>0,'Area');
CellIntensityAll=zeros(size(CellRegion,1),3*size(Index,2));
Channel=cell(0);

for Round=1:size(Index,2)
    Channel{1}=FITCImage(:,:,Index(Round));
    Channel{2}=TRITCImage(:,:,Index(Round));
    Channel{3}=CY5Image(:,:,Index(Round));

    for CellIntensity=1:3
        
%         BackGroundIndensity=Channel{C}(~BW_Image_Filtered);
%         BackGroundRandPerm=BackGroundIndensity(randperm(size(BackGroundIndensity,1),50000));
        
        CellRegion=regionprops(BW_Image_Filtered>0,Channel{CellIntensity},'Area','MeanIntensity','PixelValues','BoundingBox');
        CellRegionCell=struct2cell(CellRegion);
        CellIntensityAll(:,CellIntensity+(Round-1).*3)=cell2mat(CellRegionCell(4,:));

        CellRegion=regionprops(BW_Image_Filtered>0,Channel{CellIntensity},'Area','MeanIntensity','PixelValues','BoundingBox');
        CellRegionCell=struct2cell(CellRegion);
        CellRegionBoundingBox=CellRegionCell(2,:);
%         Intensity{Round,C}=cell2mat(CellRegionCell(4,:));
        for k=1:size(CellRegion,1)
            CellRegionBoxX=max(floor(CellRegionBoundingBox{k}(1))-50,1):min(floor(CellRegionBoundingBox{k}(1))+CellRegionBoundingBox{k}(3)+50,size(Channel{CellIntensity},2));
            CellRegionBoxY=max(floor(CellRegionBoundingBox{k}(2))-50,1):min(floor(CellRegionBoundingBox{k}(2))+CellRegionBoundingBox{k}(4)+50,size(Channel{CellIntensity},1));
            ChannelImageCut=Channel{CellIntensity}(CellRegionBoxY,CellRegionBoxX);
            BW_ImageCut=BW_Image_Filtered(CellRegionBoxY,CellRegionBoxX);
            BackGroundCut=ChannelImageCut(~BW_ImageCut);
            CellIntensityAll(k,CellIntensity+(Round-1).*3)=cell2mat(CellRegionCell(4,k))-mean(BackGroundCut);
            DisplayBar(k,size(CellRegion,1));
        end
    end
end
end