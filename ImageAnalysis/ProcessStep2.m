function [] = ProcessStep2(Path,Group,RootNum,LocationNum,StrainColors,StrainCode)


for GroupID=1:size(Group,2)
    for Root=1:size(RootNum,2)
        for Location=1:LocationNum(GroupID,Root)

            Pref=[Group{GroupID},'-',num2str(RootNum(Root)),'-',num2str(Location)];
            load([Path,filesep,Pref,filesep,Pref,'.mat'])

            BW_Image_Filtered_X = imfill(BW_Image_Filtered,'holes');
            BW_Image_Filtered_X = bwpropfilt(BW_Image_Filtered_X,'Area',[1,200]);
            %     imshow(BW_Image_Filtered)
            BW_Image_Filtered_1=bwpropfilt(BW_Image_Filtered_X,'Area',[1,60]);
            BW_Image_Filtered_2=bwpropfilt(BW_Image_Filtered_X,'Area',[61,200]);

            TestRound=1;
            while TestRound<=8 && sum(BW_Image_Filtered_2(:))>1

                Normalize_Phase_1=1.05-mat2gray(mean(double(FITCImageShift(:,:,TestRound+1)),3));
                Normalize_Phase_2=1.05-mat2gray(mean(double(TRITCImageShift(:,:,TestRound+1)),3));
                Normalize_Phase_3=1.05-mat2gray(mean(double(CY5ImageShift(:,:,TestRound+1)),3));
                TestRound=TestRound+1;

                [BW_Image_Filtered_Test_1,~] = PhaseCheck(BW_Image_Filtered_2,Normalize_Phase_1);
                [BW_Image_Filtered_Test_2,~] = PhaseCheck(BW_Image_Filtered_2,Normalize_Phase_2);
                [BW_Image_Filtered_Test_3,~] = PhaseCheck(BW_Image_Filtered_2,Normalize_Phase_3);

                BW_Image_Filtered_Test=(BW_Image_Filtered_Test_1+BW_Image_Filtered_Test_2+BW_Image_Filtered_Test_3)>0;
                BW_Image_Filtered_Test = imfill(BW_Image_Filtered_Test,'holes');

                BW_Image_Filtered_1=(BW_Image_Filtered_1+bwpropfilt(BW_Image_Filtered_Test,'Area',[1,60]))>0;

                BW_Image_Filtered_X=(imerode((BW_Image_Filtered_X-BW_Image_Filtered_1),strel('disk',2))+BW_Image_Filtered_1)>0;

                BW_Image_Filtered_1=bwpropfilt(BW_Image_Filtered_X,'Area',[1,60]);
                BW_Image_Filtered_2=bwpropfilt(BW_Image_Filtered_X,'Area',[61,200]);

            end

            BW_Image_Filtered_X = imfill(BW_Image_Filtered_X,'holes');
            %     histogram(cell2mat(struct2cell(regionprops(BW_Image_Filtered,'Area'))))

            %     imshow(BW_Image_Filtered)
            BW_Image_Filtered_X=bwpropfilt(BW_Image_Filtered_X,'Area',[5,100]);


            [~,Labels] = bwboundaries(BW_Image_Filtered_X,'noholes');
            TestImage1 = labeloverlay(mat2gray(mean(FluoImageShift(:,:,1:9),3)).*0.85,Labels,'Transparency',0.25);
            TestImage2 = labeloverlay(mat2gray(mean(PhaseImageShift(:,:,1:9),3)).*0.85,Labels,'Transparency',0.25);

            % figure
            imwrite(TestImage1,[Path,filesep,Pref,filesep,'RootFluoLabelImage.tif'])
            imwrite(TestImage2,[Path,filesep,Pref,filesep,'RootPhaseLabelImage.tif'])


            CodexRes = [];
            CodexRes = ColorIdentify_Bright(BW_Image_Filtered_X,FITCImageShift,TRITCImageShift,CY5ImageShift,2:9);


            ColorImage=zeros([size(FITCImageShift,1),size(FITCImageShift,2),3]);
            ColorImage2=zeros([size(FITCImageShift,1),size(FITCImageShift,2),3]);
            IdentifiyImage=zeros([size(FITCImageShift,1),size(FITCImageShift,2),1]);
            Labels = bwlabeln(BW_Image_Filtered_X);
            ColorMap=[];

            for i=1:8

                ColorImage(:,:,1)=mat2gray(CY5ImageShift(:,:,i+1))+mat2gray(TRITCImageShift(:,:,i+1));
                ColorImage(:,:,2)=mat2gray(FITCImageShift(:,:,i+1))+0.5*mat2gray(TRITCImageShift(:,:,i+1));

                ColorImage2(:,:,1)=ColorImage(:,:,1).*BW_Image_Filtered_X;
                ColorImage2(:,:,2)=ColorImage(:,:,2).*BW_Image_Filtered_X;

                ColorMap(:,1)=0.98.*(CodexRes(:,i)==3)+0.85.*(CodexRes(:,i)==2)+0.25.*(CodexRes(:,i)==1)+0.5.*(CodexRes(:,i)==0);
                ColorMap(:,2)=0.40.*(CodexRes(:,i)==3)+0.65.*(CodexRes(:,i)==2)+0.95.*(CodexRes(:,i)==1)+0.5.*(CodexRes(:,i)==0);
                ColorMap(:,3)=0.40.*(CodexRes(:,i)==3)+0.20.*(CodexRes(:,i)==2)+0.25.*(CodexRes(:,i)==1)+0.5.*(CodexRes(:,i)==0);

                IdentifiyImage = label2rgb(Labels,ColorMap,[0 0 0]);

                imwrite(ColorImage,[Path,filesep,Pref,filesep,'R',num2str(i),'-ColorImage.tif'])
                imwrite(ColorImage2,[Path,filesep,Pref,filesep,'R',num2str(i),'-ColorImage2.tif'])
                imwrite(IdentifiyImage,[Path,filesep,Pref,filesep,'R',num2str(i),'-IdentifiyImage.tif'])

            end


            StrainLikehood=[];
            Decode=[];
            [StrainLikehood,Decode] = StrainIndentifySim(StrainCode,CodexRes,2);

            sum(Decode(:,1)==0 & Decode(:,2)==4)
            sum(Decode(:,1)==0 & Decode(:,2)==0)
            sum(Decode(:,1)>0)

            Labels = bwlabeln(BW_Image_Filtered_X);

            ColorMap=zeros([size(Decode,1),3]);

            for i=1:size(StrainCode,2)
                ColorMap(Decode(:,1)==i,:)=StrainColors(i,:).*ones([sum(Decode(:,1)==i),3]);
            end

            ColorMap((Decode(:,1)==0 & Decode(:,2)==0),:)=StrainColors(31,:).*ones([sum(sum(Decode(:,1)==0 & Decode(:,2)==0)),3]);
            ColorMap((Decode(:,1)==0 & Decode(:,2)==4),:)=StrainColors(32,:).*ones([sum(sum(Decode(:,1)==0 & Decode(:,2)==4)),3]);

            ColorStrainImage = label2rgb(Labels,ColorMap,[0 0 0]);

            imshow(ColorStrainImage)

            imwrite(ColorStrainImage,[Path,filesep,Pref,filesep,Pref,'.tif'])

            save([Path,filesep,Pref,filesep,Pref,'.mat'],'-v7.3')


        end
    end
end




end