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


%let DATE=20180401;
%let DEDATE=20180402;

%StoreFdsFormat
data dps_apply_info;
set dps_apply_info&day.;
%datechange(APPLYDATE);%datechange(APPROVETIME);%datechange(FINISHDATE);%datechange(INPUTDATE);
%PosnameFds_E(POSNAME,INPUTER);%datechange(signcontract);%YMD(applycode);
input_minutes=applydate_update - inputdate_update;
format input_minutes time8.;
if status= 3 or status=4 or status =8 or (status=0 and applydate^="none");
APPLY_TIME=timepart(applydate_update);format APPLY_TIME time.;
run;

/**********************************************��������ʱ���******************************************************/
/***************************����PROCESS�����ڻ��˵��²�һ�£�����Ҫ�������һ�εĽ�����в���******************************
****************************************************************************************************************/
data work.processupdate;
	set dps_pre_socrecard&day.(keep=applycode createtime process);
	%datechange(createtime);
	drop date_update createtime;
run;

proc sort data=work.processupdate;
by applycode createtime_update;
run;

data process; set work.processupdate;
by applycode;
if last.applycode;
drop createtime_update;
run;

data timeprescore;
merge processupdate(drop=process)
	  process;
by applycode;
	drop date_update createtime;
	if process='A' then verif='Only ID'; /*******���ֹ���verif���ж�׼��*******/
	else if process='H' then
		verif='Hard';
	else if process='M' then
		verif='Medium';
	else if process='E' then
		verif='Easy';
run;

proc sort data=work.timeprescore;
	by applycode process verif createtime_update;
run;

proc transpose data=work.timeprescore out=work.timeprescoretrana(drop=_NAME_ rename=(col1=checktime1 col2=checktime2 col3=checktime3 col4=checktime4 col5=checktime5));/*�п��ܻ�����*/
	by applycode process verif;
	var createtime_update;
run;

/**********************************************����ʱ���******************************************************/
data work.timereturn;
	set work.dps_return_record(keep=applycode returntime);
run;

proc sort data=work.timereturn;
	by applycode returntime;
run;

proc transpose data=work.timereturn out=work.timereturntran(drop=_NAME_ rename=(col1=returntime1 col2=returntime2 col3=returntime3 col4=returntime4));
	by applycode;
	var returntime;
run;

/**********************************************���˴���******************************************************/
proc sql;
	create table returntimes as
		select distinct applycode, count(*) as RETURNTIMES from work.timereturn
			group by applycode;
run;

/*********************************************����/������Ϣ******************************************************/
data work.firstapprove;set work.firstapprove&day.;
Firstappro_Ym=substr(approvetime,1,10);
firstappro_time=substr(approvetime,12,8);
%datechange(approvetime)
firstapprover=approver;
FIRSTAPPROVETIME=approvetime_update;format FIRSTAPPROVETIME datetime.;
FIRSTAPPROVEHMS=timepart(FIRSTAPPROVETIME);format FIRSTAPPROVEHMS time.;
keep applycode firstappro_ym firstappro_time firstapprover FIRSTAPPROVETIME FIRSTAPPROVEHMS;
run;

data work.finalapprove;set work.finalappro&day.;
finalappro_ym=substr(approvetime,1,10);
finalappro_time=substr(approvetime,12,8);
%datechange(approvetime)
finalapprover=approver;
FINALAPPROVETIME=approvetime_update;format FINALAPPROVETIME datetime.;
FINALAPPROVEHMS=timepart(FINALAPPROVETIME);format FINALAPPROVEHMS time.;
keep applycode finalappro_ym finalappro_time finalapprover FINALAPPROVETIME FINALAPPROVEHMS;
run;


/**********************************************�ϲ����ܱ�******************************************************/
proc sort data=dps_apply_info;
by applycode;
run;

proc sort data=timeprescoretrana;
	by applycode;
run;

proc sort data=timereturntran;
	by applycode;
run;

proc sort data=returntimes;
	by applycode;
run;

proc sort data=firstapprove;
	by applycode;
run;

proc sort data=finalapprove;
	by applycode;
run;

data APPLY_APPROVE_RETURN_INFO;
	merge work.dps_apply_info(in=A)
		  work.timeprescoretrana
		  work.timereturntran
		  work.returntimes
          work.firstapprove
		  work.finalapprove;
by applycode;
returnduration1=checktime2-returntime1;format returnduration1 time.;
returnduration2=checktime3-returntime2;format returnduration2 time.;
returnduration3=checktime4-returntime3;format returnduration3 time.;
returnduration4=checktime5-returntime4;format returnduration4 time.;
if returnduration1=. then returnduration1=0;
if returnduration2=. then returnduration2=0;
if returnduration3=. then returnduration3=0;
if returnduration4=. then returnduration4=0;
%TIMEPERIOD(APPLY_TIME,FIRSTAPPROVEHMS,FINALAPPROVEHMS);
if applydate_update=. then applydate_update=approvetime_update;
if A=1;
run;

/**********************************************����ҳ����******************************************************/
proc sql;
	create table OUTLINE_APPLYINFO����ҳ���� as 
		select applyday,count(*) as ������,sum(approver^="system") as �˹�������, sum(status=3 or status=4) as ������ͨ����,
		       sum(status=4) as ��ͬ��,sum(status=3 or status=4)/count(*) format percent8.2 as ������ͨ����, 
			   sum(firstapprover^="") as �ܳ�����,sum(finalapprover^="") as ��������,sum(returntimes>=1)as ���˴���,
			   avg(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4) format time8. as ����ƽ������ʱЧ,
			   sum(returnduration1+returnduration2+returnduration3+returnduration4)/sum(returntimes>=1) format time8. as ƽ������ʱ��,	
			   sum(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t) as �ܳ�ʱ����,
			   sum(((approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4)>"00:30:00"t)*(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4))/sum((approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4)>"00:30:00"t) format time8. as ��ʱ����ƽ������ʱЧ
		from work.APPLY_APPROVE_RETURN_INFO
		where applyday >= 20180401
		group by applyday;
run;

/**********************************************������ҳ����******************************************************/
proc sql;
	create table OUTLINE_RULE������ as
		select applyday,count(*) as ���ս�����,sum(scoreresult=0) as ϵͳ�ܾ�������,
               sum(scoreresult=4) as ���ⰸ��������,
		       sum(scoreresult=4 and (status=0 or status=3 or status=4)) as ���ⰸ��ͨ����,
		       sum(scoreresult=4 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4)>"00:30:00"t) as ���ⰸ����ʱ����,
               sum((scoreresult=4)*(approvetime_update-applydate_update))/sum(scoreresult=4) format time8. as ���ⰸ��ƽ������ʱЧ,
               sum(scoreresult=1) as ��������������,
		       sum(scoreresult=1 and (status=0 or status=3 or status=4)) as ��������ͨ����,
		       sum(scoreresult=1 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4)>"00:30:00"t) as ����������ʱ����,
               sum((scoreresult=1)*(approvetime_update-applydate_update))/sum(scoreresult=1) format time8. as ��������ƽ������ʱЧ,
               sum(scoreresult=2) as �м�����������,
		       sum(scoreresult=2 and (status=0 or status=3 or status=4)) as �м�����ͨ����,
		       sum(scoreresult=2 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4)>"00:30:00"t) as �м�������ʱ����,
               sum((scoreresult=2)*(approvetime_update-applydate_update))/sum(scoreresult=2) format time8. as �м�����ƽ������ʱЧ,
               sum(scoreresult=3) as �߼�����������,
		       sum(scoreresult=3 and (status=0 or status=3 or status=1)) as �߼�����ͨ����,
		       sum(scoreresult=3 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4)>"00:30:00"t) as �߼�������ʱ����,
               sum((scoreresult=3)*(approvetime_update-applydate_update))/sum(scoreresult=3) format time8. as �߼�����ƽ������ʱЧ
		from work.APPLY_APPROVE_RETURN_INFO
		where applyday >= 20180401
		group by applyday;
run;

/**********************************************�������˲����ܱ�(��system���ܵ�)******************************************************/
proc sql;
	create table PERSONAL_APPROVAL_PRODUCTIVITY as 
		select applyday, approver, 
			   sum(approver=firstapprover and approver^=finalapprover) as ��������,
			   sum(approver=finalapprover and approver^=firstapprover) as ��������,
               sum(approver=firstapprover and approver=finalapprover) as ����������,
			   sum(scoreresult=4 and approver=firstapprover) as ������󰸼�����,
			   sum(scoreresult=1 and approver=firstapprover) as �������󰸼�����,
			   sum(scoreresult=2 and approver=firstapprover) as �м����󰸼�����,
			   sum(scoreresult=3 and approver=firstapprover) as �߼����󰸼�����,
			   sum(approver=firstapprover and approver^=finalapprover and (status=0 or status=3 or status=4)) as ������ͨ����,
			   sum(approver=finalapprover and approver^=firstapprover and (status=0 or status=3 or status=4)) as ������ͨ����,
			   sum(approver=firstapprover and approver=finalapprover and (status=0 or status=3 or status=4)) as ��������ͨ����,
			   avg(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4) format time8. as ƽ������ʱ��,
			   sum(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t) as ���峬ʱ����,
			   sum(approver=firstapprover and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) as ����ʱ��,
			   sum(approver=firstapprover and scoreresult=4 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) as ���ⳬʱ������,
			   sum(approver=firstapprover and scoreresult=1 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) as ������ʱ������,
			   sum(approver=firstapprover and scoreresult=2 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) as �м���ʱ������,
			   sum(approver=firstapprover and scoreresult=3 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) as �߼���ʱ������,
			   sum((approver=firstapprover and scoreresult=4 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t))*(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4))/sum(approver=firstapprover and scoreresult=4 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) format time8. as ���ⳬʱƽ������ʱЧ,
			   sum((approver=firstapprover and scoreresult=1 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t))*(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4))/sum(approver=firstapprover and scoreresult=1 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) format time8. as ������ʱƽ������ʱЧ,
			   sum((approver=firstapprover and scoreresult=2 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t))*(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4))/sum(approver=firstapprover and scoreresult=2 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) format time8. as �м���ʱƽ������ʱЧ,
			   sum((approver=firstapprover and scoreresult=3 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t))*(approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4))/sum(approver=firstapprover and scoreresult=3 and (approvetime_update- applydate_update-returnduration1-returnduration2-returnduration3-returnduration4>"00:30:00"t)) format time8. as �߼���ʱƽ������ʱЧ
        from work.APPLY_APPROVE_RETURN_INFO
		where applyday >= 20180401
		group by applyday, approver;
run;


/**********************************************�������˲����ܱ�(ɾ��system:���հ�)**************************************/
data �������˲����ܱ�;set work.PERSONAL_APPROVAL_PRODUCTIVITY;
if approver="system" then delete;
run;

/****************************************************������ʱ��ҵ�����ܱ�********************************************/
proc sql;
	create table ��ʱ��_���� as
		select applyday,APPLYTIMEPERIOD as period,count(*) as ������
		from work.APPLY_APPROVE_RETURN_INFO
		where applyday >= 20180401
		group by applyday, APPLYTIMEPERIOD;
run;

proc sql;
	create table ��ʱ��_���� as
		select applyday,FIRSTAPPROVEPERIOD as period,count(*) as ������,
			   sum((FIRSTAPPROVETIME-applydate_update-returnduration1-returnduration2-returnduration3-returnduration4)>"00:25:00"t) as ����25m��,
			   sum((approvetime_update-applydate_update-returnduration1-returnduration2-returnduration3-returnduration4)>"00:30:00"t) as ����30m��
		from work.APPLY_APPROVE_RETURN_INFO
		where applyday>=20180401
		group by applyday, FIRSTAPPROVEPERIOD;
run;

proc sql;
	create table ��ʱ��_���� as
		select applyday,FINALAPPROVEPERIOD as period,count(*) as ������
		from work.APPLY_APPROVE_RETURN_INFO
		where applyday >= 20180401
		group by applyday,FINALAPPROVEPERIOD;
run;



            /****************************����ʱ���*************************/

data DATE;
length APPLYDAY 8;
do i = 0 to 30;
APPLYDAY = &DATE + i;
output;
end;
drop i;
run;

data TIME;
length period $18;
input period@@;
cards;
09:00 09:00:01-9:30:00 09:30:01-10:00:00 10:00:01-10:30:00 10:30:01-11:00:00 11:00:01-11:30:00 11:30:01-12:00:00
12:00:01-12:30:00 12:30:01-13:00:00 13:00:01-13:30:00 13:30:01-14:00:00 14:00:01-14:30:00 14:30:01-15:00:00
15:00:01-15:30:00 15:30:01-16:00:00 16:00:01-16:30:00 16:30:01-17:00:00 17:30:01-18:00:00 18:00:01-18:30:00
18:30:01-19:00:00 19:00:01-19:30:00 19:30:01-20:00:00 20:00:01-20:30:00 20:30:01-21:00:00 21:00
;
run;

proc sql;
create table ʱ��� as 
select * from date,time;
run;

proc sort data=��ʱ��_����;
by applyday period;
run;

proc sort data=��ʱ��_����;
by applyday period;
run;

proc sort data=��ʱ��_����;
by applyday period;
run;

proc sort data=ʱ���;
by applyday period;
run;

data ��Сʱͳ���ܱ�;
merge ʱ���(in=A)
��ʱ��_����
��ʱ��_����
��ʱ��_����;
by applyday period;
if A =1;
run;

/********************************************����T-2�µ��������********************************************/

DATA work.dps_account_info&DEDATE;
infile "/usr/sasmeta/Lev1/SASApp/DEPOSE_FIC_TEXTE/SHAREDATA/SIGNANDGO/output_sql_table_info/dps_account_info&dedate..txt" firstobs=1 ENCODING="gb2312" dlm = "|";
informat CUSTNO $16.FULLNAME $12.IDNO $18.APPLYCODE $16.ACCTNAME $12.
ACCTNO $19. BANK $3.CONTRACTNO $16.DEFPHASES $2.DIRECTDEBIT $1.
FIRSTPAYMENT $7.GUARATE $4.INITREFDATE $10.PAYACCTNOF $12.PAYACCTNOP $21.
PAYBANKF $3.PAYBANKP $3.PAYNAMEF $1.PAYNAMEP $36.PENALTYRATE $4.
PROCFEE $6.PRODUCTCODE $4.REFDATE $2.REFUNDING $32.SERVICEFEE $5.
STATUS $1.SUPPORTFEE $6.TOTALDEFPRICE $8.TOTALPRICE $8.MERCHANTID $15.
DEFDATE $10.ACCOUNTNO $16.EARLYPAYMENTDATE $23.LASTPHASES $1.NEEDUPDATE $1.
RETURNGOODSDATE $4.SPLITSTATUS $2.UPDATEDATE $23.UPDATER $15.OVERDUEDAYS $2.
DEFBALANCEF $6. DEFBALANCEP $8.ISOVERDUE $4.OPRINCIPAL $7.OPRINCIPALLF $5.
OSERVICEFEE $5.OSERVICEFEELF $4.OTOTALAMOUNT $7.OVERDUEDAYSH $2.TOTALBALANCE $8.
WFCODE $4.OVERPAID 8.RRUN 8. EPAYPRINCIPAL 8. EPAYPRINCIPALLF 8.
EPAYSERVICEFEE 8. EPAYSERVICEFEELF 8. EPAYESERVICEFEE 8. PAYPRINCIPAL 8. PAYPRINCIPALLF 8.
PAYSERVICEFEE 8.PAYSERVICEFEELF 8.RAPRINCIPAL 8.RAPRINCIPALLF 8.RASERVICEFEE 8.
RASERVICEFEELF 8.RAESERVICEFEE 8.PREACCOUNTNO $4.ISDEBITRESTR $1.POSCODE $9.
POSNAME $31.CONTRACTOPER $15.SIGNCONTRACT $23.FIRSTOVERDUEDATE $10.OVERDUEDATE $10.
OVERDUECOUNT $1.payservicefeelfn $4.;
INPUT CUSTNO FULLNAME IDNO APPLYCODE ACCTNAME
ACCTNO BANK CONTRACTNO DEFPHASES DIRECTDEBIT
FIRSTPAYMENT GUARATE INITREFDATE PAYACCTNOF PAYACCTNOP
PAYBANKF PAYBANKP PAYNAMEF PAYNAMEP PENALTYRATE
PROCFEE PRODUCTCODE REFDATE REFUNDING SERVICEFEE
STATUS SUPPORTFEE TOTALDEFPRICE TOTALPRICE MERCHANTID
DEFDATE ACCOUNTNO EARLYPAYMENTDATE LASTPHASES NEEDUPDATE
RETURNGOODSDATE SPLITSTATUS UPDATEDATE UPDATER OVERDUEDAYS
DEFBALANCEF DEFBALANCEP ISOVERDUE OPRINCIPAL OPRINCIPALLF
OSERVICEFEE OSERVICEFEELF OTOTALAMOUNT OVERDUEDAYSH TOTALBALANCE
WFCODE OVERPAID RRUN EPAYPRINCIPAL EPAYPRINCIPALLF
EPAYSERVICEFEE EPAYSERVICEFEELF EPAYESERVICEFEE PAYPRINCIPAL PAYPRINCIPALLF
PAYSERVICEFEE PAYSERVICEFEELF RAPRINCIPAL RAPRINCIPALLF RASERVICEFEE
RASERVICEFEELF RAESERVICEFEE PREACCOUNTNO ISDEBITRESTR POSCODE
POSNAME CONTRACTOPER SIGNCONTRACT FIRSTOVERDUEDATE OVERDUEDATE
OVERDUECOUNT payservicefeelfn;
run;

data STATUS;set work.dps_account_info&DEDATE;
%YMD(applycode);
if applyday>=20180201 and applyday <=20180228;
run;

proc sql;
create table DELINT_TWO as 
select distinct applyday, sum(status="1") as ������
from STATUS
group by applyday;
run;

/********************************************���********************************************/
/**********************************OUTLINE_APPLYINFO����ҳ����********************************/
/***************************************OUTLINE_RULE������***********************��***********/
/*************************************��***�������˲����ܱ�*************************************/
/*****************************************��Сʱͳ���ܱ�***************************************/
/********************************��DELINT_TWO���е����ݸ��Ƶ�T-2�µı���ȥ***********************/
