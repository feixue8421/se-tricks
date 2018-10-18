xmlmapping = '''xmlDataField.put("acceptUnitAddressReceiver", "SLDW_DZMC");
xmlDataField.put("acceptUnitAddressLostReceiver", "JSSLDW_DZMC");
xmlDataField.put("acceptUnitCode", "GAJGDM");
xmlDataField.put("acceptUnitCodeLostReceiver", "JSSLDW_GAJGDM");
xmlDataField.put("acceptUnitName", "GAJGMC");
xmlDataField.put("acceptUnitNameReceiver", "SLDW_GAJGMC");
xmlDataField.put("acceptUnitNameLostReceiver", "JSSLDW_GAJGMC");
xmlDataField.put("acceptUnitPhoneNoReceiver", "SLDW_LXDH");
xmlDataField.put("acceptUnitPhoneNoLostReceiver", "JSSLDW_LXDH");
xmlDataField.put("applicant", "SBRXM");
xmlDataField.put("applyReason", "JMSFZSLYYDM");
xmlDataField.put("birthday", "CSRQ");
xmlDataField.put("code", "@code");
xmlDataField.put("commissionCharge", "ZZJE");
xmlDataField.put("dataOwnerCode", "SJGSDWDM");
xmlDataField.put("dataOwnerName", "SJGSDWMC");
xmlDataField.put("delivery", "JMSFZLZFSDM");
xmlDataField.put("deliveryAddress", "YJDZ");
xmlDataField.put("faultCode", "GZDM");
xmlDataField.put("faultDescription", "GZMS");
xmlDataField.put("fingerReader", "ZWCJQMC");
xmlDataField.put("fingerReaderId", "ZWCJQID");
xmlDataField.put("fingerReaderType", "ZWCJQXH");
xmlDataField.put("flowNo", "JS_YWLSH");
xmlDataField.put("fp1Code", "ZWY_ZWDM");
xmlDataField.put("fp1CodeReturned", "CYJMSFZQK_ZWY_ZWDM");
xmlDataField.put("fp1FeatureData", "ZWY_ZWTZSJ");
xmlDataField.put("fp1FeatureDataReturned", "CYJMSFZQK_ZWY_ZWTZSJ");
xmlDataField.put("fp1ImageData", "ZWY_ZWTXSJ");
xmlDataField.put("fp1ImageQuality", "ZWY_ZWTXZLZ");
xmlDataField.put("fp1Result", "ZWY_ZWZCJGDM");
xmlDataField.put("fp1ResultReturned", "CYJMSFZQK_ZWY_ZWZCJGDM");
xmlDataField.put("fp2Code", "ZWE_ZWDM");
xmlDataField.put("fp2CodeReturned", "CYJMSFZQK_ZWE_ZWDM");
xmlDataField.put("fp2FeatureData", "ZWE_ZWTZSJ");
xmlDataField.put("fp2FeatureDataReturned", "CYJMSFZQK_ZWE_ZWTZSJ");
xmlDataField.put("fp2ImageData", "ZWE_ZWTXSJ");
xmlDataField.put("fp2ImageQuality", "ZWE_ZWTXZLZ");
xmlDataField.put("fp2Result", "ZWE_ZWZCJGDM");
xmlDataField.put("fp2ResultReturned", "CYJMSFZQK_ZWE_ZWZCJGDM");
xmlDataField.put("fpCollectResult", "ZWCJJGDM");
xmlDataField.put("fpCollectResultResult", "CYJMSFZQK_ZWCJJGDM");
xmlDataField.put("fpValidation", "ZWBDJGBS");
xmlDataField.put("fpValidationFingers", "BDZWZW");
xmlDataField.put("fpValidationImages", "BDZWTX");
xmlDataField.put("giveupReason", "BLQYY");
xmlDataField.put("hjAddress", "HJDZ_QHNXXDZ");
xmlDataField.put("hjCity", "HJDZ_SSXQ");
xmlDataField.put("hjCityCode", "HJDZ_SSXQDM");
xmlDataField.put("hjDataOwerCode", "HJDZ_SJGSDWDM");
xmlDataField.put("hjDataOwerName", "HJDZ_SJGSDWMC");
xmlDataField.put("id", "GMSFHM");
xmlDataField.put("ipAddress", "IPDZ");
xmlDataField.put("issuer", "QFJG_GAJGMC");
xmlDataField.put("legalityExpireDate", "YXQJZRQ");
xmlDataField.put("legalityStartDate", "YXQQSRQ");
xmlDataField.put("location", "BSDD");
xmlDataField.put("lostFlag", "JMSFZ_JSZLBS");
xmlDataField.put("msg", "@msg");
xmlDataField.put("name", "XM");
xmlDataField.put("nationality", "MZDM");
xmlDataField.put("no", "NO");
xmlDataField.put("phoneNo", "LXDH");
xmlDataField.put("photo", "XP");
xmlDataField.put("productName", "CPMC");
xmlDataField.put("productRegistNo", "CPDJH");
xmlDataField.put("proposerSig", "SQRQM");
xmlDataField.put("registDate", "DJSJ");
xmlDataField.put("reportLostType", "GSLX");
xmlDataField.put("scenePhoto", "XCXP");
xmlDataField.put("sex", "XBDM");
xmlDataField.put("systemVersion", "XTBBH");
xmlDataField.put("unusualFinger", "SZYCZKDM");
xmlDataField.put("vendor", "PPCH");
xmlDataField.put("xzzAddress", "XZZ_QHNXXDZ");
xmlDataField.put("xzzCityCode", "XZZ_SSXQDM");
xmlDataField.put("zipCode", "YJBM");'''

mapitems = [item.strip() for item in xmlmapping.split("\n")]
mapitems.sort()

print("sorted items:")
print('\n'.join(mapitems))

def tojparam(xid):
    for mapitem in mapitems:
        if (mapitem.find('"%s"' % (xid)) != -1):
            return mapitem[len('xmlDataField.put("') : mapitem.index('", "')]

    return "Unknown %s" % xid

def generateDataDefination(id, paramcontent):
    xids = [item.strip().upper() for item in paramcontent.split("\n")]
    params = '\n'.join(['public String %s;' % (tojparam(xid)) for xid in xids])
    print('-----------------------------------')
    print('public static class %s {%s}' % (id, params))
    print('-----------------------------------')

fields = '''AidRegister
Identification
LostFound
VaildIdentification
IDApplyDataRecord
GiveupLostFoundDataRecord
ReportLostDataRecord
TerminalFaultRecord'''.split('\n')

definations = ['''cpdjh
cpmc
ppch
xtbbh
zwcjqmc
zwcjqxh
zwcjqid
ipdz
bsdd
gajgdm
gajgmc
sbrxm
sjgsdwdm
sjgsdwmc''', #AidRegister
'''gmsfhm
xm
xbdm
mzdm
csrq
xp
hjdz_ssxqdm
hjdz_ssxq
hjdz_qhnxxdz
hjdz_sjgsdwdm
hjdz_sjgsdwmc
cyjmsfzqk_zwcjjgdm
cyjmsfzqk_zwy_zwzcjgdm
cyjmsfzqk_zwy_zwdm
cyjmsfzqk_zwy_zwtzsj
cyjmsfzqk_zwe_zwzcjgdm
cyjmsfzqk_zwe_zwdm
cyjmsfzqk_zwe_zwtzsj
jmsfz_jszlbs''', #Identification
'''js_ywlsh
gmsfhm
xm
qfjg_gajgmc
yxqqsrq
yxqjzrq
jssldw_gajgdm
jssldw_gajgmc
jssldw_dzmc
jssldw_lxdh''', #LostFound
'''no
gmsfhm
xm
xbdm
mzdm
csrq
hjdz_ssxq
hjdz_qhnxxdz
qfjg_gajgmc
yxqqsrq
yxqjzrq
xp
zwcjjgdm
zwy_zwzcjgdm
zwy_zwdm
zwy_zwtzsj
zwe_zwzcjgdm
zwe_zwdm
zwe_zwtzsj''', #VaildIdentification
'''gmsfhm
xm
xbdm
mzdm
csrq
xp
hjdz_ssxqdm
hjdz_qhnxxdz
hjdz_sjgsdwdm
hjdz_sjgsdwmc
xzz_ssxqdm
xzz_qhnxxdz
jmsfzslyydm
zzje
jmsfzlzfsdm
yjbm
yjdz
lxdh
djsj
zwcjjgdm
zwy_zwzcjgdm
zwy_zwdm
zwy_zwtxsj
zwy_zwtxzlz
zwy_zwtzsj
zwe_zwzcjgdm
zwe_zwdm
zwe_zwtxsj
zwe_zwtxzlz
zwe_zwtzsj
szyczkdm
sqrqm
zwbdjgbs
bdzwzw
bdzwtx''', #IDApplyDataRecord
'''js_ywlsh
gmsfhm
xm
qfjg_gajgmc
qfjg_gajgmc
yxqqsrq
yxqjzrq
sldw_gajgmc
sldw_dzmc
sldw_lxdh
blqyy
xcxp
sqrqm
bdzwzw
zwbdjgbs
bdzwtx
lxdh
djsj''', #GiveupLostFoundDataRecord
'''gmsfhm
xm
xbdm
mzdm
csrq
hjdz_ssxqdm
hjdz_qhnxxdz
gslx
xcxp
sqrqm
zwbdjgbs
bdzwzw
bdzwtx
lxdh
djsj''', #ReportLostDataRecord
'''gzdm
gzms
djsj''' #TerminalFaultRecord
]

[generateDataDefination(fields[idx], definations[idx]) for idx in range(len(fields))]

print("done!!!")

