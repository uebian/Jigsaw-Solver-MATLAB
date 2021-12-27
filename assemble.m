tic
placed=zeros(count,'int8');
mapsizew=floor(count*1.5);
mapsizeh=floor(count*1.5);
map=zeros(mapsizeh,mapsizew,'int16');

zmat=-entropys_v;
[data,idx]=sort(reshape(squeeze(zmat),[count^2,1]));
cur=mod(idx(1),count);
curx=round(mapsizeh/2);
cury=round(mapsizew/2);
map(curx,cury)=cur;
placed(cur)=1;
filledinfo=zeros(count,2);
filledinfo(1,:)=[curx cury];
losslog=zeros(count,1);
t=1;

direction=[-1 0;1 0;0 -1;0 1];
maxv=0;
while t<count
    bv=0x7ffffff;
    bp=[0,0,0,0];
    k=1;
    while k<=t
        cp=filledinfo(k,:);
        curx=cp(1);
        cury=cp(2);
        flag=1;
        for j=1:4
                if(map(curx+direction(j,1),cury+direction(j,2))==0)
                    flag=0;
                end
        end
        if(flag==1)
            k=k+1;
            continue;
        end
        for i=1:count
            if(placed(i)==1)
                continue
            end
            for j=1:4
                if(map(curx+direction(j,1),cury+direction(j,2))~=0)
                    continue
                end
                c=checkCompatibility(i,curx+direction(j,1),cury+direction(j,2),diff_data_h,diff_data_v,map,entropys_h,entropys_v);
                if(c<bv)
                    bv=c;
                    bp=[k,i,curx+direction(j,1),cury+direction(j,2)];
                end
            end
        end
        k=k+1;
    end
    map(bp(3),bp(4))=bp(2);
    placed(bp(2))=1;
    losslog(t)=bv;
    trycount=1;
    maxv=max(maxv,bv);
    
    t=t+1;
    filledinfo(t,:)=[bp(3) bp(4)];
    if(mod(t,20)==0)
        fprintf("%d/%d\n",t,count);
    end
end
fprintf("maxv=%d\n",t,maxv);
map(all(map==0,2),:) = [];
map(:,all(map==0,1))= [];
nsize=size(map);
mapsizeh=nsize(1);
mapsizew=nsize(2);
dimg=ones(ih*mapsizeh,iw*mapsizew,3,'uint8')*255;
for i=1:mapsizeh
    for j=1:mapsizew
        if(map(i,j)~=0)
            dimg(1+(i-1)*ih:ih+(i-1)*ih,1+(j-1)*iw:iw+(j-1)*iw,:)=squeeze(image_data(map(i,j),:,:,:));
        end
    end
end
toc
imshow(dimg)
imwrite(dimg,"./result.png");

function c=checkCompatibility(i,x,y,diff_data_h,diff_data_v,map,entropys_h,entropys_v)
k1=1;
k2=0.1;
valid=0;
c=0;
e=0;
if(map(x-1,y)~=0)
    valid=valid+1;
    c=c+diff_data_v(map(x-1,y),i);
    e=e+entropys_v(map(x-1,y),i);
end
if(map(x+1,y)~=0)
    valid=valid+1;
    c=c+diff_data_v(i,map(x+1,y));
    e=e+entropys_v(i,map(x+1,y));
end
if(map(x,y-1)~=0)
    valid=valid+1;
    c=c+diff_data_h(map(x,y-1),i);
    e=e+entropys_h(map(x,y-1),i);
end
if(map(x,y+1)~=0)
    valid=valid+1;
    c=c+diff_data_h(i,map(x,y+1));
    e=e+entropys_h(i,map(x,y+1));
end
e=e/valid;
c=c/valid;
c=c/e^k1/log(valid+k2);
end