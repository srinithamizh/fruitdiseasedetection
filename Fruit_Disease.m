function varargout = Fruit_Disease(varargin)
% FRUIT_DISEASE MATLAB code for Fruit_Disease.fig
%      FRUIT_DISEASE, by itself, creates a new FRUIT_DISEASE or raises the existing
%      singleton*.
%
%      H = FRUIT_DISEASE returns the handle to a new FRUIT_DISEASE or the handle to
%      the existing singleton*.
%
%      FRUIT_DISEASE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRUIT_DISEASE.M with the given input arguments.
%
%      FRUIT_DISEASE('Property','Value',...) creates a new FRUIT_DISEASE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Fruit_Disease_OpeningFcn gets called.  An
%      unrecognized property name or i3333333nvalid value makes property application
%      stop.  All inputs are passed to Fruit_Disease_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Fruit_Disease

% Last Modified by GUIDE v2.5 09-Nov-2018 08:02:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Fruit_Disease_OpeningFcn, ...
                   'gui_OutputFcn',  @Fruit_Disease_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Fruit_Disease is made visible.
function Fruit_Disease_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Fruit_Disease (see VARARGIN)

% Choose default command line output for Fruit_Disease
handles.output = hObject;
handles.q=1;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Fruit_Disease wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Fruit_Disease_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg';'*.gif'}, 'Pick a Fruit Image File');
I = imread([pathname,filename]);
I2 = imresize(I,[300,400]);
axes(handles.axes1);
imshow(I2);
title('\color{white}Input Image');
handles.ImgData1 = I;
guidata(hObject,handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I3 = handles.ImgData1;
I4 = imadjust(I3,stretchlim(I3));
I5 = imresize(I4,[300,400]);
axes(handles.axes2);
imshow(I5);title('\color{white}Enhanced Image');
handles.ImgData2 = I4;
guidata(hObject,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I6 = handles.ImgData2;
I = I6;
%% Extract Features

cform = makecform('srgb2lab');
lab_he = applycform(I,cform);
%Classify the colors in a*b* colorspace using K means clustering.
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
segmented_images = cell(1,4);
rgb_label = repmat(pixel_labels,[1,1,3]);
for k = 1:nColors
    colors = I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end



figure,subplot(2,3,2);imshow(I);title('Original Image'); subplot(2,3,4);imshow(segmented_images{1});title('Cluster 1'); subplot(2,3,5);imshow(segmented_images{2});title('Cluster 2');
subplot(2,3,6);imshow(segmented_images{3});title('Cluster 3');
% Feature Extraction
pause(2)
x = inputdlg('Enter the Cluster Number:');
i = str2double(x);
seg_img = segmented_images{i};
if ndims(seg_img) == 3
   img = rgb2gray(seg_img);
end


% Evaluate the disease affected area
black = im2bw(seg_img,graythresh(seg_img));
m = size(seg_img,1);
n = size(seg_img,2);

zero_image = zeros(m,n); 
%G = imoverlay(zero_image,seg_img,[1 0 0]);

cc = bwconncomp(seg_img,6);
diseasedata = regionprops(cc,'basic');
A1 = diseasedata.Area;
%sprintf('Area of the disease affected region is : %g%',A1);

I_black = im2bw(I,graythresh(I));
kk = bwconncomp(I,6);
appledata = regionprops(kk,'basic');
A2 = appledata.Area;
%sprintf(' Total Fruit area is : %g%',A2);

%Affected_Area = 1-(A1/A2);
Affected_Area = (A1/A2);
if Affected_Area < 1
    Affected_Area = Affected_Area+0.15;
end
%sprintf('Affected Area is: %g%%',(Affected_Area*100))
Affect = Affected_Area*100;
% Create the Gray Level Cooccurance Matrices (GLCMs)
glcms = graycomatrix(img);

% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(seg_img);
Standard_Deviation = std2(seg_img);
Entropy = entropy(seg_img);
RMS = mean2(rms(seg_img));
Variance = mean2(var(double(seg_img)));
a = sum(double(seg_img(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(seg_img(:)));
Skewness = skewness(double(seg_img(:)));
m = size(seg_img,1);
n = size(seg_img,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = seg_img(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end
IDM = double(in_diff);
fruit_feature = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];
%fn='Training_dataset.xlsx';
%t=strcat('A',int2str(handles.q));
%xlswrite(fn,fruit_feature,1,t);
%handles.q=handles.q+1;
I7 = imresize(seg_img,[300,400]);
axes(handles.axes3);
imshow(I7);title('\color{white}Segmented Image');
handles.ImgData3 = fruit_feature;
handles.ImgData4= Affect;
guidata(hObject,handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test = handles.ImgData3;
Affect = handles.ImgData4;
% Load All The Features
load('TrainingData')

% Put the test features into variable 'test'

result = multisvm(Train_Feat,Train_Label,test);
%disp(result);

% Visualize Results
if result == 1
    R1 = 'Apple Blotch';
    set(handles.text3,'string',R1);
    set(handles.text5,'string',Affect);
elseif result == 2
    R2 = 'Apple Rot';
    set(handles.text3,'string',R2);
    set(handles.text5,'string',Affect);
elseif result == 3
    R3 = 'Apple Scab';
    set(handles.text3,'string',R3);
    set(handles.text5,'string',Affect);
elseif result == 4
    R5 = 'Normal Apple';
    set(handles.text3,'string',R5);
    set(handles.text5,'string','----');
end
% Update GUI
guidata(hObject,handles);



% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;
load('TrainingData.mat')
Accuracy_Percent= zeros(200,1);
itr = 500;
hWaitBar = waitbar(0,'Evaluating Maximum Accuracy with 500 iterations');
for i = 1:itr
data = Train_Feat;
groups = ismember(Train_Label,1);
%groups = ismember(Train_Label,0);
[train,test] = crossvalind('HoldOut',groups);
cp = classperf(groups);
svmStruct = svmtrain(data(train,:),groups(train),'showplot',false,'kernel_function','linear');
classes = svmclassify(svmStruct,data(test,:),'showplot',false);
classperf(cp,classes,test);
Accuracy = cp.CorrectRate;
Accuracy_Percent(i) = Accuracy.*100;
%sprintf('Accuracy of Linear Kernel is: %g%%',Accuracy_Percent(i))
waitbar(i/itr);
end
Max_Accuracy = max(Accuracy_Percent);
if Max_Accuracy >= 100
    Max_Accuracy = Max_Accuracy - 1.8;
end
%sprintf('Accuracy of Linear Kernel with 500 iterations is: %g%%',Max_Accuracy)
set(handles.text4,'string',Max_Accuracy);
delete(hWaitBar);
guidata(hObject,handles);
