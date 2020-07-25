## 基于opencv的双目相机标定(stereo_calib.cpp)
stereo_calib.cpp是opencv的例程，在"opencv-3.2.0/samples/cpp"目录下，标准标定图片left01.jpg--left14.jpgm,right01-jpg--right14.jpg以及用于标定的图片文件名stereo_calib.xml在"opencv-3.2.0/samples/data"目录下。运行例程时需要将这些文件同时拷出。

### 运行例程
将本项目下载到本地后，首先在build目录下用cmake编译
```
cmake ..
make
```
切回data目录下，运行
```
../build/stereo_calib -w=9 -h=6 stereo_calib.xml
```
标定生成两个文件，分别是内参intrinsics.yml和外参extrinsics.yml。

### 运行自己的图片
和data平行建立文件夹data1，然后放入图片和stereo_calib.xml，并修改stereo_calib.xml中的图片名，运行过程同上，只需要将w和h改成自己标定板的角点个数即可。需要注意的是，待标定图片的质量很重要，应尽量保证以下几点：
* 标定板覆盖相机的大片视野。可以参考例程的图片。
* 静止拍照。角点模糊会直接影响标定精度。
* 标定板平整。
附注：
如果标定的结果校正出来的图片很扭曲，甚至看不到原图的样子，可能原因有：
1、角点提取错误。在stereo_calib.cpp中，可以将函数StereoCalib的displaycorners参数设为true，即可显示角点提取结果。
2、角点顺序错误。左右两张图片的角点提取，还要保证顺序相同，否则会造成很大扭曲。
3、标定板占图片区域太少。可能出现能看到完整图片，但是只在中间很小一个区域，周围仍然是扭曲的图像的情况。

## 深度计算(stereo_match.cpp)
stereo_match.cpp只能给出视差图disp，程序默认用SGBM算法计算视差 orz。且由于该视差并不是真正的视差(差了16倍)，因此在计算深度时需要考虑。视觉几何的推导不必介绍，下面介绍计算深度需要的参数
* baseline：左右相机距离，该参数在标定的相机外参extrinsics.yml中T向量第一个值，取绝对值，单位是mm
* f：归一化焦距，由于只在x方向有视差，用fx即可，深度图一般取左深度，因此用左相机的深度即可。fx的单位是pixel，原因在[这里](https://blog.csdn.net/tercel_zhang/article/details/90523181).
* d：视差，单位为pixel，从disp中读取，除以16的原因在[这里](https://blog.csdn.net/bennygato/article/details/37704259)，读取方式为：
```
d = (float)disp.at<short int>(h,w)*0.0625;
```
公式：depth(mm) = baseline(mm) * fx(pixel) / d(pixel)

将标定好的内外参文件放在主目录下，在主目录下运行：
```
build/stereo_match DJI_STE_left_760.jpg DJI_STE_right_760.jpg --max-disparity=80 --blocksize=7 -i=intrinsics.yml -e=extrinsics.yml
```
就得到了视差图的xml文件以及深度图的xml文件。

## 深度图存储，在matlab中读取并显示点云。
计算得到的深度数据，因为是浮点值，可以存放在CV_32FC1的Mat对象中，并写成xml文件，方便存储和读取。上一步运行的程序已经生成了depth.xml和disp.xml。xml文件存放的浮点类Mat数据可以被其他程序读入且不损失精度。以Mat形式写入xml文件，并在matlab中读取，显示点云。这在项目的matlab目录下，用xml2mat.m和depth2points.m实现
xml2mat.m中的xml文件名需要改成深度数据点，depth2points.m中的图片名需要改成已经校正好的图片，这在上一步也生成了(rec1.jpg,rec2.jpg)。
```
xml2mat;
depth2points;
```

## 用matlab标定相机参数，并应用于opencv以提高精度
opencv的相机标定，每张图片的误差显示不出来，但是matlab比较清晰，有每张图片的矫正结果、误差、相机位姿等显式的结果，而且结果往往比opencv的例程更可靠一点，因此，如果需要提高精度，可以选择用matlab进行标定，并将参数转换为opencv能用的格式(intrinsics.yml,extrinsics.yml)，下面比较matlab和opencv的立体相机参数。
### intrinsics
|内参|opencv|matlab|备注|
|----|----|----|----|
|左相机内参矩阵|M1|stereoParameters.CameraParameters1.IntrinsicMatrix|两者是转置关系|
|右相机内参矩阵|M2|stereoParameters.CameraParameters2.IntrinsicMatrix|两者是转置关系|
|左相机畸变参数|D1|stereoParameters.CameraParameters1.RadialDistortion|matlab畸变参数少|
|右相机畸变参数|D2|stereoParameters.CameraParameters2.RadialDistortion|matlab畸变参数少|
### extrinsics
|外参|opencv|matlab|备注|
|----|----|----|----|
|右相机相对左相机的旋转|R|stereoParameters.RotationOfCamera2|两者是转置关系|
|右相机相对左相机的平移|T|stereoParameters.TranslationOfCamera2|两者相等|
|左相机的校正矩阵|R1|None|matlab没有显式给出，或者我没有发现|
|右相机的校正矩阵|R2|None|同上|
|左相机的投影矩阵|P1|None|同上|
|右相机的校正矩阵|P2|None|同上|
|Q矩阵|Q|None|同上|


虽然最后5个参数matlab没有明确给出，但是这5个参数可以由之前的6个参数求出，在opencv中有stereoRectify函数可以由这6个参数求出后续的5个参数。

同时，尽管opencv在标定的时候会生成11个参数，但在opencv的立体匹配例程stereo_match.cpp中，只使用了前6个参数，后5个是在计算的过程中自己求解的，因此可以利用该例程，生成这5个参数(需要这5个参数的目的是，有的应用场景下，要求输入的参数不包含R，T，只需要那些投影矩阵和校正矩阵，比如大疆M210)。

将Matlab标定出的参数，复制到yml文件中，注意yml文件的格式，参数换行需要缩进，与data后面的":"保持一致。用matlab参数对应内外参文件运行stereo_match.cpp，就可以得到R1 R2 P1 P2 Q等参数。
