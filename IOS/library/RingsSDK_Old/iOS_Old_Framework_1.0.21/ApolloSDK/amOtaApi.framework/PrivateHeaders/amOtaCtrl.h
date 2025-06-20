//
//  amOtaCtrl.h
//  amOta demo
//
//  Created by Mark on 15-12-16.
//  Copyright (c) 2016 Viewtool. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

#import "amOta.h"
#import "amOtaApi.h"

@interface amOtaCtrl : NSObject{
    
}


@property (nonatomic, readwrite) CBPeripheral *amPeri;
@property (nonatomic, readwrite) CBCharacteristic *wrChar;

@property (nonatomic, readwrite) eAmotaState masterState;
@property (nonatomic, readwrite) uint16_t brickLength;        /// for brick data size.

@property (nonatomic, readwrite) uint16_t amFwHeaderSize;        /// fw header size.
@property (nonatomic, readwrite) NSData *pubAmFwHeaderBuf;        /// Fw Meta Data Buffer

@property (nonatomic, readwrite) uint32_t amFwTotalDataSize;  /// Fw data Buffer
@property (nonatomic, readwrite) NSData *amFwTotalDataBuf;     /// Fw Data Buffer

@property (nonatomic, readwrite) uint32_t amOtaBrickDataSize; /// brick data size.
@property (nonatomic, readwrite) uint32_t masterPkgs;         /// record sent pkg count at master side.

@property (nonatomic, readwrite) uint32_t serverPkgs;          /// received pkg counter at server side.

@property (nonatomic, readwrite) ePauseReq ePause;                 /// pause ota or not.

#if _ENABLE_SUB_THREAD
@property (nonatomic, readwrite) BOOL fWritingLoop;
#endif

// server request
@property (nonatomic, readwrite) uint8_t svrCmd,svrPkgLength;
@property (nonatomic, readwrite) eAmotaStatus svrStatus;    /// output ota status to app layer.

+(amOtaCtrl *)sharedInst;

@end
