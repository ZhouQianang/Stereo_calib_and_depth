%function [ pic2 ] = xml2mat( xml_name )
%clear;
%��ȡopencv��xml�ļ�����ʾ���Ǿ���
 xmlDoc = xmlread('./best/depth/DJI_STE_depth_3.xml');
 %�õ����������
 row = xmlDoc.getElementsByTagName('rows').item(0).getFirstChild.getData;
 %�õ����������
 col = xmlDoc.getElementsByTagName('cols').item(0).getFirstChild.getData;
 row = str2num(row);%������string���ͣ�תΪ���֣�
 col = str2num(col);%opencv_
 %��ʱ�������һ���ַ�
 histstring =char(xmlDoc.getElementsByTagName('data').item(0).getFirstChild.getData);

x1 =strtrim(histstring);%ȥ����λ�ո�һ������λ�пո�
x2 = strsplit(x1);%���տո��з��ַ�
x3 = str2double(x2);%תΪdouble��

pic1 = reshape(x3,col,row);%תΪ��col,row���ߴ��mat
pic2 = pic1';%��ת�ã�������Ϊxml�ļ��е�������һ��һ��д���
%imshow(pic2,[]);
%end