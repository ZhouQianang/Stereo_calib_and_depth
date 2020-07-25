%function [ pic2 ] = xml2mat( xml_name )
%clear;
%读取opencv中xml文件，表示的是矩阵。
 xmlDoc = xmlread('DJI_STE_depth_3.xml');
 %得到矩阵的行数
 row = xmlDoc.getElementsByTagName('rows').item(0).getFirstChild.getData;
 %得到矩阵的列数
 col = xmlDoc.getElementsByTagName('cols').item(0).getFirstChild.getData;
 row = str2num(row);%读入是string类型，转为数字；
 col = str2num(col);%opencv_
 %此时读入的是一串字符
 histstring =char(xmlDoc.getElementsByTagName('data').item(0).getFirstChild.getData);

x1 =strtrim(histstring);%去除首位空格，一般在首位有空格
x2 = strsplit(x1);%按照空格切分字符
x3 = str2double(x2);%转为double型

pic1 = reshape(x3,col,row);%转为（col,row）尺寸的mat
pic2 = pic1';%求转置，这是因为xml文件中的数据是一列一列写入的
%imshow(pic2,[]);
%end
