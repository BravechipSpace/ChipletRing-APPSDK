//
//  amOTA.h
//
//  @brief Application Programming Interface Header File for OTA Profile.
//
//  Created by ViewTool on 11/30/2016.
//  Copyright (c) 2016 ViewTool. All rights reserved.
//
/*
 *
 * ver 0.1 : speed: about 3K Bps.
 *
 * ver 0.2 : optimize speed.
 * ver 0.3 : add pause/setup brick length.
 */


#ifndef AM_OTA_h
#define AM_OTA_h

#include <stdio.h>
#include <stdint.h>
#include <string.h>


#define BLE_4_0_MTU_LEN    (20)


/// OTA the UUID of the service

/*
 ota
 svc : 00002760-08C2-11E1-9073-0E8AC72E1001
 Rx  : 00002760-08C2-11E1-9073-0E8AC72E0001
 Tx  : 00002760-08C2-11E1-9073-0E8AC72E0002
 */

#define UUID_AMOTA_SERVICE         @"00002760-08C2-11E1-9073-0E8AC72E1001"

/// OTA the UUID of char for write
#define UUID_AMOTA_CHAR_FOR_WRITE  @"00002760-08C2-11E1-9073-0E8AC72E0001"

/// OTA the UUID of char for notify
#define UUID_AMOTA_CHAR_FOR_NOTIFY @"00002760-08C2-11E1-9073-0E8AC72E0002"



//#define Tranverse32(X) ((((int32_t)(X)&0xff000000) >> 24)|(((int32_t)(X)&0x00ff0000) >> 8)|(((int32_t)(X)&0x0000ff00) << 8) | (((int32_t)(X)&0x000000ff) << 24))
//
//#define Tranverse16(X) ((((int16_t)(X)&0xff00) >> 8)|(((int16_t)(X)&0x00ff) << 8))
//
//#define SET_UINT16_2_LE(addr, x) do{((uint8_t *)(addr))[0] = (x) >> 0; \
//                                ((uint8_t *)(addr))[1] = (x) >> 8;}while(0)
//
//#define GET_UINT16_2_LE(addr)    (((uint16_t)(((uint8_t *)(addr))[0]) << 0) | \
//                                ((uint16_t)(((uint8_t *)(addr))[1]) << 8))

//#if _BACKUP_CODE
//#define BYTES_TO_UINT32(n, p)     {n = ((uint32_t)(p)[0] + ((uint32_t)(p)[1] << 8) + \
//    ((uint32_t)(p)[2] << 16) + ((uint32_t)(p)[3] << 24));}
//
//#define UINT32_TO_BSTREAM(p, n)   {*(p)++ = (uint8_t)(n); *(p)++ = (uint8_t)((n) >> 8); \
//    *(p)++ = (uint8_t)((n) >> 16); *(p)++ = (uint8_t)((n) >> 24);}
//
//#define UINT32_TO_BSTREAM_L(p, n)  {*(p)++ = (uint8_t)((n) >> 24); *(p)++ = (uint8_t)((n) >> 16); \
//*(p)++ = (uint8_t)((n) >> 8); *(p)++ = (uint8_t)((n) >> 0);}
//#endif

/// start
/* RFU=Reserved for Future Usage*/
enum metaDataFormat
{
    mdfEncrptionFlag,/*Encrption flag (RFU) 
                             0 = non-encrypted. (default)
                             other = reserved.*/
    mdfLoadAddr=0x04, /* Load address. (execution image start address.) */
    mdfBinLength=0x08, /* Binary length (bytes) Length of raw binary file in bytes. */
    mdfCRCValue=0x0c, /* CRC value of the raw binary. */
    mdfOverrideGPIO=0x10,/* Override GPIO, GPIO number assigned as the override GPIO for bootloader. */
    mdfOverridePolarity=0x14,/* Override polarity, polarity that holds the bootloader in serial port listening mode. */
    mdfAppSP=0x18,/* Application stack pointer (SP). (a copy from raw binary) */
    mdfAppPC=0x1c,/* Application reset vector (PC). (a copy from raw binary) */
    mdfAppSWVer=0x20,/* Application software version.  */
    mdfBinType=0x24,/* Binary type (execution image or data only) (RFU) */
    mdfRFU0=0x28,/* Storage type (internal or external flash) (RFU)
                  0 = internal flash (default)
                  1 = external flash */
    mdfRFU1=0x2c,/* RFU RFU=Reserved for Future Usage */
    mdfBinRaw=0x30,/* Actual binary data starting in raw format starts from here. */
};

/*
 Characteristic Descriptors
 Characteristic User Description
 This characteristic descriptor defines the AM OTA version with read permission property.
 Client Characteristic Configuration Descriptor
 The notification characteristic will start to notify if the value of the CCCD (Client Characteristic Configuration Descriptor) is set to 0x0001 by client. The send data characteristic will  stop notifying if the value of the CCCD is set to 0x0000 by client.
 
 Service Behaviors
	•	OTA client sends firmware header/meta info to server on amota packet format
	•	Server replies with received byte counters
	•	OTA client starts to send firmware data by amota packet format
	•	Server replies with received byte counters
	•	OTA client sends verify command to ask server to calculate the whole firmware checksum
	•	Server replies checksum result to client
	•	Client sends reset command to server (APP behavior)
	•	Server sends reset command response to server before reset (APP behavior)
 AMOTA packet format
 Length : two bytes (data + checksum)
 Cmd : 1 byte
 Data : 0 ~ 512 bytes
 Checksum : 4 bytes
 
 | Length | Command | Data       | Checksum |
 | 2Bytes | 1Byte   | 0~512Bytes | 4Bytes   |
 
 */
/// AB-OTA
#define AMOTA_HEADER_DATA_LENGTH     (24)
#define AMOTA_LENGTH_SIZE            (2)
#define AMOTA_CMD_SIZE               (1)
#define AMOTA_CS_SIZE                (4)

#define OTA_BRICK_SIZE_DEF           (512) // (400) // default of brick size. 

#define _ENABLE_SUB_THREAD         (0)

typedef enum
{
    PKG_LENG_0,
    PKG_LENG_1,
    PKG_LENG_MAX
}eAmotaPkgLength;

typedef enum
{
    PKG_CMD_0,
    PKG_CMD_MAX
}eAmotaCmdInPkg;

typedef enum
{
    PKG_Data_0,
    PKG_Data_MAX=512
}eAmotaDataInPkg;

typedef enum
{
    PKG_CS_0,
    PKG_CS_1,
    PKG_CS_2,
    PKG_CS_3,
    PKG_CS_MAX
}eAmotaCSInPkg;

/// Commands:
/* amota commands */
typedef enum
{
    AMOTA_CMD_UNKNOWN,
    AMOTA_CMD_FW_HEADER,
    AMOTA_CMD_FW_DATA,
    AMOTA_CMD_FW_VERIFY,
    AMOTA_CMD_FW_RESET,
    AMOTA_CMD_MAX
}eAmotaCommand;

typedef enum
{
    AMOTA_STATE_IDLE,
    AMOTA_STATE_HEADER,
    AMOTA_STATE_DATA_START,
    AMOTA_STATE_DATA_CARRYING,
    AMOTA_STATE_DATA_END,
    AMOTA_STATE_VERIFY,
    AMOTA_STATE_RESET,
    AMOTA_STATE_MAX
}eAmotaState;

/*
FW Header Info
Amota packet header (two bytes length + 1 byte cmd)
Version 4 bytes;
Firmware/Data size 4 bytes;
CRC32 4 bytes;
Start address in flash 4 bytes;
Byte counter for retransmitting 4 bytes;
Data Type 4 bytes;
Amota packet checksum (4 bytes)

FW Data Packet
Amota packet header (two bytes length + 1 byte cmd)
Data : 0 ~ 512 bytes
Amota packet checksum (4 bytes)

FW Verify Command
Amota packet header (two bytes length + 1 byte cmd)
Amota packet checksum (4 bytes)

Target Reset Command
Amota packet header (two bytes length + 1 byte cmd)
Amota packet checksum (4 bytes)

Command Response Format
Length : 2 bytes (data + status)
Cmd : 1 byte
Status : 1 byte
Data : 0 ~ 16 bytes
*/
/* amota status */
//typedef enum
//{
//    AMOTA_STATUS_SUCCESS,
//    AMOTA_STATUS_CRC_ERROR,
//    AMOTA_STATUS_INVALID_HEADER_INFO,
//    AMOTA_STATUS_INVALID_PKT_LENGTH,
//    AMOTA_STATUS_INSUFFICIENT_BUFFER,
//    AMOTA_STATUS_UNKNOWN_ERROR,
//    AMOTA_STATUS_MAX
//}eAmotaStatus;
/*
FW Header Info Response & FW Data Response
Amota packet header (two bytes length + 1 byte cmd)
Status : 1 byte
Received packet counter : 4 bytes

FW Verify & Target Reset Response
Amota packet header (two bytes length + 1 byte cmd)
Status : 1 byte
*/

typedef enum {
    OTA_RSP_LENGTH_L,  // command rsp format: length low
    OTA_RSP_LENGTH_H,  // command rsp format: length high
    OTA_RSP_CMD,       // command rsp format: command
    OTA_RSP_STATUS,    // command rsp format: status
    OTA_RSP_DATA0,     // command rsp format: data0
    OTA_RSP_DATA1,     // command rsp format: data1
    OTA_RSP_DATA2,     // command rsp format: data2
    OTA_RSP_DATA3,     // command rsp format: data3.
    OTA_RSP_MAX,       // command rsp format: data3.
}eCmdRspFormat;

#endif
