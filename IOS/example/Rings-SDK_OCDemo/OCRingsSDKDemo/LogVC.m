//
//  LogVC.m
//  OCRingsSDKDemo
//
//  Created by JianDan on 2025/3/5.
//

#import <RingsSDK/RingsSDK.h>
#import "LogVC.h"
@interface LogVC ()


@property (strong, nonatomic) NSTimer *logTimer;
@end

@implementation LogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self readLog];
}

- (void)clearTodayLog
{
    [self clearTodayLogFileAtPath:nil];
}

- (void)readLog {
    // 停止已存在的定时器
    [self.logTimer invalidate];

    // 创建新的定时器，每0.25秒读取一次日志
    self.logTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                    repeats:YES
                                                      block:^(NSTimer *_Nonnull timer) {
        if (!self.log_TV) {
            NSLog(@"⚠️ log_TV 未正确初始化");
            return;
        }

        NSString *logContent = [self readLogContentAtPath:nil
                                                 fileName:nil];

        if (logContent) {
            // 如果内容相同，不需要更新
            if ([self.log_TV.text isEqualToString:logContent]) {
                return;
            }

            self.log_TV.text = logContent;
            // 滚动到底部
            dispatch_async(dispatch_get_main_queue(), ^{
                               NSRange range = NSMakeRange(self.log_TV.text.length - 1, 1);
                               [self.log_TV scrollRangeToVisible:range];
                           });
        } else {
            NSLog(@"⚠️ 未能读取到日志内容");
        }
    }];
}

+ (NSString *)defaultLogDirectoryPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

- (nullable NSString *)readLogContentAtPath:(nullable NSString *)directoryPath
                                   fileName:(nullable NSString *)fileName {
    // 使用默认目录路径（如果未指定）
    NSString *finalDirectoryPath = directoryPath ? : [LogVC defaultLogDirectoryPath];

    // 确定最终的文件名
    NSString *finalFileName;

    if (fileName.length > 0) {
        finalFileName = fileName;
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        finalFileName = [NSString stringWithFormat:@"%@.log", dateString];
    }

    // 构建完整的文件路径
    NSString *logFilePath = [finalDirectoryPath stringByAppendingPathComponent:finalFileName];

    // 检查文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        NSLog(@"⚠️ 日志文件不存在: %@", logFilePath);
        return @"";
    }

    NSError *error = nil;
    // 读取文件内容
    NSString *content = [NSString stringWithContentsOfFile:logFilePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];

    if (error) {
        NSLog(@"⚠️ 读取日志文件出错: %@", error);
        return @"";
    }

    return content;
}

- (BOOL)clearTodayLogFileAtPath:(nullable NSString *)directoryPath {
    NSString *finalDirectoryPath = directoryPath ? : [LogVC defaultLogDirectoryPath];

    // 生成今天的日志文件名
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.log", dateString];

    NSString *logFilePath = [finalDirectoryPath stringByAppendingPathComponent:fileName];

    // 检查文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        NSLog(@"⚠️ 当日日志不存在：%@", logFilePath);
        return NO;
    }

    // 删除文件
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&error];

    if (!success) {
        NSLog(@"⚠️ 删除日志文件出错：%@", error);
    }

    return success;
}

- (void)dealloc {
    [self.logTimer invalidate];
    self.logTimer = nil;
}

@end
