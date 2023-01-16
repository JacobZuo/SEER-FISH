function [] = ProcessStep3(Path,PathSave,Group,RootNum,LocationNum)


for GroupID=1:size(Group,2)
    for Root=1:size(RootNum,2)
        RootPref=[Group{GroupID},'-',num2str(RootNum(Root))];

        ImageLocation=[];
        Root_BW_Image_Filtered=cell(0);
        StrainImage=cell(0);
        IdentifiedImage=cell(0);
        RootPhaseLabelImage=cell(0);
        ImageLocationPixelAll=[];
        ImageLocationCenterPixelAll=[];
        OriImageSizeAll=[];
        DisplaceAll=[];
        for Location=1:LocationNum(GroupID,Root)
            Pref=[Group{GroupID},'-',num2str(RootNum(Root)),'-',num2str(Location)];
            load([Path,filesep,Pref,filesep,Pref,'.mat'],'ImageInfo','ImageLocationCenterPixel','OriImageSize','Displace','StrainCode','BW_Image_Filtered_X','Decode','ColorStrainImage','StrainColors');
            ScaleX=ImageInfo.metadata.channels(1).volume.axesCalibration(1);

            Root_BW_Image_Filtered{Location}=BW_Image_Filtered_X;
            IdentifiedImage{Location} = ColorStrainImage;

            Labels = bwlabeln(BW_Image_Filtered_X);

            ColorMap=zeros([size(Decode,1),3]);

            for i=1:size(StrainCode,2)
                ColorMap(Decode(:,1)==i,:)=[i,i,i]./255.*ones([sum(Decode(:,1)==i),3]);
            end

            ColorMap((Decode(:,1)==0 & Decode(:,2)==0),:)=[31,31,31]./255.*ones([sum(sum(Decode(:,1)==0 & Decode(:,2)==0)),3]);
            ColorMap((Decode(:,1)==0 & Decode(:,2)==4),:)=[32,32,32]./255.*ones([sum(sum(Decode(:,1)==0 & Decode(:,2)==4)),3]);

            StrainImageGray = label2rgb(Labels,ColorMap,[0 0 0]);

            StrainImage{Location} = StrainImageGray(:,:,1);
            RootPhaseLabelImage{Location} = imread([Path,filesep,Pref,filesep,'RootPhaseLabelImage.tif']);
            ImageLocationCenterPixelAll(:,Location)=ImageLocationCenterPixel;
            OriImageSizeAll(:,Location)=OriImageSize;
            DisplaceAll(:,Location)=Displace;

            DecodeAll{Location}=Decode;
        end

        ImageLocationPixelAll=ImageLocationCenterPixelAll+[-OriImageSizeAll(1,:)./2;OriImageSizeAll(2,:)./2]-[-DisplaceAll(1,:);DisplaceAll(2,:)];


        ImageSpan=floor(max(ImageLocationPixelAll,[],2)-min(ImageLocationPixelAll,[],2));

        Root_BW_Image_Filtered_Full=zeros(ImageSpan(1),ImageSpan(2));
        Root_IdentifiedImage_Full=zeros(ImageSpan(1),ImageSpan(2),3);
        RootPhaseLabelImageFull=zeros(ImageSpan(1),ImageSpan(2),3);
        Root_StrainImage_Full=zeros(ImageSpan(1),ImageSpan(2),1);


        ImageLocation=-floor(ImageLocationPixelAll-ImageLocationPixelAll(:,1));
        ImageLocationX=ImageLocation(2,:)-ImageLocation(2,1);
        ImageLocationY=-(ImageLocation(1,:)-ImageLocation(1,1));
        for i=1:size(ImageLocationX,2)
            ImageLocationY(i)=ImageLocationY(i)-155.*(i-1);
            ImageLocationX(i)=ImageLocationX(i)+10.*(i-1);
        end
        ImageLocationX=ImageLocationX-min(ImageLocationX)+1;
        ImageLocationY=ImageLocationY-min(ImageLocationY)+1;

        for Location=1:LocationNum(GroupID,Root)

            Root_BW_Image_Filtered_Full(ImageLocationY(Location):ImageLocationY(Location)+size(Root_BW_Image_Filtered{Location},1)-1,ImageLocationX(Location):ImageLocationX(Location)+size(Root_BW_Image_Filtered{Location},2)-1)=Root_BW_Image_Filtered{Location};
            Root_IdentifiedImage_Full(ImageLocationY(Location):ImageLocationY(Location)+size(IdentifiedImage{Location},1)-1,ImageLocationX(Location):ImageLocationX(Location)+size(IdentifiedImage{Location},2)-1,:)=IdentifiedImage{Location};
            Root_StrainImage_Full(ImageLocationY(Location):ImageLocationY(Location)+size(StrainImage{Location},1)-1,ImageLocationX(Location):ImageLocationX(Location)+size(StrainImage{Location},2)-1,:)=StrainImage{Location};
            RootPhaseLabelImageFull(ImageLocationY(Location):ImageLocationY(Location)+size(RootPhaseLabelImage{Location},1)-1,ImageLocationX(Location):ImageLocationX(Location)+size(RootPhaseLabelImage{Location},2)-1,:)=RootPhaseLabelImage{Location};

        end
% 
%         test=imread([PathSave,filesep,RootPref,'-Phase.jpg']);
%         size(test)
%         size(RootPhaseLabelImageFull)
%         imshow(test)


%         imshow(Root_BW_Image_Filtered_Full)
%         imshow(uint8(RootPhaseLabelImageFull))


        imwrite(uint8(Root_IdentifiedImage_Full),[PathSave,filesep,RootPref,'-Iden.jpg'])
        imwrite(uint8(RootPhaseLabelImageFull),[PathSave,filesep,RootPref,'-Phase.jpg'])

        save([PathSave,filesep,RootPref,'.mat'],'Root_BW_Image_Filtered_Full','Root_StrainImage_Full','Root_IdentifiedImage_Full','StrainColors','DecodeAll','ScaleX')

    end

end

end