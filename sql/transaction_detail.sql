CREATE TABLE transaction_detail
(
	deviceid			char(16) NOT NULL,
	sequenceno			varchar2(256) NULL,
	txntime				decimal(18,0) NOT NULL,
	txntype				INTEGER NULL,
	txnauth				INTEGER NULL,
	txnamount			decimal(18,6) NULL,
	txnresult			INTEGER NULL,
	txncurrency			char(10) NULL,
	cardno				char(80) NULL,
	cardtype			INTEGER NULL,
	cardgroup			varchar2(256) NULL,
	cardproduct			varchar2(256) NULL,
	cardexpirydate		decimal(18,0) NULL,
	hosttxnstatus		INTEGER NULL,
	devicetxnstatus		INTEGER NULL,
	senddevicenumber	varchar2(256) NULL,
	servicecode			varchar2(32) NULL
);

ALTER TABLE transaction_detail ADD PRIMARY KEY (deviceid, txntime);

create or replace PROCEDURE insertTransactionDetail(
	par_deviceid IN eventstore.deviceid%TYPE,
	par_transaction_info IN eventstore.orgmessage%TYPE )
IS
	TYPE ITEMSARRAY IS VARRAY(50) OF VARCHAR2(80 CHAR);
	TYPE VALUESARRAY IS VARRAY(50) OF VARCHAR2(1024 CHAR);
	txn_items ITEMSARRAY;
	txn_values VALUESARRAY;
	tbl_items ITEMSARRAY;
	tbl_type_items ITEMSARRAY;
	sqltxndetail VARCHAR2(8000 CHAR);
	txn_item_value VARCHAR2(1024 CHAR); 
	position_start INTEGER;
	position_end INTEGER;
BEGIN
	txn_items := ITEMSARRAY(',TxnNo=', ',Pan1=', ',TxnDate=', ',TxnTime=', ',TxnType=', ',TxnAmount=', ',CardType=', ',HostAuth=', ',TxnReversal=', ',ReversalResult=');
	txn_values := VALUESARRAY();
	tbl_items := ITEMSARRAY('sequenceno', 'cardno', 'txntime', 'txntime', 'txntype', 'txnamount', 'cardtype', 'txnresult', 'txnauth', 'txnauth');
	
	tbl_type_items := ITEMSARRAY('''$sequenceno$''', '''$txntime$''', '$txntype$', '$txnauth$', 
	'$txnamount$', '$txnresult$', '''$txncurrency$''', '''$cardno$''', '$cardtype$', '''$cardgroup$''', 
	'''$cardproduct$''', '$cardexpirydate$', '$hosttxnstatus$', '$devicetxnstatus$', '''$senddevicenumber$''', '''$servicecode$''');
	
	sqltxndetail := 'INSERT INTO transaction_detail(deviceid, sequenceno, txntime, txntype, txnauth, txnamount, txnresult, txncurrency,
	cardno, cardtype, cardgroup, cardproduct, cardexpirydate, hosttxnstatus, devicetxnstatus, senddevicenumber, servicecode)
	VALUES (:1, ''$sequenceno$'', TO_NUMBER(TO_DATE(''$txntime$'', ''YYYYMMDDHH24:MI:SS'') - TO_DATE(''1970-01-01'', ''YYYY-MM-DD'')) * 24 * 60 * 60 * 1000,
	$txntype$, $txnauth$, $txnamount$, $txnresult$, ''$txncurrency$'', ''$cardno$'', $cardtype$, ''$cardgroup$'', 
	''$cardproduct$'', $cardexpirydate$, $hosttxnstatus$, $devicetxnstatus$, ''$senddevicenumber$'', ''$servicecode$'')';
	
	-- analyze txn info
	FOR i IN 1 .. txn_items.count LOOP
		txn_item_value := '';

		position_start := INSTR(par_transaction_info, txn_items(i));
		IF position_start > 0 THEN
			position_end := INSTR(par_transaction_info, ',', position_start + 1);
			IF position_end <= 0 THEN
				position_end := LENGTH(par_transaction_info) + 1;
			END IF;

			txn_item_value := SUBSTR(par_transaction_info, position_start + LENGTH(txn_items(i)), position_end - position_start - LENGTH(txn_items(i)));
		END IF;

		txn_values.extend; 
		txn_values(i) := txn_item_value;

		IF INSTR(txn_items(i), 'TxnTime') > 0 THEN
			txn_item_value := txn_values(i - 1) || txn_values(i);
			txn_values(i - 1) := txn_item_value;
			txn_values(i) := txn_item_value;
		ELSIF INSTR(txn_items(i), 'ReversalResult') > 0 THEN
			IF txn_values(i - 1) = 'Y' THEN
				txn_item_value := CASE txn_item_value WHEN '00' THEN '4' ELSE '5' END;
			ELSE
				txn_item_value := '3';
			END IF;

			txn_values(i - 1) := txn_item_value;
			txn_values(i) := txn_item_value;
		ELSIF INSTR(txn_items(i), 'TxnType') > 0 THEN
			txn_values(i) := CASE txn_item_value WHEN 'MWD' THEN '1' WHEN 'MWC' THEN '2' WHEN 'MCD' THEN '3' WHEN 'WCD' THEN '4' WHEN 'MCQ' THEN '5' WHEN 'WK2' THEN '6' WHEN 'WK3' THEN '7' ELSE '' END;
		ELSIF INSTR(txn_items(i), 'CardType') > 0 THEN
			txn_values(i) := CASE txn_item_value WHEN 'MA' THEN '1' WHEN 'IC' THEN '2' ELSE '' END;
		ELSIF INSTR(txn_items(i), 'HostAuth') > 0 THEN
			txn_values(i) := CASE txn_item_value WHEN '00' THEN '1' WHEN '01' THEN '2' WHEN '02' THEN '3' WHEN '03' THEN '4' ELSE '' END;
		END IF;
	END LOOP;

	-- update txn info
	FOR i IN 1 .. txn_items.count LOOP
		IF LENGTH(txn_values(i)) > 0 THEN
			sqltxndetail := REPLACE(sqltxndetail, '$' || tbl_items(i) || '$', txn_values(i));
		END IF;
	END LOOP;
	
	-- set other fields to NULL
	FOR i IN 1 .. tbl_type_items.count LOOP
		sqltxndetail := REPLACE(sqltxndetail, tbl_type_items(i), 'NULL');
	END LOOP;
	
	-- DBMS_OUTPUT.PUT_LINE(sqltxndetail);
	-- update transaction_detail
	EXECUTE IMMEDIATE sqltxndetail USING par_deviceid;
END;
/