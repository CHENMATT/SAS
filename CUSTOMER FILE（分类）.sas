/*���������ڷ����ͻ�����Ʒ����*/

/*��Ҫʹ��work.dps_goods_content&day.		
	work.dps_customer_info&day.
	work.dps_apply_info&day.*/

/*������Ϣ���뱨��*/
data work.CAAPPLY;
	SET work.dps_apply_info&day.;/* approvetime_update);*/

	%datechange(applydate);
	%datechange(inputdate);
	weekday=weekday(date_update);/*�����ܼ�*/
	hour=hour_update;
	time=compress(tranwrd(substr(inputdate,1,10),"-",""))+1-1;/*����ɸѡ���������ͳ������*/

	if merchantid in (191400205399,191400201533,191400205943,8888888888888880,191400205941,888888,		
		191400206108) then store='Auchan';/*����apply���е�merchantID�ж�Ϊŷ�л���RTM*/
	else store='RTMart';

	if (status in (3,4,8) or (status in (0) and signcontract^="none")) and applycode not in ('APP2016012000002','APP2016071100018',		
	'APP2016071100019') then output;/*������Ч����*/
run;

/*��ƽ����Ʒ�۸�ʱ��ʹ��*/

/*data work.CAAPPLYaverprice; set work.CAAPPLY;
if time< 20170101 then output;
	run; /*���Ƚ���ʱ��ɸѡ*/

/*proc means data=work.CAAPPLY;
class posname;
var TOTALPRICE;
output out=work.avertotalprice;
run;*/

/*����ͻ���Ϣ��,ֻ��Ҫ���ò��Ϳͻ�������Ϣ��ϲ�*/
data work.CACUSTOMER;
	set work.dps_customer_info&day.;
run;

proc sort data=work.CACUSTOMER out=work.CACUSTOMER1;/*�������applycode���������Ա����ں������ϲ�*/
	by applycode;
run;

proc sort data=work.CAAPPLY out=work.CAAPPLY1;
	by applycode;
run;

data work.union;/*work.union�ǿͻ���Ϣ��������Ϣ�ĺϲ�������ɸѡΪ��Ч����*/
	merge work.CACUSTOMER1		
	work.CAAPPLY1(in=A);/*��work.CAAPPLY1Ϊ�����������ݺϲ���������work.CAAPPLY1û�е������򲻽��кϲ�*/
	by applycode;

	if A=1 then
		output;
run;

/*�����Ʒ��Ϣwork.dps_goods_content&day.*/
data work.CAgood;
	set work.dps_goods_content&day.;
	Nb=1+1-1;/*���ں��ڸ��������Ʒ������Ϊ�˱���һ����������������Ʒ*/
run;

proc sort data=work.CAgood out=work.CAgood1;
	by applycode;
run;

data work.CAgood2;
	set work.CAgood1;
	by applycode;
	retain Quantity; /*��ʼ��*/

	if first.applycode than Quantity=Nb;
	else Quantity=sum(Nb,Quantity);/*����ͬһ������ʱ�����в�Ʒ�����ۼ�*/
run;

/*���ݲ�ͬ��Ʒ����з���*/
data work.CAgood3;
	set work.CAgood2;

	if gatecode in (00020002,000200020001,000200020002,000200020003,000200020004) then
		product='communication';
	else if gatecode in (00010004,000100040002,000100040003) then
		product='ebike';
	else if gatecode in (00020001,000200010001,000200010002,000200010003,000200010004,000200010005,		
	000200010006,000200010007) then
		product='appliance';
	else if gatecode in (00020003,000200030001,000200030002,000200030003,000200030004,000200030005,		
		000200030006,000200030007,000200030008,000200030009,000200030010,000200030011,000200030012,000200030013,		
		000200030014,000200030015) then
		product='computer_it';
	else if gatecode in (00020005,000200050001,000200050002,000200050003,000200050004,000200050005,		
		000200050006,000200050007,000200050008,000200050009) then
		product='small_appliance';
	else if gatecode in (00020004,000200040001,000200040002,000200040003,000200040004,000200040005) then
		product='photo';
	else if gatecode in (00020006,000200060001,000200060002,000200060003,000200060004,000200060005,		
		000200060006,000200060007,000200060008,000200060009,000200060010) then
		product='sound';
	else if gatecode in (.) then
		product='nothing';
	else product='others';
run;

/*��work.union�Ͳ�Ʒ��Ϣ����кϲ�*/
proc sort data=work.union out=work.union1;
	by applycode;
run;

proc sort data=work.CAgood3 out=work.CAgoodsort;
	by applycode;
run;

data work.unionsummay;
	merge  work.union1(in=A)		
		work.CAgoodsort;
	by applycode;

	if A=1 then
		output;
run;

/*work.unionsummay���������ݺϲ��ı��*/
data work.unionsummarycal;
	set work.unionsummay; /*���в�ͬ����ķ�������*/

	if comcurrlength<3 then work_curren='_<1_3  '; /*��ҵʱ������3����*/
	else if comcurrlength<6 then
		work_curren='_<2_6';
	else if comcurrlength<12 then
		work_curren='_<3_12';
	else if comcurrlength<24 then
		work_curren='_<4_24';
	else if comcurrlength<36 then
		work_curren='_<5_36';
	else if comcurrlength<48 then
		work_curren='_<6_48';
	else if comcurrlength>=48 then
		work_curren='_>=48';

	if fmincome<6000 then fmincome2='_<1_6000  ';/*��ͥ������Ԫ*/
	else if fmincome<8000 then
		fmincome2='_<2_8000';
	else if fmincome<10000 then
		fmincome2='_<3_10000';
	else if fmincome<12000 then
		fmincome2='_<4_12000';
	else if fmincome<15000 then
		fmincome2='_<5_15000';
	else if fmincome<20000 then
		fmincome2='_<6_20000';
	else if fmincome>=20000 then
		fmincome2='_>=20000';

	if monthlyincome<3000 then monthlyincome2='_<3000 ';/*������������*/
	else if monthlyincome<3500 then
		monthlyincome2='_<3500';
	else if monthlyincome<4000 then
		monthlyincome2='_<4000';
	else if monthlyincome<4500 then
		monthlyincome2='_<4500';
	else if monthlyincome<5000 then
		monthlyincome2='_<5000';
	else if monthlyincome<8000 then
		monthlyincome2='_<8000';
	else if monthlyincome>=8000 then
		monthlyincome2='_>=8000';

	if workingexpi<5 then workingexp2='_<1_5  ';/*��������/�ܴ�ѧѧϰʱ�䣨�꣩*/
	else if workingexpi<10 then
		workingexp2='_<2_10';
	else if workingexpi<20 then
		workingexp2='_<3_20';
	else if workingexpi>=20 then
		workingexp2='_>=20';

	if age<20 then age2='_<20 '; /*����������ͳ��*/
	else if age<25 then
		age2='_<25';
	else if age<30 then
		age2='_<30';
	else if age<35 then
		age2='_<35';
	else if age<40 then
		age2='_<40';
	else if age>=40 then
		age2='_>=40';

	if merchantID=191400205790 and (currdistrict in ('����','������') or comdistrict in ('����','������')) then proximity='yes'; /*dahua*/
	else if merchantID=191400206185 and (currdistrict in ('�ռ���','�ռ�����','�ռ��ʹ�'		
			) or comdistrict in ('�ռ���','�ռ�����','�ռ��ʹ�')) then
		proximity='yes'; /*sujiatun*/
	else if merchantID=191400206183 and (currdistrict in ('����','������','������������') or comdistrict  in ('����','������','������������')) then
		proximity='yes'; /*huadu*/
	else if merchantID in (191400205399,191400201533) and (currdistrict in ('����','������') or comdistrict in ('����','������')) then
		proximity='yes'; /*Changyang*/
	else if merchantID in (191400205943,8888888888888880) and (currdistrict in ('����','������','������Ψͤ��') or comdistrict  in ('����','������','������Ψͤ��')) then
		proximity='yes'; /*Suzhou*/
	else if merchantID in (191400205941,888888) and (currdistrict in ('������','����') or comdistrict  in ('������','����')) then
		proximity='yes'; /*Wuxi*/
	else if merchantID=191400206108 and (currdistrict in ('����','������','����������') or comdistrict in ('����','������','����������')) then
		proximity='yes'; /*Nanjing*/
	else if merchantID=191400206169 and (currdistrict in ('����','������','������������','�������º���',		
	'�����������','�����������','�������͹���') or comdistrict in ('����','������','������������','�������º���',		
	'�����������','�����������','�������͹���')) then
		proximity='yes'; /*Shuyang*/
	else proximity='no';

	/*		
	        city    		
	Changyang �Ϻ���		
	Dahua �Ϻ���		
	Nanjing �Ͼ���		
	Huadu ������		
	Wuxi ������		
	sujiatun ������		
	suzhou ������		
	shuyang ��Ǩ��		
	*/
	if age<=30 then
		age3='_<=30 ';
	else age3='_>30';

	if monthlyincome<=3000 then
		monthlyincome3='_<=1_3000 ';
	else if monthlyincome<=6000 then
		monthlyincome3='_<=2_6000';
	else if monthlyincome<=10000 then
		monthlyincome3='_<=3_10000';
	else if monthlyincome>10000 then
		monthlyincome3='_>4_10000';

	if age<20 then
		age4='_<20 ';
	else if age<30 then
		age4='_<30';
	else if age<40 then
		age4='_<40';
	else if age<50 then
		age4='_<50';
	else if age<60 then
		age4='_<60';
	else if age>=60 then
		age4='_>=60';

	if monthlyincome<3000 then
		monthlyincome4='_<=1_3000 ';
	else if monthlyincome<6000 then
		monthlyincome4='_<=2_6000';
	else if monthlyincome<10000 then
		monthlyincome4='_<=3_10000';
	else if monthlyincome<15000 then
		monthlyincome4='_<=4_15000';
	else if monthlyincome>=15000 then
		monthlyincome4='_>5_15000';

	if weekday in (1,2,6,7) then
		day_week2='Fri/Sat/Sun/Mon';
	else day_week2='Tue/Thur/Wed';

	if weekday in (1,7) then
		day_week3='Weekend ';
	else day_week3='Weekday';

	if hour<12 then
		hour2=1;
	else if hour<14 then
		hour2=2;
	else if hour<16 then
		hour2=3;
	else if hour<17 then
		hour2=4;
	else if hour<18 then
		hour2=5;
	else if hour<20 then
		hour2=6;
	else hour2=7;

	if totaldefprice<=2000 then prix='_<=1_2000    '; /*��Ʒ�޹��۸�ͳ��*/
	else if totaldefprice<=2500 then
		prix='_<=2_2500';
	else if totaldefprice<=3000 then
		prix='_<=3_3000';
	else if totaldefprice<=3500 then
		prix='_<=4_3500';
	else if totaldefprice<=4000 then
		prix='_<=5_4000';
	else if totaldefprice<=4500 then
		prix='_<=6_4500';
	else if totaldefprice<=5000 then
		prix='_<=7_5000';
	else if totaldefprice<=5500 then
		prix='_<=8_5500';
	else if totaldefprice<=6000 then
		prix='_<=9_6000';
	else if totaldefprice<=6500 then
		prix='_<=10_6500';
	else if totaldefprice<=7000 then
		prix='_<=11_7000';
	else if totaldefprice<=7500 then
		prix='_<=12_7500';
	else if totaldefprice<=8000 then
		prix='_<=13_8000';
	else if totaldefprice<=10000 then
		prix='_<=14_10000';
	else prix='_>15_10000';

	if merchantid in (191400205399) then
		store2='Auchan Changyang';
	else if merchantid in (191400206185) then
		store2='RTMart Sujiatun';
	else if merchantid in (191400205790) then
		store2='RTMart Dahua';
	else if merchantid in (191400205943,8888888888888880) then
		store2='Auchan Suzhou';
	else if merchantid in (191400205941,888888) then
		store2='Auchan Wuxi';
	else if merchantid in (191400206108) then
		store2='Auchan Nanjing';
	else if merchantid in (191400206169) then
		store2='RTM Shuyang';
	else store2='RTMart Huadu';

	if status in (0,3,4) then
		decision="ACC";
	ELSE decision="REF";

	if time <20180401 /*and store2=/*"Auchan Changyang""RTMart Sujiatun" "RTMart Dahua" "Auchan Suzhou" /*"Auchan Wuxi"*/

	/*"RTM Shuyang"*/
	/*"RTMart Huadu" "Auchan Nanjing"*/
	then output;  /*ѡ��ͳ�����ڼ��ŵ�*/
run;

proc sql;
	create table work.database as 		
		select		
			decision,		
			store,		
			store2,		
			proximity,		
			product,		
			DEFPHASES,		
			hour,		
			hour2,		
			weekday,		
			day_week2,		
			day_week3,		
			HASCREDITCARD,		
			MARITALSTATUS,		
			EDULEVEL,		
			GENDER,		
			WORKSTATUS,		
			INDUSTRY,		
			CURRISSAMEREG,		
			HOUSESTATUS,		
			fmincome2,		
			monthlyincome2,		
			monthlyincome3,		
			monthlyincome4,		
			age2,		
			age3,		
			age4,		
			work_curren,		
			workingexp2,		
			prix,		
			quantity,		
			nb,		
			PRICE		
		from work.unionsummarycal;
quit;

run;