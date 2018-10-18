content = '''
		xmlDataField.put("productRegistNo", "CPDJH");
		xmlDataField.put("productName", "CPMC");
		xmlDataField.put("vendor", "PPCH");
		xmlDataField.put("systemVersion", "XTBBH");
		xmlDataField.put("fingerReader", "ZWCJQMC");
		xmlDataField.put("fingerReaderType", "ZWCJQXH");
		xmlDataField.put("fingerReaderId", "ZWCJQID");
		xmlDataField.put("ipAddress", "IPDZ");
		xmlDataField.put("location", "BSDD");
		xmlDataField.put("acceptUnitCode", "GAJGDM");
		xmlDataField.put("acceptUnitName", "GAJGMC");
		xmlDataField.put("applicant", "SBRXM");
		xmlDataField.put("dataOwnerCode", "SJGSDWDM");
		xmlDataField.put("dataOwnerName", "SJGSDWMC");
		xmlDataField.put("acceptUnitAddress", "SLDW_DZMC");
		xmlDataField.put("acceptUnitAddressJS", "JSSLDW_DZMC");
		xmlDataField.put("acceptUnitCodeJS", "JSSLDW_GAJGDM");
		xmlDataField.put("acceptUnitName", "SLDW_GAJGMC");
		xmlDataField.put("acceptUnitNameJS", "JSSLDW_GAJGMC");
		xmlDataField.put("acceptUnitPhoneNo", "SLDW_LXDH");
		xmlDataField.put("acceptUnitPhoneNoJS", "JSSLDW_LXDH");
		xmlDataField.put("applyReason", "JMSFZSLYYDM");
		xmlDataField.put("birthday", "CSRQ");
		xmlDataField.put("code", "@code");
		xmlDataField.put("commissionCharge", "ZZJE");
		xmlDataField.put("delivery", "JMSFZLZFSDM");
		xmlDataField.put("deliveryAddress", "YJDZ");
		xmlDataField.put("faultCode", "GZDM");
		xmlDataField.put("faultDescription", "GZMS");
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
		xmlDataField.put("issuer", "QFJG_GAJGMC");
		xmlDataField.put("legalityExpireDate", "YXQJZRQ");
		xmlDataField.put("legalityStartDate", "YXQQSRQ");
		xmlDataField.put("lostFlag", "JMSFZ_JSZLBS");
		xmlDataField.put("msg", "@msg");
		xmlDataField.put("name", "XM");
		xmlDataField.put("nationality", "MZDM");
		xmlDataField.put("no", "NO");
		xmlDataField.put("phoneNo", "LXDH");
		xmlDataField.put("photo", "XP");
		xmlDataField.put("proposerSig", "SQRQM");
		xmlDataField.put("registDate", "DJSJ");
		xmlDataField.put("reportLostType", "GSLX");
		xmlDataField.put("scenePhoto", "XCXP");
		xmlDataField.put("sex", "XBDM");
		xmlDataField.put("unusualFinger", "SZYCZKDM");
		xmlDataField.put("xzzAddress", "XZZ_QHNXXDZ");
		xmlDataField.put("xzzCityCode", "XZZ_SSXQDM");
		xmlDataField.put("zipCode", "YJBM");
'''

lines = content.split("\n")
lines.sort()

print('\n'.join(lines))
print("done!!!")
