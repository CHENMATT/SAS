


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

/************************导出结果***************************
***********导出 当月数据：fraud_data_UWLTRANSPOSE************
***********导出 总量数据：fraud_data_UWLTILLLASTMONTHTRF****/
