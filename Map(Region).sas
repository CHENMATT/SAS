/*data china;set maps.china2;
run;sas自带的数据集，无法直接编辑，需要先创建一个一样的数据集;据大神说可以先编辑,再用out导出,步骤如下,亲测没有问题,谢谢大神*/

proc sort data=maps.china2 out=china;;
by idname;
run;

proc sort data=mattcc.map_region;
by idname;
run;

data tmpmap;
merge china mattcc.map_region;
by idname;
if idname="Zhongqing Shi" then delete;
run;/*合并之前必须先排序,尤其是merge*/


proc sort data=tmpmap;
by id;
run;

proc sort data=maps.china;
by id;
run;

data mapbyregion;
merge maps.china tmpmap;
by id;
if id=24 then region="North";
if id=26 then region="South & Central";
if idname="Jiangsu Sheng" then region="EC2";
run;/*maps.china2中没有经纬度（X, Y坐标），所以必须通过maps.china进行构图，构图方式是沟通过ID，
    所以需要先通过ID将maps.china与之前已经合并的tmpmap进行合并，记住合并之前必须先排序*/


proc gmap data=mapbyregion map=maps.china;
id id;
choro region/coutline=black;
title Oney geographic division;
pattern1 color=bigb;
pattern2 color=bio;
pattern3 color=coral;
pattern4 color=lightslategray;
run;

