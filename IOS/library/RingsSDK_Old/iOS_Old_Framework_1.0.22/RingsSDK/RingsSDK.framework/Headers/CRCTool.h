//
//  CRCTool.h
//  Rings
//
//  Created by weicb on 2023/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRCTool : NSObject
+ (NSInteger)crc:(NSArray *)datas seed:(unsigned short)seed;
@end

NS_ASSUME_NONNULL_END
