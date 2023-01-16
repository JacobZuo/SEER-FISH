function [] = ProcessStep1(Path,Group,RootNum,LocationNum,Round)


for GroupID=1:size(Group,2)
    for Root=1:size(RootNum,2)
        for Location=1:LocationNum(GroupID,Root)
            Pref=[Group{GroupID},'-',num2str(RootNum(Root)),'-',num2str(Location)];
            ScaleX=[];
            for RoundID=1:9
                FileName=[Path,filesep,num2str(Round(RoundID)),'-',Group{GroupID},'-',num2str(RootNum(Root)),'-100',num2str(Location),'.nd2'];

                if isempty(ScaleX)
                    ImageInfo=ND2Info(FileName);

                    ScaleX=ImageInfo.metadata.channels(1).volume.axesCalibration(1);
                    ScaleY=ImageInfo.metadata.channels(1).volume.axesCalibration(2);
                    ScaleZ=ImageInfo.metadata.channels(1).volume.axesCalibration(3);

                    if ScaleX==ScaleY
                        ImageScale=ScaleX;
                    else
                        warning('Scale not fit in X and Y')
                    end
                else
                end
                Image=ND2ReadSingle(FileName);


                if RoundID>1 && (size(Image{1},1) ~= size(FITCImage(:,:,1),1) || size(Image{1},2) ~= size(FITCImage(:,:,1),2))
                    for i=1:size(Image,2)
                        Image{i}=Image{i}(1:size(FITCImage(:,:,1),1),1001:size(FITCImage(:,:,1),2)+1000);
                    end
                else
                end


                if size(Image,2)==2
                    FITCImage(:,:,RoundID)=uint16(zeros(size(Image{1})));
                    TRITCImage(:,:,RoundID)=uint16(zeros(size(Image{1})));
                    CY5Image(:,:,RoundID)=Image{1};
                    PhaseImage(:,:,RoundID)=Image{2};
                elseif size(Image,2)==3
                    FITCImage(:,:,RoundID)=Image{1};
                    TRITCImage(:,:,RoundID)=Image{2};
                    CY5Image(:,:,RoundID)=Image{3};
                    PhaseImage(:,:,RoundID)=uint16(zeros(size(Image{1})));
                else
                    FITCImage(:,:,RoundID)=Image{1};
                    TRITCImage(:,:,RoundID)=Image{2};
                    CY5Image(:,:,RoundID)=Image{3};
                    PhaseImage(:,:,RoundID)=Image{end};
                end


            end

            FluoImage=CY5Image+FITCImage+TRITCImage;
            %             [FluoImageShift,FITCImageShift,TRITCImageShift,CY5ImageShift,PhaseImageShift] = Alignment(FluoImage,FITCImage,TRITCImage,CY5Image,PhaseImage);
            [FluoImageShift,FITCImageShift,TRITCImageShift,CY5ImageShift,PhaseImageShift,Displace] = Alignment(FluoImage,FITCImage,TRITCImage,CY5Image,PhaseImage);



            ImageLocationCenter=ImageInfo.Experiment.parameters.points(end).stagePositionUm;
            ImageLocationCenterPixel=[ImageLocationCenter(2)./ScaleX,ImageLocationCenter(1)./ScaleX];
            ImageLocationPixel=ImageLocationCenterPixel+[size(FluoImage,1)/2,size(FluoImage,2)/2]-Displace;
            OriImageSize=[size(FluoImage,1),size(FluoImage,2)];

            clear('FluoImage','FITCImage','TRITCImage','CY5Image','PhaseImage')

            BW_Image_Filtered=[];
            Normalize_Phase=1.0-mat2gray(mean(double(FluoImageShift(:,:,1)),3));
            imshow(Normalize_Phase)

            sePattern=strel('disk',1);
            AreaRange=[10,1000];
            Thereshold='Auto';
            Effectiveness=0.65;
            N=3;

            [BW_Image_Segment] = ImageSegment(Normalize_Phase,'sePattern',sePattern,'AreaRange',AreaRange,'Thereshold',Thereshold,'Effectiveness',Effectiveness,'N',N);
            [BW_Image_Filtered,~] = PhaseCheck(BW_Image_Segment,Normalize_Phase);

            [~,Labels] = bwboundaries(BW_Image_Filtered,'noholes');
            TestImage = labeloverlay(mat2gray(mean(FluoImageShift(:,:,1:9),3)),Labels,'Transparency',0.5);

            % figure
            imshow(TestImage)

            mkdir([Path,filesep,Pref,filesep])
            save([Path,filesep,Pref,filesep,Pref,'.mat'],'-v7.3')

        end
    end
end


end