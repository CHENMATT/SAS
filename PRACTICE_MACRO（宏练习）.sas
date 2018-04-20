/****************************************һ�������*****************************************/

/**********PRACTICE1***********/
%let var = city;
%put &var.;
%put &var;/*".": ���������������֮��û�и��κζ������Ӳ��Ӷ������Ч��һ��*/
%put &var1;
%put &var.1;/*�������������������ı���������϶����*/


/**********PRACTICE2***********/
%let var = city;
%let n = Birmingham;
%put &var of &n;
%put &&var of &&n;/*�괦���������Ұ�ÿ����&������һ��&*/
%put &&&var of &&&n;/*�괦���������Ұ�ÿ����&������һ��&,���Լ�Ϊ&var of &n,����������һ��һ��*/


/**********PRACTICE3***********/
%let city1=Shanghai;
%let city2=Beijing;
%let city3=Chengdu;
%let city4=Tianjin;
%let city5=Guangzhou;
%macro listthem;
%do n=1 %to 5;
&&city&n   /*�괦���������Ұ�ÿ����&������һ��&����Ϊ&city&n��SAS��ʾ�ļ�Ϊcity1��city2��city3��city4��city5��ֵ���������е�5������*/
%end;
%mend listthem;
%put %listthem;


/**********PRACTICE4***********/
%let site=2010 EXPO Shanghai;
%let road=%scan(&site,2);/*%SCAN ���������ں����SITE�в��ҵڶ������ʣ�ΪEXPO��Ȼ��EXPO��ֵ�������RODA*/
%put &site;
%put &road;



/****************************************������*****************************************/
/*************************************************************************************
�༭��ʱ���û����붨��һ���꣬ͨ������ʽΪ�� 
     %MACRO <����>
          ��<���ı�>��
     %MEND    <����>

���ú�ʱ��ʹ��������ʽ��
    %����

ע�����ڼ򵥵��ı�˵����ʹ�ú�����ȶ���һ�������Ч�����ڸ��ӵ������У���Ⱥ�����������ơ�
**************************************************************************************/

/**********PRACTICE1***********/
%macro plot;
proc plot;
plot height*weight;
run;
%mend plot;
data temp;set MATTCC.health;
if sex=1;
run;
%plot
proc print;
run;


/**********PRACTICE2***********/
%macro plot;
proc plot;
Plot &X*&y;
run;
%mend plot;
data temp;
Set MATTCC.health;
If sex=1;
run;
%let x=height;
%let y=weight;
%plot /*�����ı����SAS�����ֵ��������SAS����������������Ȼ���ڵ��������֮ǰ�ã�LET����������еĺ������ֵ,
		��������Practice1һ��*/
%let x=age;
%plot/*��X�ĳ���AGE����������Ľ��ΪAGE��WEIGHT��ɢ��ͼ*/
Proc print;
Run;


/**********PRACTICE3***********/
/*���ʹ����%LET��䣬ʹ�ó��������Ƚ���׸����ʱ���Խ��������Ϊ�궨�����%MACRO��һ���֣��Ծ���SAS�����磺*/
%macro plot(x,y);
proc plot;
plot &x*&y;
run;
%mend plot;
data temp;set MATTCC.health;
If sex=1;
run;
%plot (height, weight);
%plot (age, weight);/*�����PRACTICE2һ�£�������˳���������%let����ٴζ���*/
proc print;
run;


/**********PRACTICE4***********/
%macro whatstep(info=, mydata=);
%if &info=print %then
%do;
Proc print data=&mydata;
run;
%end;
%else %if
&info=report %then
%do;
options nodate nonumber ps=18 ls=70 fmtsearch=(sasuser);
Proc report data=&mydata nomd;
column manager dept sales;
where sector=��se��;
format manager $mgrfmt.dept$deptfmt.sales dollar11.2;
title ��Sales for the Southeast Sector��;
Run;
%end;
%mend whatstep;
%whatstep(info=print, mydata=grocery)
%whatstep(info=report, mydata=book)
/*���info=print,���е�һ��DO�����info<>print�����еڶ���do*/


/**********PRACTICE5***********/
%macro names (name=,number=);
%do n=1 %to &number;
&name &n
%end;
%mend names;
Data %names (name=dsn, number=5);
/*��DATA DSN1 DSN2 DSN3 DSN4 DSN5;*/

