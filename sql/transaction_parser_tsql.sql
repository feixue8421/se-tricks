CREATE TABLE transaction_detail
(
	deviceid			char(16) NOT NULL,
	sequenceno			varchar(256) NULL,
	txntime				decimal(18,0) NOT NULL,
	txntype				INTEGER NULL,
	txnauth             INTEGER NULL,
	txnamount			decimal(18,6) NULL,
	txnresult			INTEGER NULL,
	txncurrency			char(10) NULL,
	cardno				char(80) NULL,
	cardtype			INTEGER NULL,
	cardgroup			varchar(256) NULL,
	cardproduct			varchar(256) NULL,
	cardexpirydate		decimal(18,0) NULL,
	hosttxnstatus		INTEGER NULL,
	devicetxnstatus		INTEGER NULL,
	senddevicenumber	varchar(256) NULL,
	servicecode			varchar(32) NULL
)
GO

ALTER TABLE transaction_detail ADD PRIMARY KEY NONCLUSTERED (deviceid ASC, txntime ASC)
GO


DROP PROCEDURE insertDeviceJournalEntry
GO

CREATE PROCEDURE insertDeviceJournalEntry
    @par_device char(16),
    @par_entrytype int,
    @par_entrytime datetime,
    @par_pan varchar(255),
    @par_orgentrytype int,
    @par_orgentry varchar(2048),
    @par_id int,
    @par_currententrycount int,
    @par_nodetails int,   
    @par_orgkeyname1 varchar(254),
    @par_fieldnumber1 int,
    @par_valuetype1 int,
    @par_value1 varchar(2048),
    @par_orgkeyname2 varchar(254),
    @par_fieldnumber2 int,
    @par_valuetype2 int,
    @par_value2 varchar(2048),
    @par_orgkeyname3 varchar(254),
    @par_fieldnumber3 int,
    @par_valuetype3 int,
    @par_value3 varchar(2048),
    @par_orgkeyname4 varchar(254),
    @par_fieldnumber4 int,
    @par_valuetype4 int,
    @par_value4 varchar(2048),
    @par_orgkeyname5 varchar(254),
    @par_fieldnumber5 int,
    @par_valuetype5 int,
    @par_value5 varchar(2048),
    @par_orgkeyname6 varchar(254),
    @par_fieldnumber6 int,
    @par_valuetype6 int,
    @par_value6 varchar(2048),
    @par_orgkeyname7 varchar(254),
    @par_fieldnumber7 int,
    @par_valuetype7 int,
    @par_value7 varchar(2048),
    @par_orgkeyname8 varchar(254),
    @par_fieldnumber8 int,
    @par_valuetype8 int,
    @par_value8 varchar(2048),
    @par_orgkeyname9 varchar(254),
    @par_fieldnumber9 int,
    @par_valuetype9 int,
    @par_value9 varchar(2048),      
    @par_orgkeyname10 varchar(254),
    @par_fieldnumber10 int,
    @par_valuetype10 int,
    @par_value10 varchar(2048),    
    @par_newentrycount int OUTPUT,
    @par_alreadyInDatabase int OUTPUT,
    @par_daychange int OUTPUT,
    @par_lastentrytime datetime OUTPUT
AS
     DECLARE @iId int
     DECLARE @lastentrytime datetime
     DECLARE @par_entrycount int
     DECLARE @par_amount DECIMAL(18,6);
     DECLARE @par_result VARCHAR(50);
	 DECLARE @vars_table TABLE(orgkeyname varchar(254), fieldnumber int, valuetype int, value varchar(2048))

     SET @par_alreadyInDatabase = 0
     SET @par_daychange = 0
     SET @par_amount = NULL
     SET @par_result = NULL

	 IF @par_nodetails >= 1 INSERT INTO @vars_table SELECT @par_orgkeyname1, @par_fieldnumber1, @par_valuetype1, @par_value1
	 IF @par_nodetails >= 2 INSERT INTO @vars_table SELECT @par_orgkeyname2, @par_fieldnumber2, @par_valuetype2, @par_value2
	 IF @par_nodetails >= 3 INSERT INTO @vars_table SELECT @par_orgkeyname3, @par_fieldnumber3, @par_valuetype3, @par_value3
	 IF @par_nodetails >= 4 INSERT INTO @vars_table SELECT @par_orgkeyname4, @par_fieldnumber4, @par_valuetype4, @par_value4
	 IF @par_nodetails >= 5 INSERT INTO @vars_table SELECT @par_orgkeyname5, @par_fieldnumber5, @par_valuetype5, @par_value5
	 IF @par_nodetails >= 6 INSERT INTO @vars_table SELECT @par_orgkeyname6, @par_fieldnumber6, @par_valuetype6, @par_value6
	 IF @par_nodetails >= 7 INSERT INTO @vars_table SELECT @par_orgkeyname7, @par_fieldnumber7, @par_valuetype7, @par_value7
	 IF @par_nodetails >= 8 INSERT INTO @vars_table SELECT @par_orgkeyname8, @par_fieldnumber8, @par_valuetype8, @par_value8
	 IF @par_nodetails >= 9 INSERT INTO @vars_table SELECT @par_orgkeyname9, @par_fieldnumber9, @par_valuetype9, @par_value9
	 IF @par_nodetails >= 10 INSERT INTO @vars_table SELECT @par_orgkeyname10, @par_fieldnumber10, @par_valuetype10, @par_value10
	 
     IF @par_id >= 0
     BEGIN     
          -- process header
          SELECT @par_newentrycount = entrycount, @iId = id, @par_lastentrytime = entrytime 
               FROM journalstate WHERE deviceid = @par_device
          IF @@ROWCOUNT > 0
          BEGIN
               -- entry in journalstate exits
               IF @iId = @par_id
               BEGIN
                -- already in database
                    SET @par_alreadyInDatabase = 1
                    RETURN
               END
               -- increment entrycount
               SET @par_newentrycount = @par_newentrycount + 1
            -- check if day has changed
               SET @par_daychange = DATEPART(dayofyear,  @par_entrytime) - DATEPART(dayofyear,  @par_lastentrytime)
          END
          ELSE
               SET @par_newentrycount = 1

		  SELECT @par_amount = CAST(value AS DECIMAL(18,6)) FROM @vars_table WHERE orgkeyname = 'amount'
		  
		  SELECT @par_result = CAST(value AS VARCHAR(50)) FROM @vars_table WHERE orgkeyname = 'result'

          IF @par_pan = ''
               INSERT INTO journal(deviceid, entrycount, entrytype, entrytime, servertimestamp, orgentrytype, orgentry, id, amount, result) 
                    VALUES(@par_device, @par_newentrycount, @par_entrytype, @par_entrytime, GETDATE(), @par_orgentrytype, @par_orgentry, @par_id, @par_amount, @par_result)
          ELSE
               INSERT INTO journal(deviceid, entrycount, entrytype, entrytime, servertimestamp, pan, orgentrytype, orgentry, id, amount, result) 
                    VALUES(@par_device, @par_newentrycount, @par_entrytype, @par_entrytime, GETDATE(), @par_pan, @par_orgentrytype, @par_orgentry, @par_id, @par_amount, @par_result)

          IF @par_newentrycount > 1
               UPDATE journalstate SET entrycount = @par_newentrycount, entrytime = @par_entrytime, servertimestamp = GETDATE(), id = @par_id 
                    WHERE deviceid = @par_device
          ELSE
               INSERT INTO journalstate(deviceid, entrycount, entrytime, servertimestamp, id) 
                    VALUES(@par_device, @par_newentrycount, @par_entrytime, GETDATE(), @par_id)
          SET @par_entrycount = @par_newentrycount
     END
     ELSE
          SET @par_entrycount = @par_currententrycount

     -- process details
	 INSERT INTO journaldetail(deviceid, entrycount, orgkeyname, fieldnumber, valuetype, value)
		SELECT @par_device, @par_entrycount, orgkeyname, fieldnumber, valuetype, value FROM @vars_table

	 DECLARE @sqltxndetail VARCHAR(8000)
	 SET @sqltxndetail = 'INSERT INTO transaction_detail(deviceid, sequenceno, txntime, txntype, txnauth, txnamount, txnresult, txncurrency,
		cardno, cardtype, cardgroup, cardproduct, cardexpirydate, hosttxnstatus, devicetxnstatus, senddevicenumber, servicecode)
		VALUES (''$deviceid$'', ''$sequenceno$'', $txntime$, $txntype$, $txnauth$, $txnamount$, $txnresult$, ''$txncurrency$'',
		''$cardno$'', $cardtype$, ''$cardgroup$'', ''$cardproduct$'', $cardexpirydate$, $hosttxnstatus$, $devicetxnstatus$, ''$senddevicenumber$'', ''$servicecode$'')'
	 SELECT @sqltxndetail = REPLACE(@sqltxndetail, '$' + orgkeyname + '$', value) FROM @vars_table
	 SET @sqltxndetail = REPLACE(@sqltxndetail, '$deviceid$', @par_device)

	 DECLARE @items_table TABLE(item VARCHAR(80))
	 INSERT INTO @items_table SELECT '''$sequenceno$''' UNION ALL SELECT '$txntime$' UNION ALL SELECT '$txntype$' UNION ALL SELECT '$txnauth$' UNION ALL SELECT '$txnamount$' UNION ALL SELECT '$txnresult$' UNION ALL SELECT '''$txncurrency$'''
		UNION ALL SELECT '''$cardno$''' UNION ALL SELECT '$cardtype$' UNION ALL SELECT '''$cardgroup$''' UNION ALL SELECT '''$cardproduct$''' UNION ALL SELECT '$cardexpirydate$' UNION ALL SELECT '$hosttxnstatus$' 
		UNION ALL SELECT '$devicetxnstatus$' UNION ALL SELECT '''$senddevicenumber$''' UNION ALL SELECT '''$servicecode$'''
	 SELECT @sqltxndetail = REPLACE(@sqltxndetail, item, 'NULL') FROM @items_table
	 
	 EXEC(@sqltxndetail)
GO

