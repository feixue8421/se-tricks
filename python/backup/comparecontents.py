import re

left = """
typedef enum {
   /* Commands */
   RESERVED_CMD_CODE                   = 0x00,
   BOARD_PARAMS_CMD_CODE               = 0x01,
   REGISTER_ONU_CMD_CODE               = 0x02,
   DLT_SER_NUM_CMD_CODE                = 0x03,
   OAM_PATH_INFO_CMD_CODE              = 0x04,
   BER_INT_CONFIG_CMD_CODE             = 0x05,
   SET_FEC_CMD_CODE                    = 0x06,
   ENCRYPT_PORTID_CMD_CODE             = 0x07,
   ISU_IN_PRG_CMD_CODE                 = 0x08,
   REQUEST_STAT_CMD_CODE               = 0x09,
   SET_SER_NUM_STAT_CMD_CODE           = 0x0A,
   SET_BANDWIDTH_CMD_CODE              = 0x0B,
   SET_TIMING_PARAM_CMD_CODE           = 0x0C,
   GET_PASSWORD_CMD_CODE               = 0x0D,
   CONFIGURE_ALLOCID_CMD_CODE          = 0x0E,
   RESTART_CMD_CODE                    = 0x0F,
   RESTART_STAT_CMD_CODE               = 0x10,
   GET_PM_CTRS_CMD_CODE                = 0x12, /*New from Rob's latest gltda code */
   /* Alarm messages */
   GLTD_ALRM_MSG_CODE                  = 0x14,
   ONU_ALRM_MSG_CODE                   = 0x15,

   /* PM GEM msgs */
   RESERVE_PM_COUNTER_CMD_CODE         = 0x16,
   RETURN_PM_COUNTER_CMD_CODE          = 0x17,
   SET_PM_COUNTER_CMD_CODE             = 0x18,

   /* Diagnostic Thread */
   DIAG_TEST_CMD_CODE                  = 0x19,
   SLEEP_ALLOW_CMD_CODE                = 0x1A,
   REBOOT_ONT_WITH_PLOAM_CMD_CODE      = 0x1B,

   /*upstream dynamic cac*/
   MAX_RANGING_ONTS_CMD_CODE           = 0x1C,
   TCONTS_PER_FRAME_CMD_CODE           = 0x1D,
   ENCRYPT_PORTID_RELEASE_CMD_CODE     = 0x1E,
   /*Clear RNG mistmatch alarm*/
   CLR_RNG_MISMATCH_CMD_CODE       = 0x1F,

   /* Board management notifications */
   ALIVE_NTF_CODE                      = 0x20,
   RESTART_NTF_CODE                    = 0x21,
   ONU_DETECT_NTF_CODE                 = 0x22,
   PM_GEM_NTF_CODE                     = 0x23,
   DIAG_NTF_CODE                       = 0x24,
   ONU_ALM_CHG_NTF_CODE                = 0x25,
   ONU_KEYS_NTF_CODE	               = 0x26,
   DIAG_ACTIVE_NTF_CODE                = 0x27,
   POPUP_INPRG_NTF_CODE                = 0x28,
   ONU_TEQ_NTF_CODE                    = 0x29,

   /* additional commands */
   SNIPER_ENABLE_CMD_CODE              = 0x30,
   SWO_PROV_CMD_CODE                   = 0x31,
   SWO_STATUS_CMD_CODE                 = 0x34,
   SET_PROFILE_CMD_CODE                = 0x35,
   SET_AES_CMD_CODE                    = 0x36,
   LOID_AUTH_STAT_CMD_CODE             = 0x37,
   SET_MSK_CMD_CODE                    = 0x38,
   SET_PON_TAG_CMD_CODE                = 0x39,
   DEL_STDBY_PROV_CMD_CODE             = 0x3a,
   MANUAL_SWO2_CMD_CODE                = 0x3b,
   SET_LOOC_ALARM_CMD_CODE             = 0x3c,
   SET_BC_KEY_CMD_CODE                 = 0x3d,
   ACT_DEACT_BC_ENCRYPT_CMD_CODE       = 0x3e,
   /* unused                           = 0x3F, */

   /* T&D console traffic */
   CONSOLE_MESSAGE                     = 0x40,
   CONSOLE_RESPONSE                    = 0x41,

   /* LTP time of day exchange */
   LTP_TIME_REQUEST                    = 0x42,
   PLT_TIME_RESPONSE                   = 0x43,

   /* Dynamic data sync messages */
   ONU_SYNC_NTF_CODE                   = 0x44,
   PON_SYNC_NTF_CODE                   = 0x45,
   ONU_SYNC_CMD_CODE                   = 0x46,
   PON_SYNC_CMD_CODE                   = 0x47,
   SYNC_AUDIT_NTF_CODE                 = 0x48,

   /* Additional Diagnostic Thread */
   DIAG_PARMS_CMD_CODE                 = 0x50,
   DIAG_IGNORE_ONU_CMD_CODE            = 0x51,

   COMMIT_TYPE_C_CMD_CODE              = 0x52,

   /* N:P CMCC IOP feature */
   SEND_PASSWORD_REQUEST_CODE          = 0x53,

   /* PON utilization feature */
   PON_UTIL_CMD_CODE                   = 0x54,

   /* GPON PON-ID Maintenance feature */
   SET_GPON_ID_CMD_CODE                = 0x55,

   /* Alien detection */
   DIAG_ALIEN_TEST_PARMS_CMD_CODE      = 0x56,
   DIAG_ALIEN_NTF_CODE                 = 0x57,
   SET_PON_RANGE_MODE                  = 0x58,
   SET_PONLOS_ALARM_CTRL             = 0x59,

   /*query eligible for diag*/
   DIAG_IS_ELIGIBLE_FOR_TEST       = 0x5c,

   /* NGPON2 */
   SET_FREE_ONUID_MAP_CMD_CODE         = 0x61,
   GET_FREE_ONUID_MAP_CMD_CODE         = 0x62,
   SET_PON_ID_CMD_CODE                 = 0x63,
   TUNE_CONTROL_CMD_CODE               = 0x64,
   PM_PHY_GEM_NTF_CODE                 = 0x65,
   TUNE_CONTROL_NTF_CODE               = 0x66,
   GET_ONU_TUNE_DATA_CMD_CODE          = 0x67,
   SET_ONU_TUNE_DATA_CMD_CODE          = 0x68,
   SET_CHANNEL_SPEED_CMD_CODE          = 0x69,
   SET_CHANNEL_PROFILE_CMD_CODE        = 0x6a,
   ONU_PROTECTION_CMD_CODE             = 0x6b,
   ONU_TARGET_CP_CMD_CODE              = 0x6c,
   DEACTIVATE_ONU_CMD_CODE             = 0x6d,
   SET_CHANNEL_PAIR_OPER_MODE_CMD_CODE = 0x6e, /* XGS versus TWDM mode */
   SET_SYSTEM_PROFILE_CMD_CODE         = 0x6f,
   GLOB_ERR_REC_NTF_CODE               = 0x70,

   /* PRELOAD TYPEA*/
   LISTEN_FOR_ZYNQ_UPGRADE             = 0x71,
   MBX_MAX_CMD_CODE

    /* Host ONT simulation private codes */
    /* must not overlap real ones */
    ,ONTSIM_DET_REQUEST                = 0x7f
    ,ONTSIM_DET_RESPONSE               = 0x7e
} MESSAGE_CODE;
"""

right = """
typedef enum
{
    /* Commands */
    GPON_RESERVED_CMD_CODE                   = 0x00,
    GPON_BOARD_PARAMS_CMD_CODE               = 0x01,
    REGISTER_ONU_CMD_CODE                    = 0x02,
    GPON_DEACT_ONU_CMD_CODE                  = 0x03,
    GPON_CONFIG_PORTID_CMD_CODE              = 0x04,
    GPON_BER_INT_CONFIG_CMD_CODE             = 0x05,
    ENA_DISABLE_FEC_CMD_CODE                 = 0x06,
    GPON_ENCRYPTED_PORTID_CMD_CODE           = 0x07,
    GPON_ISU_IN_PRG_CMD_CODE                 = 0x08,
    GPON_REQUEST_STAT_CMD_CODE               = 0x09,
    ENA_DISABLE_GPON_SERNUM_CMD_CODE         = 0x0A,
    GPON_SET_BANDWIDTH_CMD_CODE              = 0x0B,
    GPON_SET_TIMING_PARAM_CMD_CODE           = 0x0C,
    GPON_GET_GPON_PASSWORD_CMD_CODE          = 0x0D,
    GPON_ASSIGN_ALLOCID_CMD_CODE             = 0x0E,
    GPON_RESTART_CMD_CODE                    = 0x0F,
    GPON_RESTART_STAT_CMD_CODE               = 0x10, /* can we do this?  No RI */
    GPON_GET_PM_CTRS_CMD_CODE                = 0x12,
    GPON_GET_GLOB_ALRM_CMD_CODE              = 0x14,
    GPON_GET_ONU_ALRM_CMD_CODE               = 0x15,
    RESERVE_GPON_PM_COUNTER_CMD_CODE         = 0x16,
    RETURN_GPON_PM_COUNTER_CMD_CODE          = 0x17,
    SET_GPON_PM_COUNTER_CMD_CODE             = 0x18,
    GPON_DIAG_TEST_CMD_CODE                  = 0x19,
    GPON_SLEEP_ALLOW_CMD_CODE                = 0x1A,
    GPON_REBOOT_ONT_VIA_PLOAM_CMD_CODE       = 0x1B,
    /*upstream dynamic cac*/
    GPON_MAX_RANGING_ONTS_CMD_CODE           = 0x1C,
    GPON_TCONTS_PER_FRAME_CMD_CODE           = 0x1D,

    GPON_ENCRYPTED_PORTID_RELEASE_CMD_CODE   = 0x1E,
    GPON_CLR_RNG_MISMATCH_CMD_CODE           = 0x1F,

    /* Board management notifications */
    GPON_ALIVE_NTF_CODE                      = 0x20,
    GPON_RESTART_NTF_CODE                    = 0x21,
    GPON_ONU_DETECT_NTF_CODE                 = 0x22,
    GPON_PM_GEM_NTF_CODE                     = 0x23,
    GPON_DIAG_NTF_CODE                       = 0x24,
    /* 0x25, 0x26 reserved for xgpon notifications */
    GPON_DIAG_ACTIVE_NTF_CODE                = 0x27,
    GPON_POPUP_INPRG_NTF_CODE                = 0x28,
    GPON_ONU_TEQ_NTF_CODE                    = 0x29,

    /* more commands */
    GPON_SNIPER_ENABLE_CMD_CODE              = 0x30,
    GPON_SWO_PROV_CMD_CODE                   = 0x31,
//  GPON_SWO_ADM_STATE_CMD_CODE              = 0x32,
//  GPON_MANUAL_SWO_CMD_CODE                 = 0x33,
    GPON_SWO_STATUS_CMD_CODE                 = 0x34,
    GPON_SET_PROFILE_CMD_CODE                = 0x35,
    ENA_DISABLE_AES_CMD_CODE            = 0x36,
    GPON_LOID_AUTH_STAT_CMD_CODE             = 0x37,
    GPON_DEL_STANDBY_PROV_CMD_CODE           = 0x3A,
    GPON_MANUAL_SWO2_CMD_CODE                = 0x3B,

    /* T&D console traffic */
    GPON_CONSOLE_MESSAGE                     = 0x40,
    GPON_CONSOLE_GPON_RESPONSE                    = 0x41,

    /* time of day exchange */
    GPON_GLOB_TIME_REQUEST                   = 0x42,
    GPON_PLT_TIME_GPON_RESPONSE                   = 0x43,

    /* additional commands */
    GPON_ONU_SYNC_NTF_CODE                   = 0x44,
    GPON_PON_SYNC_NTF_CODE                   = 0x45,
    ONU_SYNC_CMD_CODE                   = 0x46,
    PON_SYNC_CMD_CODE                   = 0x47,
    GPON_SYNC_AUDIT_NTF_CODE                 = 0x48,
    INVALIDATE_ONU_CMD_CODE             = 0x49,

    GPON_DIAG_PARMS_CMD_CODE                 = 0x50,
    GPON_DIAG_IGNORE_ONU_CMD_CODE            = 0x51,
    GPON_COMMIT_TYPE_C_CMD_CODE              = 0x52,
    /*add for CMCC*/
    SEND_GPON_PASSWORD_REQUEST_CODE          = 0x53,
    /* PON utilization feature */
    GPON_PON_UTIL_CMD_CODE                   = 0x54,
    /*send pon-id msg for G984.3 Annex C*/
    GPON_SET_ID_MSG_CMD_CODE            = 0x55,
    /* commands added for Alien Test*/
    GPON_DIAG_ALIEN_TEST_PARMS_CMD_CODE      = 0x56,
    DIAG_ALIEN_NTF_CODE                 = 0x57,
    /*for poke&hope mode, GPON ONUs range*/
    GPON_SET_PON_RANGE_MODE                  = 0x58,
    GPON_SET_PONLOS_ALARM_CTRL             = 0x59,
    GPON_DIAG_IS_ELIGIBLE_FOR_TEST       = 0x5c,

    GPON_ERR_PRINTF_NTF_CODE                 = 0x70,
    GPON_LISTEN_FOR_ZYNQ_UPGRADE             = 0x71,
	SET_RESPONSE_CMD_CODE               = 0x72,
    MBX_MAX_CMD_CODE

} GPON_MESSAGE_CODE;
"""

rule = re.compile('(.*)=(.*),')

def _split(content):
    result = {}
    for line in content.split('\n'):
        if len(line.strip()) < 1:
            continue

        match = rule.search(line.strip())
        if not match:
            continue

        result[match.group(2).strip()] = match.group(1).strip()
    return result

leftitems = _split(left)
rightitems = _split(right)

print(f'left size: {len(leftitems)}, right size: {len(rightitems)}')

total = 0
for id, name in rightitems.items():
    if id in leftitems:
        print(f'command id ({id}), names ({name}, {leftitems[id]})')
        total += 1

print('total commands: %d' % total)

print('--done!!')

