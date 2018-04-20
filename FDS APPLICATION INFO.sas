%StoreFdsFormat
data dps_apply_info;
set dps_apply_info&day.;
%datechange(applydate)
%datechange(inputdate)
%PosnameFds_E(POSNAME,INPUTER)
%YMD(applycode);
input_minutes=applydate_update - inputdate_update;
format input_minutes time8.;
if status= 3 or status=4 or status =8 or (status=0 and applydate^="none");
run;

data work.appbymonth;
	set work.dps_apply_info;
	if applymonth=201804;
run;

proc sql;
	create table work.finalresult as
		select 
			applycode,
			inputdate,
			input_minutes,
			inputer,
			totalprice,
			status,
			FDS_E
		from work.appbymonth;
quit;

run;

%SORT(applycode)


