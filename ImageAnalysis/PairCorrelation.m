
function [GR] = PairCorrelation(StrainImage1,StrainImage2,ScaleX,Range,varargin)

Mask=ones(size(StrainImage1));
if StrainImage1==StrainImage2
    Method='Pair';
else
    Method='Cross';
end

% Reload the parameters input by user
if isempty(varargin)
else
    for i = 1:(size(varargin, 2) / 2)
        AssignVar(varargin{i * 2 - 1}, varargin{i * 2})
    end
end

if strcmp(Method,'Pair')
    Coeff=1;
elseif strcmp(Method,'Cross')
    Coeff=2;
else
    Coeff=2;
end


R=Range./ScaleX;
n=50000;
Density1=sum(StrainImage1(:))./sum(Mask(:));
Density2=sum(StrainImage2(:))./sum(Mask(:));


for k=1:size(R,2)
    r=R(k);
    Theta=rand(1,n).*2.*pi;
    x0=floor(rand(1,n).*size(StrainImage1,2));
    y0=floor(rand(1,n).*size(StrainImage1,1));
    x1=floor(x0+cos(Theta).*r);
    y1=floor(y0+sin(Theta).*r);
    
    Index=x0>0&x1>0&y0>0&y1>0&x0<=size(StrainImage1,2)&x1<=size(StrainImage1,2)&y0<size(StrainImage1,1)&y1<=size(StrainImage1,1);
    
    X0=x0(Index);
    Y0=y0(Index);
    X1=x1(Index);
    Y1=y1(Index);
    
    T=(Mask(Y0+(X0-1).*size(StrainImage1,1))==1&Mask(Y1+(X1-1).*size(StrainImage1,1))==1);
    
    H1=(StrainImage1(Y0+(X0-1).*size(StrainImage1,1))==1&StrainImage2(Y1+(X1-1).*size(StrainImage1,1))==1);
    H2=(StrainImage2(Y0+(X0-1).*size(StrainImage1,1))==1&StrainImage1(Y1+(X1-1).*size(StrainImage1,1))==1);
    
    H=(H1|H2)&T;
    
    GR(k)=sum(H)/sum(T)/Density1/Density2/Coeff;
end


end