%StoreFdsFormat
data dps_apply_info; set dps_apply_info&day.;
%datechange(applydate)
%datechange(inputdate)
%PosnameFds_E(POSNAME,INPUTER)
%YMD(applycode)
if applymonth=201804 and (status= 3 or status=4 or status =8 or (status=0 and applydate^="none"));
run;

proc sql;
create table APPLYDAY as 
select applyday, count(*) as TOT_APP, sum(status = 4) as CON_APP, sum(status = 4)/count(*) as RATE format percent8.2 from dps_apply_info
group by applyday;
run;


proc sql;
create table FDS_E as 
select FDS_E, count(*) as TOT_APP, sum(status = 4) as CON_APP, sum(status = 4)/count(*) as RATE format percent8.2 from dps_apply_info
group by FDS_E;
run;

proc sql;
create table STORE as 
select POSNAME, count(*) as TOT_APP, sum(status = 4) as CON_APP, sum(status = 4)/count(*) as RATE format percent8.2 from dps_apply_info
group by POSNAME;
run;

proc sql;
create table TOT as 
select count(*) as TOT_APP, sum(status = 4) as CON_APP, sum(status = 4)/count(*) as RATE format percent8.2 from dps_apply_info;
run;

proc print data=work.APPLYDAY;
	title 'S&G APPLICATION BY APPLYDAY';
run;

proc print data=work.FDS_E;
	title 'S&G APPLICATION BY SALES';
run;

proc print data=work.STORE;
	title 'S&G APPLICATION BY STORES';
run;

proc print data=work.TOT;
	title 'S&G APPLICATION IN TOTAL';
run;
