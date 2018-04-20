/****************************************一、宏变量*****************************************/

/**********PRACTICE1***********/
%let var = city;
%put &var.;
%put &var;/*".": 定界符；如果宏变量之后没有跟任何东西，加不加定界符，效果一样*/
%put &var1;
%put &var.1;/*如果宏变量后面有其他文本，必须加上定界符*/


/**********PRACTICE2***********/
%let var = city;
%let n = Birmingham;
%put &var of &n;
%put &&var of &&n;/*宏处理器从左到右把每两个&解析成一个&*/
%put &&&var of &&&n;/*宏处理器从左到右把每两个&解析成一个&,所以即为&var of &n,输出结果与上一条一致*/


/**********PRACTICE3***********/
%let city1=Shanghai;
%let city2=Beijing;
%let city3=Chengdu;
%let city4=Tianjin;
%let city5=Guangzhou;
%macro listthem;
%do n=1 %to 5;
&&city&n   /*宏处理器从左到右把每两个&解析成一个&，即为&city&n，SAS显示的即为city1，city2，city3，city4，city5的值，即上文中的5个城市*/
%end;
%mend listthem;
%put %listthem;


/**********PRACTICE4***********/
%let site=2010 EXPO Shanghai;
%let road=%scan(&site,2);/*%SCAN 函数首先在宏变量SITE中查找第二个单词，为EXPO，然后将EXPO赋值给宏变量RODA*/
%put &site;
%put &road;



/****************************************二、宏*****************************************/
/*************************************************************************************
编辑宏时，用户必须定义一个宏，通常的形式为： 
     %MACRO <宏名>
          …<宏文本>…
     %MEND    <宏名>

调用宏时，使用以下形式：
    %宏名

注：对于简单的文本说明，使用宏变量比定义一个宏更有效；但在复杂的任务中，宏比宏变量更有优势。
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
%plot /*如果想改变宏内SAS程序的值，可以在SAS程序中引入宏变量，然后在调用这个宏之前用％LET语句对这语句中的宏变量赋值,
		输出结果与Practice1一致*/
%let x=age;
%plot/*将X改成了AGE，所以输出的结果为AGE与WEIGHT的散点图*/
Proc print;
Run;


/**********PRACTICE3***********/
/*多次使用了%LET语句，使得程序看起来比较累赘，这时可以将宏变量作为宏定义语句%MACRO的一部分，以精简SAS程序，如：*/
%macro plot(x,y);
proc plot;
plot &x*&y;
run;
%mend plot;
data temp;set MATTCC.health;
If sex=1;
run;
%plot (height, weight);
%plot (age, weight);/*结果与PRACTICE2一致，这里简化了程序，无需用%let语句再次定义*/
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
where sector=‘se’;
format manager $mgrfmt.dept$deptfmt.sales dollar11.2;
title ‘Sales for the Southeast Sector’;
Run;
%end;
%mend whatstep;
%whatstep(info=print, mydata=grocery)
%whatstep(info=report, mydata=book)
/*如果info=print,运行第一个DO；如果info<>print，运行第二个do*/


/**********PRACTICE5***********/
%macro names (name=,number=);
%do n=1 %to &number;
&name &n
%end;
%mend names;
Data %names (name=dsn, number=5);
/*→DATA DSN1 DSN2 DSN3 DSN4 DSN5;*/

