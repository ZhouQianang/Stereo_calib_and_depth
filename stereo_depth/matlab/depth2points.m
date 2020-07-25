

intrinsic=[451.607740200530,0.,343.998551683970;
       0.,457.029505887742,235.146157222543;
       0.,0.,1. ];

fdx=intrinsic(1,1);
fdy=intrinsic(2,2);
u0=intrinsic(1,3);
v0=intrinsic(2,3);

[h,w] = size(pic2);
u=repmat(1:w,[h,1]);
v=repmat(1:h,[w,1])';

f1=imread('DJI_STE_left_3.jpg');

fg=uint8(zeros(size(f1,1),size(f1,2),3));
fg(:,:,1)=f1;
fg(:,:,2)=f1;
fg(:,:,3)=f1;
pic2(pic2<0.5)=0.0;
pic2(pic2>10.0) = 0.0;

Z=pic2;
X=(Z(:).*(u(:)-u0))/fdx;
Y=(Z(:).*(v(:)-v0))/fdy;

ptCloud=pointCloud([X(:),Y(:),Z(:)],'Color',reshape(fg,[],3));

 pcshow(ptCloud,'MarkerSize',125);


