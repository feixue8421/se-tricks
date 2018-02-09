-- redo in sql select
with cal as (select substr(calname, 0, instr(calname, '-') - 1) as deviceid,
decode(dayofweek, 1,'1',2,'2',4,'3',8,'4',16,'5',32,'6',64,'7','-1') as dweek,
to_number(substr(period, 1, 2)) * 60 + to_number(substr(period, 3, 2)) as beginoffset,
to_number(substr(period, 5, 2)) * 60 + to_number(substr(period, 7, 2)) as endoffset
from calendar where type = 1),
val as ( select datepoint, to_char(datepoint,'DAY', 'NLS_DATE_LANGUAGE=''numeric date language''') as dweek from (select trunc(sysdate - 90 + level - 2) as datepoint from dual connect by level < 60))
,devcal as (select cal.deviceid, val.datepoint + cal.beginoffset/24/60 as begindate, val.datepoint + cal.endoffset/24/60 as stopdate from cal join val on cal.dweek = val.dweek)
,devexc as (select deviceid, stopdate as started, lead(begindate, 1, begindate) over (partition by deviceid order by deviceid, begindate) as stoped from devcal)
, devminmax as (select deviceid, min(begindate) as minbegin, max(stopdate) as maxstop from devcal group by deviceid),
findevcal as (
select * from devexc where started < stoped
union all
select deviceid, sysdate as started, minbegin as stoped from devminmax where sysdate < minbegin
union all
select deviceid, maxstop as started, sysdate as stoped from devminmax where maxstop > sysdate
union all
select deviceid, started, nvl(ended, sysdate) as stoped from deviceenable where started < sysdate + 30 and nvl(ended, sysdate) > sysdate - 1
)
select * from findevcal;


create or replace function checkdevicecalendar(pdeviceid in char, pchecked in date) return boolean as
type SPECIALS IS VARRAY(10) OF date;
specialday SPECIALS := SPECIALS();
counter number := 0;
checkedpoint date := trunc(pchecked);
begin
  select count(1) into counter from viewcalender where deviceid = pdeviceid;
  if counter = 0 then
    return true;
  end if;

  for cal in (select datepoint, beginoffset, endoffset from viewcalender where deviceid = pdeviceid and dweek = '-1') loop
    if pchecked >= cal.datepoint + cal.beginoffset / 24 / 60 and pchecked <= cal.datepoint + cal.endoffset / 24 / 60 then
      return true;
    end if;

    specialday.extend;
    specialday(specialday.count) := cal.datepoint;
  end loop;

  for cal in (select dweek, beginoffset, endoffset from viewcalender where deviceid = pdeviceid and dweek <> '-1') loop
    if pchecked member of specialday then
      continue;
    end if;

    if to_char(pchecked,'DAY', 'NLS_DATE_LANGUAGE=''numeric date language''') = cal.dweek
      and pchecked >= trunc(pchecked) + cal.beginoffset / 24 / 60 and pchecked <= trunc(pchecked) + cal.endoffset / 24 / 60 then
      return true;
    end if;
  end loop;

  return false;
end checkdevicecalendar;
/



create or replace function isvalidminute(pdeviceid in char, pchecked in date) return number as
begin
  if checkdeviceenable(pdeviceid, pchecked) and checkdevicecalendar(pdeviceid, pchecked) then
    return 1;
    end if;

    return 0;
end isvalidminute;
/


create or replace function calcvalidinterval(pdeviceid in char, pstarted in date, pended in date) return number
as
total number := 0;
begin
    select count(isvalidminute(pdeviceid, pstarted + (level - 1) / 24 / 60)) into total from dual connect by level <= floor(TO_NUMBER(pended - pstarted) * 24 * 60) + 1;
    return total;
end calcvalidinterval;
/




-- CHECK MINUTE ONE BY ONE



CREATE OR REPLACE VIEW viewcalendar as
  select substr(calname, 0, instr(calname, '-') - 1) as deviceid,
  decode(dayofweek, 1,'1',2,'2',4,'3',8,'4',16,'5',32,'6',64,'7','-1') as dweek,
  to_number(substr(period, 1, 2)) * 60 + to_number(substr(period, 3, 2)) as beginoffset,
  to_number(substr(period, 5, 2)) * 60 + to_number(substr(period, 7, 2)) as endoffset,
  trunc(day) as datepoint
  from calendar;



create or replace function checkdeviceenable(pdeviceid in char, pchecked in date) return boolean as
counter number := 0;
begin
  select count(1) into counter from deviceenable where deviceid = pdeviceid and pchecked between started and nvl(ended, sysdate);
  return counter = 0;
end checkdeviceenable;

create or replace function checkdevicecalendar(pdeviceid in char, pchecked in date) return boolean as
type SPECIALS IS VARRAY(10) OF date;
specialdays SPECIALS := SPECIALS();
counter number := 0;
begin
  select count(1) into counter from viewcalendar where deviceid = pdeviceid;
  if counter = 0 then
    return true;
  end if;

  for cal in (select datepoint, beginoffset, endoffset from viewcalender where calname = pdeviceid and type = 2) loop
    if pchecked >= cal.datepoint + cal.beginoffset / 24 / 60 and pchecked <= cal.datepoint + cal.endoffset / 24 / 60 then
      return true;
    end if;

    specialday.extend;
    specialday(specialday.count) := cal.datepoint;
  end loop;

  for cal in (select dweek, beginoffset, endoffset from viewcalender where calname = pdeviceid and type = 1) loop
    if trunc(pchecked) member of specialday then
      continue;
    end if;

    if to_char(pchecked,'DAY', 'NLS_DATE_LANGUAGE=''numeric date language''') = cal.dweek
      and pchecked >= trunc(pchecked) + cal.beginoffset / 24 / 60 and pchecked <= trunc(pchecked) + cal.endoffset / 24 / 60 then
      return true;
    end if;
  end loop;

  return false;
end checkdevicecalendar;


create or replace function isvalidminute(pdeviceid in char, pchecked in date) return boolean as
begin
  return checkdeviceenable(pdeviceid, pchecked) and checkdevicecalendar(pdeviceid, pchecked);
end isvalidminute;

create or replace function calcvalidinterval(pdeviceid in char, pstarted in date, pended in date) return number
as
total number := 0;
begin
    select count(1) into total from dual connect by level <= floor(TO_NUMBER(pended - pstarted) * 24 * 60) + 1 where isvalidminute(pstarted + (level - 1) / 24 / 60);
    return pcounter;
end calcvalidinterval;
/



-- ERROR BACKUP
drop function calcservicedateregion;
drop function calcdevservicedate;
drop function excludedateregion;
drop package pvpkg;
drop type devdateregionrecord;
/

create type devdateregionrecord AS object (deviceid char(16), started date, ended date);
/

create type devdateregiontable AS  table of  devdateregionrecord;
/


CREATE PACKAGE pvpkg IS
  type datetable IS table of devdateregionrecord INDEX BY BINARY_INTEGER;
  TYPE refregioncursor IS REF CURSOR;
END pvpkg;
/

create or replace function excludedateregion(daterecord in devdateregionrecord, tgtstarted in date, tgtended in date) return devdateregiontable pipelined as
begin
    if daterecord.started < tgtended and daterecord.ended > tgtstarted then
        if daterecord.tarted < tgtstarted then
            pipe row (devdateregionrecord(daterecord.deviceid, daterecord.started, tgtstarted));
        end if;

        if tgtended < daterecord.ended then
            pipe row (devdateregionrecord(daterecord.deviceid, tgtended, daterecord.ended));
        end if;

        return;
    end if;

    pipe row (daterecord);
    return;
end excludedateregion;
/

create function calcdevservicedate(regioncursor in pvpkg.refregioncursor, tgtstarted in date, tgtended in date) return devdateregiontable pipelined as
begin
    for devdate in regioncursor loop
        for validregion in (select * from table(excludedateregion(devdate, tgtstarted, tgtended))) loop
          pipe row (validregion);
        end loop;
    end loop;
    return;
end calcdevservicedate;
/

create function calcservicedate(servicecursor in pvpkg.refregioncursor, excludecursor in pvpkg.refregioncursor) return pvpkg.datetable
as
  result out pvpkg.datetable;
  tempinput pvpkg.datetable;
  tempoutput pvpkg.datetable;
  idx BINARY_INTEGER;
begin
  idx := 0;
  for sdate in servicecursor loop
    idx := idx + 1;
    tempinput(idx) := sdate;
  end loop;

  for xdate in excludecursor loop
    idx := 0;
    for vdate in (select * from table(calcdevservicedate(CURSOR(select * from table(tempinput)), xdate.started, xdate.ended))) loop
      idx := idx + 1;
      tempoutput(idx) := vdate;
    end loop;

    tempinput := tempoutput;
    tempoutput.delete;
  end loop;

  result := tempinput;
  return result;
end calcservicedate;
/




-- ERROR BACKUP

drop function calcservicedateregion;
drop function calcdevservicedate;
drop function excludedateregion;
drop package pvpkg;
drop type devdateregionrecord;
drop type devdateregiontable;
/

create type devdateregionrecord as object (deviceid char(16), started date, ended date);
/

create type devdateregiontable as table of devdateregionrecord INDEX BY BINARY_INTEGER;
/

CREATE PACKAGE pvpkg IS
  TYPE refregioncursor IS REF CURSOR RETURN devdateregionrecord;
END pvpkg;
/

create function excludedateregion(daterecord in devdateregionrecord, tgtstarted in date, tgtended in date) return devdateregiontable pipelined as
begin
    if daterecord.started < tgtended and daterecord.ended > tgtstarted then
        if daterecord.tarted < tgtstarted then
            pipe row (devdateregionrecord(daterecord.deviceid, daterecord.started, tgtstarted));
        end if;

        if tgtended < daterecord.ended then
            pipe row (devdateregionrecord(daterecord.deviceid, tgtended, daterecord.ended));
        end if;

        return;
    end if;

    pipe row (daterecord);
    return;
end excludedateregion;
/

create function calcdevservicedate(regioncursor in pvpkg.refregioncursor, tgtstarted in date, tgtended in date) return devdateregiontable pipelined as
begin
    for devdate in regioncursor loop
        for validregion in (select * from table(excludedateregion(devdate, tgtstarted, tgtended))) loop
          pipe row (validregion);
        end loop;
    end loop;
    return;
end calcdevservicedate;
/

create function calcservicedate(servicecursor in pvpkg.refregioncursor, excludecursor in pvpkg.refregioncursor) return devdateregiontable
as
  result out devdateregiontable;
  tempinput devdateregiontable;
  tempoutput devdateregiontable;
  idx BINARY_INTEGER;
begin
  idx := 0;
  for sdate in servicecursor loop
    idx := idx + 1;
    tempinput(idx) := sdate;
  end loop;

  for xdate in excludecursor loop
    idx := 0;
    for vdate in (select * from table(calcdevservicedate(CURSOR(select * from table(tempinput)), xdate.started, xdate.ended))) loop
      idx := idx + 1;
      tempoutput(idx) := vdate;
    end loop;

    tempinput := tempoutput;
    tempoutput.delete;
  end loop;

  result := tempinput;
  return result;
end calcservicedate;
/



-- ERROR BACKUP
drop function excludedateregion;
drop type dateregion;
drop type dateregion_;
/

create type dateregion_ as object (started date, ended date);
/

create type dateregion as table of dateregion_;
/

create function excludedateregion(orgstarted in date, orgended in date, tgtstarted in date, tgtended in date) return dateregion pipelined as
begin
    if orgstarted < tgtended and orgended > tgtstarted then
        if orgstarted < tgtstarted then
            pipe row (dateregion_(orgstarted, tgtstarted));
        end if;

        if tgtended < orgended then
            pipe row (dateregion_(tgtended, orgended));
        end if;

        return;
    end if;

    pipe row (dateregion_(orgstarted, orgended));
    return;
end excludedateregion;
/

drop function calcservicedate;
drop type devdateregion;
drop type devdateregion_;
/


create type devdateregion_ as object (deviceid char(16), started date, ended date);
/

create type devdateregion as table of devdateregion_;
/

create function calcservicedate(servicedate in devdateregion, reportdate in devdateregion) return devdateregion
as
result out devdateregion;
tempresult devdateregion;
firstflag int;
begin
    firstflag := 1;

    for rdate in reportdate.first .. reportdate.last loop
      if firstflag = 1 then
        for sdate in servicedate loop
          select sdate.deviceid, * into tempresult from table(excludedateregion(sdate.started, sdate.ended, rdate.started, rdate.ended));
        end loop;
      else
        for sdate in result loop
          select sdate.deviceid, * into tempresult from table(excludedateregion(sdate.started, sdate.ended, rdate.started, rdate.ended));
        end loop;
      end if;

      result := tempresult;

      firstflag := 0
    end loop;

    return result;
end calcservicedate;
/



-- UPDATE
create or replace type dateregion_ as object (started date, ended date);
/

create or replace type dateregion as table of dateregion_;
/

create or replace function excludedateregion(orgstarted in date, orgended in date, tgtstarted in date, tgtended in date) return dateregion pipelined
as
obj dateregion_;
begin
    if orgstarted < tgtended and orgended > tgtstarted then
        if orgstarted < tgtstarted then
            obj := dateregion_(orgstarted, tgtstarted);
            pipe row (obj);
        end if;

        if tgtended < orgended then
            obj := dateregion_(tgtended, orgended);
            pipe row (obj);
        end if;

        return;
    end if;

    obj := dateregion_(orgstarted, orgended);
    pipe row (obj);
    return;
end excludedateregion;
/




-- UPDATE
create or replace type dateregion_ as object (started date, ended date);
/

create or replace type dateregion as table of dateregion_;
/

create or replace function excludedateregion(orgstarted in date, orgended in date, tgtstarted in date, tgtended in date) return dateregion
as
result dateregion := dateregion();
idx int := 1;
begin
    if orgstarted < tgtended and orgended > tgtstarted then
        if orgstarted < tgtstarted then
            result.extend();
            result(idx) := dateregion_(orgstarted, tgtstarted);
            idx := idx + 1;
        end if;

        if tgtended < orgended then
            result.extend();
            result(idx) := dateregion_(tgtended, orgended);
            idx := idx + 1;
        end if;
        return result;
    end if;

    result.extend();
    result(idx) := dateregion_(orgstarted, orgended);
    return result;
end excludedateregion;
/



-- UPDATE
create or replace type _dateregion as object (started date, ended date);
create or replace type dateregion as table of _dateregion;
create or replace function excludedateregion(orgstarted in date, orgended in date, tgtstarted in date, tgtended in date) return dateregion
as
result dateregion := dateregion();
index int := 1;
begin
    if orgstarted < tgtended and orgended > tgtstarted then
        if orgstarted < tgtstarted then
            result.extend();
            result(index) := _dateregion(orgstarted, tgtstarted);
            index := index + 1
        end if;

        if tgtended < orgended then
            result.extend();
            result(index) := _dateregion(tgtended, orgended);
            index := index + 1
        end if;
        return result;
    end if;

    result.extend();
    result(index) := _dateregion(orgstarted, orgended);
    return result;
end excludedateregion;



with cal as (select substr(calname, 0, instr(calname, '-') - 1) as deviceid,
decode(dayofweek, 1,'1',2,'2',4,'3',8,'4',16,'5',32,'6',64,'7','-1') as dweek,
to_number(substr(period, 1, 2)) * 60 + to_number(substr(period, 3, 2)) as beginoffset,
to_number(substr(period, 5, 2)) * 60 + to_number(substr(period, 7, 2)) as endoffset
from calendar where type = 1),
val as ( select datepoint, to_char(datepoint,'DAY', 'NLS_DATE_LANGUAGE=''numeric date language''') as dweek from (select trunc(sysdate - 90 + level - 2) as datepoint from dual connect by level < 60)),
endev as (select rtrim(deviceid) as deviceid, started, ended from deviceenable where started > sysdate - 90)
select cal.deviceid, val.datepoint + cal.beginoffset/24/60 as begindate, val.datepoint + cal.endoffset/24/60 as stopdate,
endev.started, endev.ended
from cal join val on cal.dweek = val.dweek left join endev on cal.deviceid = endev.deviceid;


with cal as (select substr(calname, 0, instr(calname, '-') - 1) as deviceid,
substr(calname, instr(calname, '-') + 1) as calname,
decode(dayofweek, 1,'1',2,'2',4,'3',8,'4',16,'5',32,'6',64,'0','-1') as dweek,
to_number(substr(period, 1, 2)) * 60 + to_number(substr(period, 3, 2)) as beginoffset,
to_number(substr(period, 5, 2)) * 60 + to_number(substr(period, 7, 2)) as stopoffset
from calendar where type = 1 and calname like '%001%'),
val as ( select trunc(sysdate + level - 1) as datepoint from dual connect by level < 10)
select cal.deviceid, cal.calname, val.datepoint + cal.beginoffset/24/60 as begindate, val.datepoint + cal.stopoffset/24/60 as stopdate
from cal join val on to_char(val.datepoint,'DAY', 'NLS_DATE_LANGUAGE=''numeric date language''') = cal.dweek



with cal as (select substr(calname, 0, instr(calname, '-') - 1) as deviceid,
decode(dayofweek, 1,'1',2,'2',4,'3',8,'4',16,'5',32,'6',64,'7','-1') as dweek,
to_number(substr(period, 1, 2)) * 60 + to_number(substr(period, 3, 2)) as beginoffset,
to_number(substr(period, 5, 2)) * 60 + to_number(substr(period, 7, 2)) as endoffset
from calendar where type = 1),
val as ( select datepoint, to_char(datepoint,'DAY', 'NLS_DATE_LANGUAGE=''numeric date language''') as dweek from (select trunc(sysdate + level - 2) as datepoint from dual connect by level < 30))
select cal.deviceid, val.datepoint + cal.beginoffset/24/60 as begindate, val.datepoint + cal.endoffset/24/60 as stopdate
from cal join val on cal.dweek = val.dweek order by deviceid, begindate;