clear;

dir_path="images";
file_list=dir(fullfile(dir_path));
file_list=file_list([3:end]);
count=size(file_list,1);
ti=imread(fullfile(dir_path,file_list(1).name));
ih=size(ti,1);
iw=size(ti,2);
clear ti;
image_data=zeros(count,ih,iw,3);

disp 'Reading image data...'
parfor k=1:count
    image_data(k,:,:,:)=imread(fullfile(dir_path,file_list(k).name));
end
disp 'Reading process finished.'

diff_data_h=zeros(count,count);
diff_data_v=zeros(count,count);
entropys_h=zeros(count,count);
entropys_v=zeros(count,count);

dq = parallel.pool.DataQueue;
wb = waitbar(0, 'Measuring distances...');
wb.UserData = [0 count];
afterEach(dq, @(varargin) iIncrementWaitbar(wb));

parfor i=1:count
    for j=1:count
        h1=reshape(image_data(i,:,iw,:),[ih*3,1]);
        h2=reshape(image_data(j,:,1,:),[ih*3,1]);
        diff_data_h(i,j)=sum(sum((h1-h2).^2))/ih; %H矩阵
        entropys_h(i,j)=min(var(h1),var(h2)); %Eh矩阵
        v1=reshape(image_data(i,ih,:,:),[iw*3,1]);
        v2=reshape(image_data(j,1,:,:),[iw*3,1]);
        diff_data_v(i,j)=sum(sum((v1-v2).^2))/iw; %V矩阵
        entropys_v(i,j)=min(var(v1),var(v2)); %Ev矩阵
    end
    if mod(i,10)==0
        send(dq, i);
    end
end
close(wb);

disp 'Preprocess finished.'

function iIncrementWaitbar(wb)
ud = wb.UserData;
ud(1) = ud(1) + 10;
waitbar(ud(1) / ud(2), wb);
wb.UserData = ud;
end