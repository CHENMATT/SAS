/*       
 *                                    _ooOoo_
 *                                   o8888888o
 *                                   88" . "88
 *                                   (| -_- |)
 *                                   O\  =  /O
 *                                ____/`---'\____
 *                              .'  \\|     |//  `.
 *                             /  \\|||  :  |||//  \
 *                            /  _||||| -:- |||||-  \
 *                            |   | \\\  -  /// |   |
 *                            | \_|  ''\---/''  |   |
 *                            \  .-\__  `-`  ___/-. /
 *                          ___`. .'  /--.--\  `. . __
 *                       ."" '<  `.___\_<|>_/___.'  >'"".
 *                      | | :  `- \`.;`\ _ /`;.`/ - ` : | |
 *                      \  \ `-.   \_ __\ /__ _/   .-` /  /
 *                 ======`-.____`-.___\_____/___.-`____.-'======
 *                                    `=---='
 *                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 *                            ���汣��        ����BUG
 *                   ��Ի:
 *                          д��¥��д�ּ䣬д�ּ������Ա��
 *                          ������Աд�������ó��򻻾�Ǯ��
 *                          ����ֻ���������������������ߣ�
 *                          ��������ո��գ����������긴�ꡣ
 *                          ��Ը�������Լ䣬��Ը�Ϲ��ϰ�ǰ��
 *                          ���۱������Ȥ���������г���Ա��
 *                          ����Ц��߯��񲣬��Ц�Լ���̫����
 *                          ��������Ư���ã��ĸ���ó���Ա��
*/

%macro datechange(var);
year_update=substr(&var,1,4)*1;
month_update=substr(&var,6,2)*1;
day_update=substr(&var,9,2)*1;
hour_update=substr(&var,12,2)*1;
minut_update=substr(&var,15,2)*1;
sec_update=substr(&var,18,2)*1;
date_update=mdy(month_update,day_update,year_update);format date_update date10.;
&var._update=dhms(date_update,hour_update,minut_update,sec_update);
format &var._update datetime.;
drop year_update month_update day_update hour_update minut_update sec_update;
%mend datechange;

%let path=/usr/sasmeta/Lev1/SASApp/DEPOSE_FIC_TEXTE/SHAREDATA/SIGNANDGO/output_sql_table_info;
/*%let day=%sysfunc(year(%sysfunc(today())))%sysfunc(putn(%sysfunc(month(%sysfunc(today()))),z2.))%sysfunc(putn(%sysfunc(day(%sysfunc(today()))),z2.));*/
/*���ϴ��룬���˱���ʱ��18��00���ң����Զ��л�Ϊ�ڶ��죬����run�Ľ���������ҵľ������죬����װ��һ����sas*/
/*%let today=%sysfunc(today(),yymmddn8.);/*����run�Ľ���������ҵľ������죬����װ��һ����sas*/
/**/

data _null_;
		call symput("day",left(compress(put("&sysdate"d,yymmdd10.),"-"," ")));
		call symput("yesterday",left(compress(put("&sysdate"d,yymmdd10.),"-"," ")-1));
		call symput("lastmonth",substr(compress(put(intnx('month',today(),-1),yymmdd10.),"-" ),1,6));
		call symput("last2months",substr(compress(put(intnx('month',today(),-2),yymmdd10.),"-" ),1,6));
        call symput ("thismonthbegdate", compress(put(intnx('month',today(),-0,'b'),yymmdd10.),"-" ));       
        call symput ("lastmonthenddate", compress(put(intnx('month',today(),-1,'e'),yymmdd10.),"-" ));
		call symput ("thismonthenddate", compress(put(intnx('month',today(),-0,'e'),yymmdd10.),"-" ));
		call symput ("lastmonthbegdate", compress(put(intnx('month',today(),-1,'b'),yymmdd10.),"-" ));
		call symput ("DAYSTILLENDTHISMONTH", compress(put(intnx('month',today(),-0,'e'),yymmdd10.),"-" )-left(compress(put("&sysdate"d,yymmdd10.),"-"," ")));
		call symput("INITREFMONTH",substr(compress(put(intnx('month',today(),-4),yymmdd10.),"-" ),1,6));
run;
%put &day.;
%put &yesterday.;
%put &lastmonth.;
%put &last2months.;
%put &thismonthbegdate.;
%put &lastmonthenddate.;
%put &thismonthenddate.;
%put &lastmonthbegdate.;
%put &DAYSTILLENDTHISMONTH.;
%put &INITREFMONTH.;

/*%let day=20180414; */

%macro StoreFdsFormat;
proc format;
invalue $ storename "����������1071"="Shuyang 1071"  "���󷢻�����5008"="Huadu 5008" "�����ռ��͵�3018"="Sujiatun 3018" 
"���󷢳��д󻪷ֵ�1005"="Dahua 1005" "����������105"="Wuxi 105" "ŷ���Ͼ�������118"="Jiangning 118" "ŷ�����ݽ𼦺���104"="Suzhou 104" 
"ŷ�г���"="Changyang 103" ;
invalue $ FDSNAME "baizhitao"="Bai Zhitao" "liyan"="Li Yan" "zhongjiemei"="Zhong Jiemei" "liangjialiang"="Liang Jialiang" 
"liumiao"="Liu Miao" "chenjialin"="Chen Jialin" "wangyang"="Wang Yang" "chenyan"="Chen Yan" "yangchaowei"="Yang Chaowei"
"chenxingyue"="Chen Xingyue" "yinxiu"="Yin Xiu" "sunxiaobo"="Sun Xiaobo" "yangzhigang"="Yang Zhigang" 
"shizhichao"="Shi Zhichao" "Shizhichao"="Shi Zhichao" "gongqing"="Gong Qing" "xuxiaomin"="Xu Xiaomin" "zhuxuelei"="Zhu Xuelei" 
"yangcaowei"="Yang Chaowei" "chenjuan"="Chen Juan" "derekcheng"="Derek Cheng" "yaoyin"="Yao Yin" "zhaochun"="Zhao Chun"
"jiexiaojing"="Jie Xiaojing";
value TIMEPERIOD low-<'09:00:01't='09:00' '09:00:01't-<'09:30:01't='09:00:01-09:30:00' '09:30:01't-<'10:00:01't='09:30:01-10:00:00'
'10:00:01't-<'10:30:01't='10:00:01-10:30:00' '10:30:01't-<'11:00:01't='10:30:01-11:00:00' '11:00:01't-<'11:30:01't='11:00:01-11:30:00' 
'11:30:01't-<'12:00:01't='11:30:01-12:00:00' '12:00:01't-<'12:30:01't='12:00:01-12:30:00' '12:30:01't-<'13:00:01't='12:30:01-13:00:00'
'13:00:01't-<'13:30:01't='13:00:01-13:30:00' '13:30:01't-<'14:00:01't='13:30:01-14:00:00' '14:00:01't-<'14:30:01't='14:00:01-14:30:00'
'14:30:01't-<'15:00:01't='14:30:01-15:00:00' '15:00:01't-<'15:30:01't='15:00:01-15:30:00' '15:30:01't-<'16:00:01't='15:30:01-16:00:00'
'16:00:01't-<'16:30:01't='16:00:01-16:30:00' '16:30:01't-<'17:00:01't='16:30:01-17:00:00' '17:00:01't-<'18:00:01't='17:30:01-18:00:00'
'18:00:01't-<'18:30:01't='18:00:01-18:30:00' '18:30:01't-<'19:00:01't='18:30:01-19:00:00' '19:00:01't-<'19:30:01't='19:00:01-19:30:00'
'19:30:01't-<'20:00:01't='19:30:01-20:00:00' '20:00:01't-<'20:30:01't='20:00:01-20:30:00' '20:30:01't-<'21:00:01't='20:30:01-21:00:00'
'21:00:01't-high='21:00:00';
%mend StoreFdsFormat;

%macro PosnameFds_E(X,Y);
POSNAME =input(&X, $storename.);
FDS_E=input(compress(&Y,,"d"),$FDSNAME.);
%mend PosnameFds_E;

%macro TIMEPERIOD(X,Y,Z);
APPLYTIMEPERIOD=put(&X,TIMEPERIOD.);
FIRSTAPPROVEPERIOD=put(&Y,TIMEPERIOD.);
FINALAPPROVEPERIOD=put(&Z,TIMEPERIOD.);
%mend TIMEPERIOD;

%macro YMD(X);
applyyear=input(substr(&X,4,4),4.);
applymonth=input(substr(&X,4,6),6.);
applyday=input(substr(&X,4,8),8.);
%mend YMD;

%macro SORT(X);
proc sort;
by &X;
run;
%mend SORT;


/*SAS SYSTEM INFORMATION*/
proc setinit;
run;

/*proc options option = MACRO;*/
/*run;*/

/*%put _automatic_;*/
/*%put _user_;*/

