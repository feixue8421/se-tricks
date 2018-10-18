
content = """
;取款钞箱正常
26:882000=^CDM CASHOUT_CASSETTE Note status is OK

;取款钞箱空
26:882001=^CDM CASHOUT_CASSETTE Note status is EMPTY

;取款钞箱钞少, default is 200 notes
26:882003=^CDM CASHOUT_CASSETTE Note status is LOW

;取款钞箱钞少, default is 200 notes
26:882005=^CDM CASHOUT_CASSETTE Note status is (MISSING|UNKNOWN)

;取款钞箱硬件总状态：全部正常
26:881400=^CDM CASHOUT_CASSETTE Physical status is OK

;取款钞箱硬件总状态：全部故障
26:881401=^CDM CASHOUT_CASSETTE Physical status is ERROR

;取款钞箱硬件总状态：一个或多个故障
26:881403=^CDM CASHOUT_CASSETTE Physical status is WARN

;取款钞箱钞少, default is 200 notes
26:881405=^CDM CASHOUT_CASSETTE Physical status is (MISSING|UNKNOWN)

;存款钞箱正常
26:882100=^CIM CASHIN_CASSETTE Note status is OK
			
;存款钞箱将满, default is 1800 notes
26:882103=^CIM CASHIN_CASSETTE Note status is HIGH

;存款钞箱满
26:882101=^CIM CASHIN_CASSETTE Note status is FULL

;存款钞箱未知
26:882105=^CIM CASHIN_CASSETTE Note status is (MISSING|UNKNOWN)

;回收箱正常
26:880900=.*RETRACT_CASSETTE OK

;回收箱满
26:880903=.*RETRACT_CASSETTE FULL

;回收箱故障
26:880901=.*RETRACT_CASSETTE ERROR

;回收箱未连接
26:880905=.*RETRACT_CASSETTE MISSING

;废钞箱正常
26:881000=.*REJECT_CASSETTE OK

;废钞箱满
26:881003=.*REJECT_CASSETTE FULL

;废钞箱故障
26:881001=.*REJECT_CASSETTE ERROR

;废钞箱未连接
26:881005=.*REJECT_CASSETTE MISSING

;凭条打纸满
26:881700=^PRR .*Paper full.*

;凭条打印机纸少
26:881703=^PRR .*Paper low.*

;凭条打印机纸空
26:881701=^PRR .*Paper out.*

;凭条打印机故障
26:880401=^PRR Not operational.*

;凭条打印机正常
26:880400=^PRR Operational.*

;存款模块正常
26:880200=^CIM Operational.*

;存款模块异常
26:880201=^CIM Not operational.*

;取款模块正常
26:880100=^CDM Operational.*

;取款模块异常
26:880101=^CDM Not operational.*

;密码键盘正常
26:880600=^PIN Operational.*

;密码键盘异常
26:880601=^PIN Not operational.*

;读卡器正常
26:880300=^IDC Operational.*

;读卡器异常
26:880301=^IDC Not operational.*

;safe door open
26:880801=.*SAFEDOOR OPEN.*
"""

eventAdapt = """
INSERT INTO message0001 (textno, texttype, messagetext) VALUES ($EVENTID$, 1, '$MSGTEXT$');
INSERT INTO message0156 (textno, texttype, messagetext) VALUES ($EVENTID$, 1, '$MSGTEXT$');
INSERT INTO eventbase(eventno, textno, texttype, setbit, unsetbit, componentid, compsetbit, compunsetbit, target, forwarddesktop, forwardrule, eventgroupid, confidential, confidentialmask, masktype) VALUES ($EVENTID$, $EVENTID$, 1, 0, 0, 0, 0, 0, 1, 1, 1, NULL, NULL, NULL, NULL);
INSERT INTO eventconversion (messageno, devicetype, eventno, description) VALUES ($MSGNO$, 1000, $EVENTID$, '$MSGTEXT$');
"""

print("""
DELETE eventconversion WHERE devicetype = 0 AND eventno BETWEEN 600000 AND 700000;
DELETE eventbase WHERE eventno BETWEEN 600000 AND 700000;
DELETE message0156 WHERE texttype = 1 AND textno BETWEEN 600000 AND 700000;
DELETE message0001 WHERE texttype = 1 AND textno BETWEEN 600000 AND 700000;
""")

eventid = 600000
msgtext = ''
msgno = ''
for line in content.split('\n'):

    if line.startswith(';'):
        msgtext = line[1:]
    
    if line.startswith('26:'):
        msgno = line[3:9]
        
        eventid = eventid + 1 
        print(eventAdapt.replace('$MSGTEXT$', msgtext).replace('$MSGNO$', msgno).replace('$EVENTID$', str(eventid)))

print('--done!!')

