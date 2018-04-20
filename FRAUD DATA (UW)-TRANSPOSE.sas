
data work.fraud_data;
	set work.dps_customer_info&day.(Keep= applycode fullname MOBILE COMPROV
		COMCITY
		COMDISTRICT
		COMROAD
		COMPANYNAME Comaddress reprov RECITY redistrict reroad CURRCITY CURRDISTRICT CURRADDRESS FIXEDPHONE
		FMNAME FMPHONE OCNAME OCPHONE SPOUSENAME SPOUSEMOBILE HOMEPHONE workstatus sesamescore);
run;

proc sql;
	create table work.fraud_data as
		select applycode, fullname,MOBILE,COMPANYNAME,COMPROV,COMCITY,COMDISTRICT,COMROAD,comaddress,reprov,RECITY,redistrict,reroad,CURRCITY,CURRDISTRICT,CURRADDRESS,FIXEDPHONE,FMNAME,FMPHONE,SPOUSENAME,SPOUSEMOBILE,OCNAME,OCPHONE,SPOUSENAME,SPOUSEMOBILE,HOMEPHONE,workstatus,sesamescore
			from work.fraud_data;
quit;

Proc sort data= work.fraud_data out= work.fraud_data1;
	by applycode;
run;

DATA work.apply1;
	set work.dps_apply_info&day.(keep=applycode bank salesgrade posname status approver);
run;

proc sort data=work.apply1 out=work.apply2;
	by applycode;
run;

data work.fraud_data_update;
	merge work.fraud_data1
		work.apply2;
	by applycode;
run;

proc sql;
	create table work.fraud_data_updateF as
		select applycode,fullname,MOBILE,COMPANYNAME,COMPROV,COMCITY,COMDISTRICT,COMROAD,comaddress,reprov,RECITY,redistrict,reroad,CURRCITY,CURRDISTRICT,CURRADDRESS,FIXEDPHONE,POSNAME,FMNAME,FMPHONE,SPOUSENAME,SPOUSEMOBILE,OCNAME,OCPHONE,SPOUSENAME,SPOUSEMOBILE,HOMEPHONE,STATUS,salesgrade,bank,workstatus,sesamescore,approver
			from work.fraud_data_update;
quit;

/*work.fraud_data_updateFΪ���յĽ��������˱���*/
/*��ԭ�б�������FDS����*/

/*data work.apply; set work.dps_apply_info&day.(keep=applycode inputer);
run;

proc sort data=work.apply out=work.apply1;
by applycode;
run;

proc sort data=work.fraud_data_updateF out=work.fraud_data_updateFF;
by applycode;
run;

data work.fraud_data_updateFF1;
merge work.apply1
work.fraud_data_updateFF;
by applycode;
run;

/*����code����Ϊ��ʱ���󣬲���Ҫ����*/

/*��ԭ�б�Ļ��������Ӱ����ȼ�,����ʱ��,������Ա*/
data work.apply;
	set work.dps_apply_info&day.(keep=applycode inputer scoreresult);
run;

proc sort data=work.apply out=work.apply1;
	by applycode;
run;

proc sort data=work.fraud_data_updateF out=work.fraud_data_updateFF;
	by applycode;
run;

/*���������˲��ܱ��г�������г�firstduration*/
data work.firstduration;
	set work.summarytbaleA(keep=applycode firapprovetime_update applydate_update firstapprover);
	Firstduration=firapprovetime_update - applydate_update;
	format firstduration time8.;
run;

proc sort data=work.firstduration out=work.firstduration1;
	by applycode;
run;

data work.fraud_data_updateFF1;
	merge work.apply1
		work.fraud_data_updateFF
		work.firstduration1(drop=applydate_update firapprovetime_update);
	by applycode;
run;

proc sort data=work.fraud_data_updateFF1 out=work.fraud_data_updateFFF nodupkey;
	by applycode;
run;

/*work.summarytablec���Ѿ�����ɸѡ������,Ҫ��ԭ�����ҳ���/

/*work.fraud_data_updateFF2�����ݵ�������*/

/*��ʱ��������������>30��ļ�¼*/
DATA work.FDOVERDUE;
	SET work.ACCT_OVERDUE_DETAILS&day.(keep=overduedays contractno);  /*�������ݴ���*/

	IF overduedays>30 then ����=">=M2"; /*�������ڼ�¼>=M2�ļ�¼*/

		if ����=">=M2" then
			output;
run;

proc sort data=work.fdoverdue out=work.fdoverdue1 nodupkey;/*ȥ��*/
	by contractno;
run;

data work.fdapply;
	set work.dps_apply_info&day.(keep=applycode contractno);
run;

proc sort data=work.fdapply out=work.fdapply1;
	by contractno;
run;

data work.overdueapp;
	merge work.fdoverdue1(in=A)
		work.fdapply1;
	by contractno;

	if A=1 then
		output;
run;

data work.summaryoverdue;/*Ϊ������������һ��applycode������֮���Fraud�ϲ�*/
	merge work.overdueapp
		work.fdoverdue1;
	by contractno;
run;

/*��work.summaryoverdue������work.fraud_data_updateFF2��ԭ��Fraud���ݣ�����applycode�ϲ�*/

/*proc sort data=work.summaryoverdue out=work.summaryoverdue1;
by applycode;
run;

proc sort data=work.fraud_data_updateFF2 out=work.fraud_data_updateFF3;
by applycode;
run;

data work.summaryoverueF;
merge work.fraud_data_updateFF3(in=B) 
	work.summaryoverdue1(KEEP=APPLYCODE ����);
by applycode;

if B=1 then
		output;
run;*/
data work.finalapprover;
	set work.finalappro&day.(keep=applycode approver);/*����*/
run;

proc sort data=work.finalapprover out=work.finalapprover2(rename=(approver=finalapprover));
	by applycode;

proc sort data= work.fraud_data_updateFFF out=work.fraud_data_updateFFF1;
	by applycode;
run;

data work.fraud_data_updateFF9;
	merge work.fraud_data_updateFFF1
		work.finalapprover2;
	by applycode;
run;

/*����work.summaryoverueF����*/
PROC SORT DATA=work.fraud_data_updateFF9 OUT=work.fraud_data_updateFF2 NODUPKEY;
	by applycode;
RUN;

/*���ս������work.fraud_data_updateFF2 ����*/

proc sort data=dps_goods_content&day.;
by applycode;
run;

proc sort data=work.fraud_data_updateFF2;
by applycode;
run;

data work.fraud_datacom;
merge dps_goods_content&day.(keep=applycode category1st category2nd category3rd brand model) 
      fraud_data_updateFF2(in=A);
by applycode;
if A=1 then output;
run;


proc sort data=work.dps_apply_info&day.;
by applycode;
run;

proc sort data=work.fraud_datacom;
by applycode;
run;

data work.fraud_datacomtemp;
merge dps_apply_info&day.(keep=applycode applydate) 
      work.fraud_datacom(in=A);
by applycode;
if applydate = "none" then applyday = input(substr(applycode,4,8),8.);
else if applydate = " " then applyday = input(substr(applycode,4,8),8.);
else applyday = input(compress(substr(applydate,1,10),"-"),8.);
if A=1 then output;
run;

proc sql;
    create table fraud_data_UWLtill&lastmonth. as
      select APPLYCODE, INPUTER, SCORERESULT, FULLNAME, MOBILE, COMPANYNAME, COMPROV, COMCITY, COMDISTRICT, 
             COMROAD, COMADDRESS, REPROV, RECITY, REDISTRICT, REROAD, CURRCITY, CURRDISTRICT, CURRADDRESS, 
             FIXEDPHONE, POSNAME, FMNAME, FMPHONE, SPOUSENAME, SPOUSEMOBILE, OCNAME, OCPHONE, HOMEPHONE, 
             STATUS, SALESGRADE, BANK, WORKSTATUS, SESAMESCORE, APPROVER, firstapprover, Firstduration, 
             finalapprover, brand, category1st, category2nd, category3rd, model
     from work.fraud_datacomtemp where applyday <= &lastmonthenddate.;
run;

proc sql;
    create table fraud_data_UWL as
      select APPLYCODE, INPUTER, SCORERESULT, FULLNAME, MOBILE, COMPANYNAME, COMPROV, COMCITY, COMDISTRICT, 
             COMROAD, COMADDRESS, REPROV, RECITY, REDISTRICT, REROAD, CURRCITY, CURRDISTRICT, CURRADDRESS, 
             FIXEDPHONE, POSNAME, FMNAME, FMPHONE, SPOUSENAME, SPOUSEMOBILE, OCNAME, OCPHONE, HOMEPHONE, 
             STATUS, SALESGRADE, BANK, WORKSTATUS, SESAMESCORE, APPROVER, firstapprover, Firstduration, 
             finalapprover, brand, category1st, category2nd, category3rd, model
     from work.fraud_datacomtemp where applyday >= &thismonthbegdate.;
run;

data fraud_data_UWLTILLLASTMONTHTRA;set fraud_data_UWLtill&lastmonth.;
   value=brand;
   output;
   value=category1st;
   output;
   value=category2nd;
   output;
   value=category3rd;
   output;
   value=model;
   output;
   if applycode="APP2016111900003" and model="none" then delete;
/*   drop brand category1st category2nd category3rd model;*/
run; 

data fraud_data_UWLTILLLASTMONTHTRANS;set fraud_data_UWLTILLLASTMONTHTRA;
   if applycode="APP2016111900003" and model="none" then delete;
   drop brand category1st category2nd category3rd model;
run; 



data fraud_data_UWLTRANS;set fraud_data_UWL;
   value=brand;
   output;
   value=category1st;
   output;
   value=category2nd;
   output;
   value=category3rd;
   output;
   value=model;
   output;
   drop brand category1st category2nd category3rd model;
run; 

proc transpose data=fraud_data_UWLTILLLASTMONTHTRANS out=fraud_data_UWLTILLLASTMONTHTRF(drop=_NAME_ 
					rename=(COL1=P1brand COL2=P1category1st COL3=P1category2nd COL4=P1category3rd COL5=P1model
  							COL6=P2brand COL7=P2category1st COL8=P2category2nd COL9=P2category3rd COL10=P2model));
   by APPLYCODE INPUTER SCORERESULT FULLNAME MOBILE COMPANYNAME COMPROV COMCITY COMDISTRICT  
             COMROAD COMADDRESS REPROV RECITY REDISTRICT  REROAD  CURRCITY  CURRDISTRICT  CURRADDRESS  
             FIXEDPHONE  POSNAME  FMNAME  FMPHONE  SPOUSENAME  SPOUSEMOBILE  OCNAME  OCPHONE  HOMEPHONE  
             STATUS  SALESGRADE  BANK  WORKSTATUS  SESAMESCORE  APPROVER  firstapprover  Firstduration  
             finalapprover;
   var value;
run; 

proc transpose data=fraud_data_UWLTRANS out=fraud_data_UWLTRANSPOSE(drop=_NAME_ 
					rename=(COL1=P1brand COL2=P1category1st COL3=P1category2nd COL4=P1category3rd COL5=P1model
  							COL6=P2brand COL7=P2category1st COL8=P2category2nd COL9=P2category3rd COL10=P2model));
   by APPLYCODE INPUTER SCORERESULT FULLNAME MOBILE COMPANYNAME COMPROV COMCITY COMDISTRICT  
             COMROAD COMADDRESS REPROV RECITY REDISTRICT  REROAD  CURRCITY  CURRDISTRICT  CURRADDRESS  
             FIXEDPHONE  POSNAME  FMNAME  FMPHONE  SPOUSENAME  SPOUSEMOBILE  OCNAME  OCPHONE  HOMEPHONE  
             STATUS  SALESGRADE  BANK  WORKSTATUS  SESAMESCORE  APPROVER  firstapprover  Firstduration  
             finalapprover;
   var value;
run; 

data fraud_data_UWLF;set fraud_data_UWLTRANSPOSE;
	array NONEREPLACE _character_;
        do over NONEREPLACE;
                if NONEREPLACE="none" then NONEREPLACE="";
        end;
run;

data fraud_data_UWLF;set fraud_data_UWLTILLLASTMONTHTRF;
	array NONEREPLACE _character_;
        do over NONEREPLACE;
                if NONEREPLACE="none" then NONEREPLACE="";
        end;
run;

/************************�������***************************
***********���� �������ݣ�fraud_data_UWLTRANSPOSE************
***********���� �������ݣ�fraud_data_UWLTILLLASTMONTHTRF****/