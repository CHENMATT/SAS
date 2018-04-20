/*data china;set maps.china2;
run;sas�Դ������ݼ����޷�ֱ�ӱ༭����Ҫ�ȴ���һ��һ�������ݼ�;�ݴ���˵�����ȱ༭,����out����,��������,�ײ�û������,лл����*/

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
run;/*�ϲ�֮ǰ����������,������merge*/


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
run;/*maps.china2��û�о�γ�ȣ�X, Y���꣩�����Ա���ͨ��maps.china���й�ͼ����ͼ��ʽ�ǹ�ͨ��ID��
    ������Ҫ��ͨ��ID��maps.china��֮ǰ�Ѿ��ϲ���tmpmap���кϲ�����ס�ϲ�֮ǰ����������*/


proc gmap data=mapbyregion map=maps.china;
id id;
choro region/coutline=black;
title Oney geographic division;
pattern1 color=bigb;
pattern2 color=bio;
pattern3 color=coral;
pattern4 color=lightslategray;
run;

