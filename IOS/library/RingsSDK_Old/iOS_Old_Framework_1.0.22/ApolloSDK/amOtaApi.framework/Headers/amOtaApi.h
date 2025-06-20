//
//  amotaApi.h
//  OtaDemo
//
//  @brief Application Programming Interface Header File for OTA Profile.
//
//  Created by ViewTool on 11/30/2016.
//  Copyright (c) 2016 ViewTool. All rights reserved.
//
//

#ifndef AMOTA_TASK_h
#define AMOTA_TASK_h

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

/// to lib
#define UUID_AMOTA_SERVICE                @"00002760-08C2-11E1-9073-0E8AC72E1001"

/// to notify discovered Services to app layer
#define keyAmotaPeripheral                @"key-AmotaPeripheral"
#define keyAmotaEnableConfirm             @"key-AmotaEnableConfirmStatus"

#define aMotaEnableConfirmNoti            @"aMota-EnableConfirmNoti"

/// never change them from client start!
/// to notify discovered Charas to api layer
#define bleDiscoveredCharToOtaApiNoti              @"ble-DiscoveredCharToOtaApi-Noti"
#define keyBleDiscvrdCharForPeriNoti               @"key-BleDiscoveredCharForPeriNoti"
#define keyBleDiscvrdCharForServiceNoti            @"key-BleDiscoveredCharForServiceNoti"
#define keyBleDiscvrdCharForErrorNoti              @"key-BleDiscoveredCharForErrorNoti"

/// to update value of char to api layer
#define bleUpdateValueCharToOtaApiNoti             @"ble-UpdateValueCharToOtaApi-Noti"
#define keyBleUpdateValueCharToOtaForPeriNoti      @"key-BleUpdateValueCharToOtaForPeri-Noti"
#define keyBleUpdateValueCharToOtaForServiceNoti   @"key-BleUpdateValueCharToOtaForService-Noti"
#define keyBleUpdateValueCharToOtaForCharNoti      @"key-BleUpdateValueCharToOtaForChar-Noti"
#define keyBleUpdateValueCharToOtaForErrorNoti     @"key-BleUpdateValueCharToOtaForError-Noti"
/// never change them,from client end !

/**
 ****************************************************************************************
 * @brief OTA Api load file result.
 *
 ****************************************************************************************
 */
typedef enum
{
    OTA_FW_ERROR = -1,
    OTA_FW_NO_ERROR,
}eLoadFileResult;


typedef enum
{
    OTA_CONFIRM_FALSE,
    OTA_CONFIRM_TRUE,
}eAmotaEnableResult;

///// OTA api result during transfering data
typedef enum
{
    AMOTA_STATUS_SUCCESS,
    AMOTA_STATUS_CRC_ERROR,
    AMOTA_STATUS_INVALID_HEADER_INFO,
    AMOTA_STATUS_INVALID_PKT_LENGTH,
    AMOTA_STATUS_INSUFFICIENT_BUFFER,
    AMOTA_STATUS_INSUFFICIENT_FLASH,
    AMOTA_STATUS_UNKNOWN_ERROR,
    AMOTA_STATUS_MAX
}eAmotaStatus;

typedef enum
{
    AMOTA_CMD_VERIFY,  /// user to verify code.
    AMOTA_CMD_RESET,   /// user to reset device
}eAmotaUserCmd;

typedef enum
{
    AMOTA_PAUSE_NONE,           /// normally OTA.
    AMOTA_PAUSE_REQ,            /// user to pause ota.
    AMOTA_PAUSE_RESUME,         /// user to resume ota.
    AMOTA_PAUSE_FILE_RELOADED,  /// user to use reloaded file.
}ePauseReq;

/// ota Api output to app delegate protocol
@protocol AmotaApiUpdateAppDataDelegate

/***
 ****************************************************************************************
 * @brief       Update the result of the header data sent.
 *
 * @param[out]  otaMetaDataSentStatus : the status of the meta data sent. 
 *
 * @ref          eAmotaStatus definitions
 *
 * @return : none
 ****************************************************************************************
 */
-(void)didAmOtaFwHeaderRsp : (eAmotaStatus)svrStatus;

/**
 ****************************************************************************************
 * @brief       Update the result of the package sent.
 *
 * @param[out]  pkgStatusSent : the status of the package sent.
 * @param[out]  length          : nsdata with these values (eAmotaStatus).
 *
 * @ref          eAmotaStatus definitions
 *
 * @return : none
 ****************************************************************************************
 */
-(void)didAmOtaFwDataRsp : (eAmotaStatus)pkgSentStatus
           withDataLengthSent : (uint32_t)length;

/**
 ****************************************************************************************
 * @brief OTA Api output the cmd(Verify and reset) response .
 *
 * @param[out]  current command : the command sent by user.
 * @param[out]  status : the status response by device side. 
 *
 * @ref : eAmotaUserCmd about user's command.
 *           eAmotaStatus about status responsed
 ****************************************************************************************
 */
-(void)didAmOtaUserCmdRsp : (eAmotaUserCmd)curCmd withStatus : (eAmotaStatus )status;
@end

/// ota api interface
@interface amOtaApi : NSNotificationCenter
{

}

/// delegate update Ota Result/ ota dataRate/Ota Progressbar value.
@property (nonatomic, retain) id <AmotaApiUpdateAppDataDelegate> amotaApiUpdateAppDataDelegate;
// assign.

/**
 *****************************************************************
 * @brief app register OTA's peripheral UUID and service UUID to Api layer.
 *
 * @param[in]  aPeripheral    : the peripheral connected.
 * @param[in]  otaServiceUUID : the service UUID to discover.
 *
 * @return none
 *****************************************************************
 */
- (void) amOtaEnable : (CBPeripheral *)aPeripheral withServiceUUID : (NSString *)aUUID;

/**
 ****************************************************************************************
 * @brief setup brick data size.
 * @param _length: the length is set by user, it MUST be set as multiple of 4 Bytes.
 ****************************************************************************************
 */
-(void)amOtaSetupBrickSize : (uint16_t)_length;

/**
 ****************************************************************************************
 * @brief  to load new firmware .
 *
 * @param[in]  aPeripheral    : the OTA peripheral connected.
 * @param[in]  fwAddr   : the firmware header address.
 * @param[in]  fwLength : the firmware length.
 *
 * @return     Result : Failed ( = OTA_FW_ERROR)
 *                          Success ( = OTA_FW_NO_ERROR)
 *
 * @ref    eLoadFileResult definition
 ****************************************************************************************
 */ 

-( eLoadFileResult)amOtaStart : (CBPeripheral *)aPeripheral
              withDataByte : (const uint8_t *)fwAddr
                withLength : (uint32_t)fwLength ;


/**
 ****************************************************************************************
 * @brief pause OTA action of transferring brick data instead of header data!
 * @param aPeripheral : OTA peripheral.
 * @param _userReq : means pause/continue to download data/new data.
                         @see ePauseReq
 ****************************************************************************************
 */
-(void)amOtaPause : (CBPeripheral *)aPeripheral withReq : (ePauseReq)_userReq;

/**
 ****************************************************************************************
 * @brief to verify firmware code have been sent .
 *
 * @param[in]  aPeripheral    : the OTA peripheral connected.
 *
 * @return    none.
 *                firmware repsonse to @ref didAmOtaUserCmdRsp
 *
 ****************************************************************************************
 */
-(void)amOtaFwVerify : (CBPeripheral *)aPeripheral;

/**
 ****************************************************************************************
 * @brief  to reset deivce.
 *
 * @param[in]  aPeripheral    : the OTA peripheral connected.
 *
 * @return    none.
 *                firmware repsonse to @ref didAmOtaUserCmdRsp
 *
 ****************************************************************************************
 */
-(void)amOtaReset : (CBPeripheral *)aPeripheral ;

/**
 ****************************************************************************************
 * @brief  to get fw info .
 *
 * @param[in]  fwAddr   : the firmware header address.
 * @param[in]  fwLength : the firmware length.
 *
 * @return     firmware code length
 *
 ****************************************************************************************
 */
-(NSData *)vGetFwHeaderInfo : (const uint8_t *)fwAddr
                    withLength : (uint32_t)fwLength;

/**
 ****************************************************************************************
 * @brief OTA class method.
 *
 * @param[out] all methods
 *
 ****************************************************************************************
 */
+ (amOtaApi *)sharedInstance;

@end

#endif
