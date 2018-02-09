create or replace 
PROCEDURE insertDeviceJournalEntry(
    par_device IN journalstate.deviceid%TYPE,
    par_entrytype IN journal.entrytype%TYPE,
    par_entrytime IN journalstate.entrytime%TYPE,
    par_pan IN journal.PAN%TYPE,
    par_orgentrytype IN journal.orgentrytype%type,
    par_orgentry IN journal.orgentry%TYPE,
    par_id IN journal.ID%TYPE,
    par_currententrycount IN journal.entrycount%TYPE,
    par_nodetails IN INTEGER,   
    par_orgkeyname1 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber1 IN journaldetail.fieldnumber%TYPE,
    par_valuetype1 IN journaldetail.valuetype%TYPE,
    par_value1 IN journaldetail.value%TYPE,
    par_orgkeyname2 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber2 IN journaldetail.fieldnumber%TYPE,
    par_valuetype2 IN journaldetail.valuetype%TYPE,
    par_value2 IN journaldetail.value%TYPE,
    par_orgkeyname3  IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber3  IN journaldetail.fieldnumber%TYPE,
    par_valuetype3 IN journaldetail.valuetype%TYPE,
    par_value3 IN journaldetail.value%TYPE,
    par_orgkeyname4 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber4 IN journaldetail.fieldnumber%TYPE,
    par_valuetype4  IN journaldetail.valuetype%TYPE,
    par_value4 IN journaldetail.value%TYPE,
    par_orgkeyname5 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber5 IN journaldetail.fieldnumber%TYPE,
    par_valuetype5 IN journaldetail.valuetype%TYPE,
    par_value5 IN journaldetail.value%TYPE,
    par_orgkeyname6 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber6 IN journaldetail.fieldnumber%TYPE,
    par_valuetype6 IN journaldetail.valuetype%TYPE,
    par_value6 IN journaldetail.value%TYPE,
    par_orgkeyname7 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber7 IN journaldetail.fieldnumber%TYPE,
    par_valuetype7 IN journaldetail.valuetype%TYPE,
    par_value7 journaldetail.value%TYPE,
    par_orgkeyname8 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber8 IN journaldetail.fieldnumber%TYPE,
    par_valuetype8 IN journaldetail.valuetype%TYPE,
    par_value8 journaldetail.value%TYPE,
    par_orgkeyname9 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber9 IN journaldetail.fieldnumber%TYPE,
    par_valuetype9 IN journaldetail.valuetype%TYPE,
    par_value9 journaldetail.value%TYPE,     
    par_orgkeyname10 IN journaldetail.orgkeyname%TYPE,
    par_fieldnumber10 IN journaldetail.fieldnumber%TYPE,
    par_valuetype10 IN journaldetail.valuetype%TYPE,
    par_value10 IN journaldetail.value%TYPE, 
    par_newentrycount OUT INTEGER,
    par_alreadyInDatabase OUT INTEGER,
    par_daychange OUT INTEGER,
    par_lastentrytime OUT DATE)
IS
     iId INTEGER;
     lastentrytime DATE;
     iEntrycount INTEGER;
	 amount DECIMAL(18,6);
     result VARCHAR2(50);
	 TYPE ITEMSARRAY IS VARRAY(50) OF VARCHAR2(80 CHAR);
	 items ITEMSARRAY;
	 sqltxndetail VARCHAR2(8000 CHAR);
	 TYPE VARSRECORD IS RECORD (orgkeyname journaldetail.orgkeyname%TYPE, fieldnumber journaldetail.fieldnumber%TYPE, valuetype journaldetail.valuetype%TYPE, value journaldetail.value%TYPE);
	 TYPE VARSTABLE IS TABLE OF VARSRECORD INDEX BY BINARY_INTEGER;
	 vars_table VARSTABLE;
	 vars_record VARSRECORD;
BEGIN
     par_alreadyInDatabase := 0;
     par_daychange := 0;
     iId := null;
     amount := null;
     result := null;

	 SELECT par_orgkeyname1, par_fieldnumber1, par_valuetype1, par_value1 INTO vars_record FROM dual;   
	 vars_table(1) := vars_record;
	 SELECT par_orgkeyname2, par_fieldnumber2, par_valuetype2, par_value2 INTO vars_record FROM dual;   
	 vars_table(2) := vars_record;
	 SELECT par_orgkeyname3, par_fieldnumber3, par_valuetype3, par_value3 INTO vars_record FROM dual;   
	 vars_table(3) := vars_record;
	 SELECT par_orgkeyname4, par_fieldnumber4, par_valuetype4, par_value4 INTO vars_record FROM dual;   
	 vars_table(4) := vars_record;
	 SELECT par_orgkeyname5, par_fieldnumber5, par_valuetype5, par_value5 INTO vars_record FROM dual;   
	 vars_table(5) := vars_record;
	 SELECT par_orgkeyname6, par_fieldnumber6, par_valuetype6, par_value6 INTO vars_record FROM dual;   
	 vars_table(6) := vars_record;
	 SELECT par_orgkeyname7, par_fieldnumber7, par_valuetype7, par_value7 INTO vars_record FROM dual;   
	 vars_table(7) := vars_record;
	 SELECT par_orgkeyname8, par_fieldnumber8, par_valuetype8, par_value8 INTO vars_record FROM dual;   
	 vars_table(8) := vars_record;
	 SELECT par_orgkeyname9, par_fieldnumber9, par_valuetype9, par_value9 INTO vars_record FROM dual;   
	 vars_table(9) := vars_record;
	 SELECT par_orgkeyname10, par_fieldnumber10, par_valuetype10, par_value10 INTO vars_record FROM dual;   
	 vars_table(10) := vars_record;	
	 
     IF par_id >= 0 THEN
          -- process header
         BEGIN
            SELECT entrycount, id, entrytime  INTO par_newentrycount, iId, par_lastentrytime
                FROM journalstate WHERE deviceid = par_device;
            IF iId = par_id THEN
                -- already in database
                par_alreadyInDatabase := 1;
                RETURN;
            END IF;
            -- increment entrycount
            par_newentrycount := par_newentrycount + 1;
            -- check if day has changed
            par_daychange := par_entrytime - par_lastentrytime;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                par_newentrycount := 1;
         END;
		 
		 FOR i IN 1 .. vars_table.count LOOP
			IF vars_table(i).orgkeyname = 'amount' THEN
				amount := TO_NUMBER(vars_table(i).value);
			ELSIF vars_table(i).orgkeyname = 'result' THEN
				result := vars_table(i).value;
			END IF;
		 END LOOP;

         IF par_pan IS NULL OR par_pan = '' THEN
               INSERT INTO journal(counter, deviceid, entrycount, entrytype, entrytime, servertimestamp, orgentrytype, orgentry, id, amount, result) 
                    VALUES(SEQ_JOURNAL.nextval, par_device, par_newentrycount, par_entrytype, par_entrytime, CURRENT_DATE, par_orgentrytype, par_orgentry, par_id, amount, result);
         ELSE
               INSERT INTO journal(counter, deviceid, entrycount, entrytype, entrytime, servertimestamp, pan, orgentrytype, orgentry, id, amount, result) 
                    VALUES(SEQ_JOURNAL.nextval, par_device, par_newentrycount, par_entrytype, par_entrytime, CURRENT_DATE, par_pan, par_orgentrytype, par_orgentry, par_id, amount, result);
         END IF;
         IF par_newentrycount > 1 THEN
               UPDATE journalstate SET entrycount = par_newentrycount, entrytime = par_entrytime, servertimestamp = CURRENT_DATE, id = par_id
                    WHERE deviceid = par_device;
         ELSE
               INSERT INTO journalstate(deviceid, entrycount, entrytime, servertimestamp, id) 
                        VALUES(par_device, par_newentrycount, par_entrytime, CURRENT_DATE, par_id);
         END IF;
         iEntrycount := par_newentrycount;
     ELSE
         iEntrycount := par_currententrycount;
     END IF;

	-- update transaction_detail table
	items := ITEMSARRAY('''$sequenceno$''', '$txntime$', '$txntype$', '$txnamount$', '''$txnresult$''', '''$txncurrency$''',
	'''$cardno$''', '$cardtype$', '''$cardgroup$''', '''$cardproduct$''', '$cardexpirydate$', '$hosttxnstatus$', '$devicetxnstatus$', '''$senddevicenumber$''', '$servicecode$');

	sqltxndetail := 'INSERT INTO transaction_detail(deviceid, sequenceno, txntime, txntype, txnamount, txnresult, txncurrency,
	cardno, cardtype, cardgroup, cardproduct, cardexpirydate, hosttxnstatus, devicetxnstatus, senddevicenumber, servicecode)
	VALUES (:1, ''$sequenceno$'', $txntime$, $txntype$, $txnamount$, ''$txnresult$'', ''$txncurrency$'',
	''$cardno$'', $cardtype$, ''$cardgroup$'', ''$cardproduct$'', $cardexpirydate$, $hosttxnstatus$, $devicetxnstatus$, ''$senddevicenumber$'', $servicecode$)';
	 
     -- process details	
	FOR i IN 1 .. par_nodetails LOOP
		execute immediate 'INSERT INTO journaldetail(deviceid, entrycount, orgkeyname, fieldnumber, valuetype, value) VALUES(:1, :2, :3, :4, :5, :6)' using par_device, iEntrycount, vars_table(i).orgkeyname, vars_table(i).fieldnumber, vars_table(i).valuetype, vars_table(i).value;
		
		sqltxndetail := REPLACE(sqltxndetail, '$' || vars_table(i).orgkeyname || '$', vars_table(i).value);
	END LOOP;
	
	FOR i IN 1 .. items.count LOOP
		sqltxndetail := REPLACE(sqltxndetail, items(i), 'NULL');
	END LOOP;
	
	EXECUTE IMMEDIATE sqltxndetail using par_device;
END;