function [CodexRes] = ColorIdentify_Bright(BW_Image_Filtered, FITCImage, TRITCImage, CY5Image, Index)

    CellRegion = regionprops(BW_Image_Filtered > 0, 'Area');
    % Intensity=cell(0);
    FluorescentHyp = zeros(3, size(CellRegion, 1));
    FluorescentProb = zeros(3, size(CellRegion, 1));
    CodexRes = zeros(size(CellRegion, 1), size(Index, 2));
    IntensityColorAll = zeros(3, size(CellRegion, 1));

    Channel = cell(0);

    for Round = 1:size(Index, 2)

        Channel{1} = FITCImage(:, :, Index(Round));
        Channel{2} = TRITCImage(:, :, Index(Round));
        Channel{3} = CY5Image(:, :, Index(Round));

        for C = 1:3

            %         BackGroundIndensity=Channel{C}(~BW_Image_Filtered);
            %         BackGroundRandPerm=BackGroundIndensity(randperm(size(BackGroundIndensity,1),50000));
            BW_Image_Filtered2=imdilate(BW_Image_Filtered,strel('disk',4));
            CellRegion = regionprops(BW_Image_Filtered > 0, Channel{C}, 'Area', 'MeanIntensity', 'PixelValues', 'BoundingBox');
            CellRegionCell = struct2cell(CellRegion);
            CellRegionBoundingBox = CellRegionCell(2, :);
            %         Intensity{Round,C}=cell2mat(CellRegionCell(4,:));
            IntensityColorAll(C, :) = cell2mat(CellRegionCell(4, :));
            for k = 1:size(CellRegion, 1)
                CellRegionBoxX = max(floor(CellRegionBoundingBox{k}(1)) - 50, 1):min(floor(CellRegionBoundingBox{k}(1)) + CellRegionBoundingBox{k}(3) + 50, size(Channel{C}, 2));
                CellRegionBoxY = max(floor(CellRegionBoundingBox{k}(2)) - 50, 1):min(floor(CellRegionBoundingBox{k}(2)) + CellRegionBoundingBox{k}(4) + 50, size(Channel{C}, 1));
                ChannelImageCut = Channel{C}(CellRegionBoxY, CellRegionBoxX);
                BW_ImageCut = BW_Image_Filtered2(CellRegionBoxY, CellRegionBoxX);
                BackGroundCut = ChannelImageCut(~BW_ImageCut);
                BackGroundIntensityColorAll(C, k) = mean(BackGroundCut);
                [FluorescentHyp(C, k), FluorescentProb(C, k)] = ttest2(double(CellRegionCell{3, k}), double(BackGroundCut), 'Tail', 'Right', 'Alpha', 0.001, 'Vartype', 'unequal');
                DisplayBar(k, size(CellRegion, 1));
            end

        end
        IntensityColorNor=(IntensityColorAll./mean(maxk(IntensityColorAll(:, :),1,2),2));
        for k = 1:size(CellRegion, 1)
            if size(find(IntensityColorNor(:, k) == max(IntensityColorNor(:, k))),1)==1
                HighIndensity(k)=find(IntensityColorNor(:, k) == max(IntensityColorNor(:, k)));
            else
                HighIndensity(k)=find((IntensityColorAll(:, k)-BackGroundIntensityColorAll(:, k)) == max(IntensityColorAll(:, k)-BackGroundIntensityColorAll(:, k)));
            end
        end
        NonCellIndex = min(FluorescentProb(:, :), [], 1) > 0.1;

        CodexResRound = zeros(size(CellRegion, 1), 1);
        CodexResRound = HighIndensity';
        CodexResRound(NonCellIndex) = 0;
        CodexRes(:, Round) = CodexResRound;


% % %         OrigionalImage(:,:,1)=mat2gray(Channel{3},[0,4096])+mat2gray(Channel{2},[0,4096]);
% % %         OrigionalImage(:,:,2)=mat2gray(Channel{1},[0,4096])+0.5.*mat2gray(Channel{2},[0,4096]);
% % %         OrigionalImage(:,:,3)=0;
% % % 
% % %         OrignalImagePrint=uint8(OrigionalImage.*255);
% % %         RemoveBGPrint=uint8(OrigionalImage.*BW_Image_Filtered.*255);
% % % 
% % %         EnhancedImage(:,:,1)=mat2gray(mat2gray(Channel{3},[0,10^Rescale(3)+1000])+mat2gray(Channel{2},[0,10^Rescale(2)+1000]));
% % %         EnhancedImage(:,:,2)=mat2gray(mat2gray(Channel{1},[0,10^Rescale(1)+1000])+mat2gray(Channel{2},[0,10^Rescale(2)+1000]));
% % %         EnhancedImage(:,:,3)=0;
% % % 
% % %         EnhancedImagePrint=uint8((EnhancedImage.*BW_Image_Filtered).*255);
% % % 
% % %         [~,Labels] = bwboundaries(BW_Image_Filtered,'noholes');
% % % 
% % %         ColorImage=zeros(size(Labels));
% % % 
% % %         for i=1:max(Labels(:))
% % %             ColorImage(Labels==i)=CodexResRound(i);
% % %             DisplayBar(i,max(Labels(:)));
% % %         end
% % %         StrainColors=[0.4,0.8,0.3;0.8,0.6,0.3;0.8,0.3,0.3];
% % %         TestImageAll = labeloverlay(OrigionalImage.*BW_Image_Filtered,ColorImage,'ColorMap',StrainColors,'Transparency',0.25);
% % % 
% % %         AssignImagePrint=uint8(double(TestImageAll));
% % % 
% % % 
% % % 
% % %         imwrite(OrignalImagePrint,['C:\Users\dell\Desktop\OriImagePrint-Round-',num2str(Round),'.jpg'])
% % %         imwrite(EnhancedImagePrint,['C:\Users\dell\Desktop\EnhancedImagePrint-Round-',num2str(Round),'.jpg'])
% % %         imwrite(AssignImagePrint,['C:\Users\dell\Desktop\AssignImagePrint-Bac-Round-',num2str(Round),'.jpg'])


% % %         OrigionalImage(:,:,1)=0;
% % %         OrigionalImage(:,:,2)=mat2gray(Channel{1},[0,4096]);
% % %         OrigionalImage(:,:,3)=0;
% % % 
% % %         OrignalImagePrint=uint8(OrigionalImage.*255);
% % %         imwrite(OrignalImagePrint,['C:\Users\dell\Desktop\OriImagePrint-Round-',num2str(Round),'1.jpg'])
% % %         
% % %         OrigionalImage(:,:,1)=mat2gray(Channel{2},[0,4096]);
% % %         OrigionalImage(:,:,2)=0.5.*mat2gray(Channel{2},[0,4096]);
% % %         OrigionalImage(:,:,3)=0;
% % % 
% % %         OrignalImagePrint=uint8(OrigionalImage.*255);
% % %         imwrite(OrignalImagePrint,['C:\Users\dell\Desktop\OriImagePrint-Round-',num2str(Round),'2.jpg'])
% % %         
% % %         OrigionalImage(:,:,1)=mat2gray(Channel{3},[0,4096]);
% % %         OrigionalImage(:,:,2)=0;
% % %         OrigionalImage(:,:,3)=0;
% % % 
% % %         OrignalImagePrint=uint8(OrigionalImage.*255);
% % %         imwrite(OrignalImagePrint,['C:\Users\dell\Desktop\OriImagePrint-Round-',num2str(Round),'3.jpg'])

    end

end
