//
//  ViewController.m
//  OCRingsSDKDemo
//
//  Created by JianDan on 2025/3/5.
//

#import <RingsSDK/RingsSDK.h>
#import "DeviceTableVC.h"
#import "LogVC.h"
#import "OCRingsSDKDemo-Swift.h"
#import "ViewController.h"
@interface ViewController ()

@property (nonatomic, strong) LogVC *logVC;
@property (nonatomic, strong) DeviceTableVC *deviceVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.logVC clearTodayLog];

    [[BCLRingManager shared] setupConnectionStateMonitorWithStateChanged:^(BOOL isConnected) {
        if (isConnected) {
            [BDLog info:@"设备已连接"];
        } else {
            [BDLog info:@"设备已断开"];
        }
    }];
}

- (IBAction)btnAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 1000: {
            [BDLog info:@"扫描蓝牙设备"];
            [self.navigationController pushViewController:self.deviceVC animated:true];
            break;
        }

        case 1001:{
            [BDLog info:@"断开连接"];
            [[BCLRingManager shared] stopScan];
            break;
        }

        case 1002:{
            [BDLog info:@"同步时间"];
            //  东8区
            [[BCLRingManager shared] syncDeviceTimeWithTimeZoneWithDate:[NSDate date]
                                                               timeZone:RingTimeZoneEast8
                                                             completion:^(BOOL success, NSString *_Nullable message) {
                if (success) {
                    [BDLog info:@"同步时间成功"];
                } else {
                    [BDLog info:[NSString stringWithFormat:@"同步时间失败：%@", message]];
                }
            }];
//            [[BCLRingManager shared] syncDeviceTimeWithDate:[NSDate date]
//                                                 completion:^(BOOL success, NSString *_Nullable message) {
//                if (success) {
//                    [BDLog info:@"同步时间成功"];
//                } else {
//                    [BDLog info:[NSString stringWithFormat:@"同步时间失败：%@", message]];
//                }
//            }];
            break;
        }

        case 1003:{
            [BDLog info:@"读取时间"];
            [[BCLRingManager shared] readDeviceTimeWithCompletion:^(BOOL success, double timestamp) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"读取时间成功：%f", timestamp]];
                } else {
                    [BDLog info:@"读取时间失败"];
                }
            }];
            break;
        }

        case 1004:{
            [BDLog info:@"读取步数"];
            [[BCLRingManager shared] readStepsCountWithCompletion:^(BOOL success, NSInteger steps) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"读取步数成功：%ld步", (long)steps]];
                } else {
                    [BDLog info:@"读取步数失败"];
                }
            }];
            break;
        }

        case 1005:{
            [BDLog info:@"清除步数"];
            [[BCLRingManager shared] clearStepsCountWithCompletion:^(BOOL success) {
                if (success) {
                    [BDLog info:@"清除步数成功"];
                } else {
                    [BDLog info:@"清除步数失败"];
                }
            }];
            break;
        }

        case 1006:{
            [BDLog info:@"获取电量"];
            [[BCLRingManager shared] readBatteryLevelWithCompletion:^(BOOL success, NSInteger level) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"电池电量：%ld%%", (long)level]];
                } else {
                    [BDLog info:@"读取电池电量失败"];
                }
            }];
        }

        case 1007:{
            [BDLog info:@"充电状态"];
            [[BCLRingManager shared] readChargeStatusWithCompletion:^(BOOL success, ChargeStatus status) {
                if (success) {
                    switch (status) {
                        case ChargeStatusFull:
                            [BDLog info:@"充电状态：已充满"];
                            break;

                        case ChargeStatusCharging:
                            [BDLog info:@"充电状态：充电中"];
                            break;

                        case ChargeStatusNotCharging:
                            [BDLog info:@"充电状态：未充电"];
                            break;
                    }
                } else {
                    [BDLog info:@"读取充电状态失败"];
                }
            }];
            break;
        }

        case 1008:{
            [BDLog info:@"体温"];
            [[BCLRingManager shared] readTemperatureWithCompletion:^(BOOL success, NSInteger temperature) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"设备温度：%.1f°C", temperature *0.01]];
                } else {
                    [BDLog info:@"读取温度失败"];
                }
            }];
            break;
        }

        case 1009:{
            [BDLog info:@"实时血氧"];
            [[BCLRingManager shared] startO2MeasurementWithProgress:^(double progress) {
                [BDLog info:[NSString stringWithFormat:@"血氧测量进度：%.0f%%", progress * 100]];
            }
                                                           waveData:^(NSInteger sequence, NSInteger count, NSArray<NSNumber *> *data) {
                [BDLog info:[NSString stringWithFormat:@"血氧波形数据 序号:%ld 数量:%ld", (long)sequence, (long)count]];
            }
                                                         completion:^(BOOL success, NSInteger value) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"血氧测量完成：%ld", (long)value]];
                } else {
                    [BDLog info:@"血氧测量失败"];
                }
            }];
            break;
        }

        case 1010:{
            [BDLog info:@"心率变异性"];
            [[BCLRingManager shared] startHRVMeasurementWithProgress:^(double progress) {
                [BDLog info:[NSString stringWithFormat:@"HRV测量进度：%.0f%%", progress * 100]];
            }
                                                            waveData:^(NSInteger sequence, NSInteger count, NSArray<NSNumber *> *data) {
                [BDLog info:[NSString stringWithFormat:@"HRV波形数据 序号:%ld 数量:%ld", (long)sequence, (long)count]];
            }
                                                          completion:^(BOOL success, NSInteger value) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"HRV测量完成：%ld", (long)value]];
                } else {
                    [BDLog info:@"HRV测量失败"];
                }
            }];
            break;
        }

        case 1011:{
            [BDLog info:@"实时心率"];
            [[BCLRingManager shared] startHeartRateMeasurementWithRrTime:50
                                                                progress:^(double progress) {
                [BDLog info:[NSString stringWithFormat:@"心率测量进度：%.0f%%", progress * 100]];
            }
                                                                  rrData:^(NSInteger sequence, NSInteger count, NSArray<NSNumber *> *data) {
                [BDLog info:[NSString stringWithFormat:@"RR数据 序号:%ld 数量:%ld", (long)sequence, (long)count]];
            }
                                                               heartRate:^(NSInteger value) {
                [BDLog info:[NSString stringWithFormat:@"实时心率：%ld", (long)value]];
            }
                                                              completion:^(BOOL success, NSInteger value) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"心率测量完成：%ld", (long)value]];
                } else {
                    [BDLog info:@"心率测量失败"];
                }
            }];
            break;
        }

        case 1012:{
            [BDLog info:@"清除数据"];
            [[BCLRingManager shared] clearRingDataWithCompletion:^(BOOL success) {
                if (success) {
                    [BDLog info:@"清除戒指数据成功"];
                } else {
                    [BDLog info:@"清除戒指数据失败"];
                }
            }];
            break;
        }

        case 1013:{
            [BDLog info:@"获取全部数据"];
            [[BCLRingManager shared] readAllHistoryDataWithProgress:^(double progress, RingDataModel *data) {
                [BDLog info:[NSString stringWithFormat:@"读取进度：%.0f%%", progress * 100]];
                [BDLog info:[NSString stringWithFormat:@"时间戳：%u", data.timestamp]];
                [BDLog info:[NSString stringWithFormat:@"心率：%ld", (long)data.rate]];
                [BDLog info:[NSString stringWithFormat:@"血氧：%ld", (long)data.O2]];
                [BDLog info:[NSString stringWithFormat:@"HRV：%ld", (long)data.hrv]];
                [BDLog info:[NSString stringWithFormat:@"步数：%d", data.stepsOfTheDay]];
                [BDLog info:[NSString stringWithFormat:@"温度：%.2f", data.temp]];
                [BDLog info:[NSString stringWithFormat:@"运动强度：%.ld", data.isRunning]];
                [BDLog info:[NSString stringWithFormat:@"RRNumber：%ld", data.RRNums]];
                [BDLog info:[NSString stringWithFormat:@"RRS：%@", data.rrs]];
            }
                                                         completion:^(BOOL success) {
                if (success) {
                    [BDLog info:@"读取所有历史数据完成"];
                } else {
                    [BDLog info:@"读取所有历史数据失败"];
                }
            }];
            break;
        }

        case 1014:{
            [BDLog info:@"读取未上传数据记录"];
            [[BCLRingManager shared] readNewHistoryDataWithProgress:^(double progress, RingDataModel *data) {
                [BDLog info:[NSString stringWithFormat:@"读取进度：%.0f%%", progress * 100]];
                [BDLog info:data.description]; // 直接使用模型的 description 方法
            }
                                                         completion:^(BOOL success) {
                if (success) {
                    [BDLog info:@"读取未上传数据记录完成"];
                } else {
                    [BDLog info:@"读取未上传数据记录失败"];
                }
            }];
            break;
        }

        case 1015:{
            [BDLog info:@"固件版本"];
            [[BCLRingManager shared] readAppVersionWithCompletion:^(BOOL success, NSString *_Nullable version) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"固件版本：%@", version]];
                } else {
                    [BDLog info:@"读取固件版本失败"];
                }
            }];
            break;
        }

        case 1016:{
            [BDLog info:@"硬件版本"];
            [[BCLRingManager shared] readHardwareVersionWithCompletion:^(BOOL success, NSString *_Nullable version) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"硬件版本：%@", version]];
                } else {
                    [BDLog info:@"读取硬件版本失败"];
                }
            }];
            break;
        }

        case 1017:{
            [BDLog info:@"睡眠数据"];
            RingSleepModel *sleepData = [[BCLRingManager shared] calculateSleepForDate:[NSDate date]];

            if (sleepData) {
                // 零星睡眠时间
                [BDLog info:[NSString stringWithFormat:@"零星睡眠时间：%ld小时%ld分钟",
                             (long)sleepData.hours, (long)sleepData.minutes]];

                // 总睡眠时间
                [BDLog info:[NSString stringWithFormat:@"总睡眠时间：%ld小时%ld分钟",
                             (long)sleepData.allHours, (long)sleepData.allMinutes]];

                // 实际睡眠时间
                [BDLog info:[NSString stringWithFormat:@"实际睡眠时间：%ld小时%ld分钟",
                             (long)sleepData.sleepHours, (long)sleepData.sleepMinutes]];

                // 各阶段睡眠时间（转换为分钟）
                [BDLog info:[NSString stringWithFormat:@"深度睡眠：%lld分钟", sleepData.highTime / 60]];
                [BDLog info:[NSString stringWithFormat:@"浅度睡眠：%lld分钟", sleepData.lowTime / 60]];
                [BDLog info:[NSString stringWithFormat:@"眼动时间：%lld分钟", sleepData.ydTime / 60]];
                [BDLog info:[NSString stringWithFormat:@"清醒时间：%lld分钟", sleepData.qxTime / 60]];

                // 睡眠时间范围
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:sleepData.startTime];
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:sleepData.endTime];

                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

                [BDLog info:[NSString stringWithFormat:@"入睡时间：%@",
                             [formatter stringFromDate:startDate]]];
                [BDLog info:[NSString stringWithFormat:@"清醒时间：%@",
                             [formatter stringFromDate:endDate]]];

                // 详细睡眠数据
                [BDLog info:[NSString stringWithFormat:@"睡眠数据记录数：%lu",
                             (unsigned long)sleepData.sleepDataList.count]];
                [BDLog info:@"-----------------------------------------------"];

                // 遍历详细睡眠数据
                for (RingDataModel *data in sleepData.sleepDataList) {
                    [BDLog info:[NSString stringWithFormat:@"时间戳：%u", data.timestamp]];
                    [BDLog info:[NSString stringWithFormat:@"睡眠类型：%d", data.sleepType]];
                    // 可以根据需要输出其他数据...
                }
            } else {
                [BDLog info:@"获取睡眠数据失败"];
            }

            break;
        }

        case 1018:{
            [BDLog info:@"设置采集周期"];

            [[BCLRingManager shared] setFrequencyWithTime:60
                                               completion:^(BOOL success) {
                if (success) {
                    [BDLog info:@"设置采集频率成功"];
                } else {
                    [BDLog info:@"设置采集频率失败"];
                }
            }];
            break;
        }

        case 1019:{
            [BDLog info:@"读取采集周期"];
            [[BCLRingManager shared] readFrequencyWithCompletion:^(BOOL success, NSInteger frequency) {
                if (success) {
                    [BDLog info:[NSString stringWithFormat:@"当前采集频率：%ld秒", (long)frequency]];
                } else {
                    [BDLog info:@"读取采集频率失败"];
                }
            }];
            break;
        }

        case 1020:{
            [BDLog info:@"恢复出厂设置"];
            [[BCLRingManager shared] resetDeviceWithCompletion:^(BOOL success) {
                if (success) {
                    [BDLog info:@"设备重置成功"];
                    // 可以在这里添加重置后的其他操作
                } else {
                    [BDLog info:@"设备重置失败"];
                }
            }];
            break;
        }

        case 1026:{
            [BDLog info:@"通过指定mac地址链接蓝牙设备"];
            [[BCLRingManager shared] connectDeviceWithMacAddress:@"B0:04:70:00:00:1B"
                                                         timeout:15
                                                      completion:^(BOOL success, NSString *_Nullable deviceName, NSString *_Nullable error) {
                if (success) {
                    [BDLog info:@"连接成功"];
                    [BDLog info:[NSString stringWithFormat:@"设备名称：%@", deviceName]];
                } else {
                    [BDLog info:[NSString stringWithFormat:@"连接失败：%@", error]];
                }
            }];
        }

        default:
            break;
    }
}

- (IBAction)logAction:(id)sender {
    // 展示日志视图控制器
    [self presentViewController:self.logVC animated:YES completion:nil];
}

- (DeviceTableVC *)deviceVC
{
    if (_deviceVC == nil) {
        _deviceVC = [[DeviceTableVC alloc] init];
    }

    return _deviceVC;
}

- (LogVC *)logVC
{
    if (_logVC == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _logVC = [storyboard instantiateViewControllerWithIdentifier:@"LogVC_ID"];
    }

    return _logVC;
}

@end
