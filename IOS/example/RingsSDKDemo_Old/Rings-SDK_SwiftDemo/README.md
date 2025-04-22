

# Rings-SDK

[![CI Status](https://img.shields.io/travis/weicb/Rings-SDK.svg?style=flat)](https://travis-ci.org/weicb/Rings-SDK)
[![Version](https://img.shields.io/cocoapods/v/Rings-SDK.svg?style=flat)](https://cocoapods.org/pods/Rings-SDK)
[![License](https://img.shields.io/cocoapods/l/Rings-SDK.svg?style=flat)](https://cocoapods.org/pods/Rings-SDK)
[![Platform](https://img.shields.io/cocoapods/p/Rings-SDK.svg?style=flat)](https://cocoapods.org/pods/Rings-SDK)

## SDK说明

​	这是智能戒指的蓝牙通信SDK，主要提供与戒指通信相关的API管理类RingManager，以及相关的数据存储管理类RingDBManager，同时也提供部分复杂算法的实现，例如睡眠相关算法。

​	注：由于sdk需要用到蓝牙，仅支持真机调试，且注意在你项目的info中添加蓝牙权限说明

## 环境要求

​	支持 iOS 版本：iOS 13.0+

​	支持的语言版本：Swift 5.0+
​   
​    开发工具: xcode 15+   

## 安装使用

##### 	使用CocoaPods进行管理。首先在你的项目的Podfile文件中新增一个Spec源，即将下面的语句复制粘贴到项目中的Podfile最上方：

```ruby
source 'https://github.com/wcb133/RingSpec.git'
```

然后pod中导入该SDK：

```ruby
pod 'Rings-SDK'
```

最后安装：

```ruby
pod install
```

在使用地方中引入SDK即可：

```swift
import RingsSDK
```



## API说明

### 设备连接相关
#### 搜索附近的蓝牙设备，开始搜索后可通过回调获取搜索到的设备列表，也可通过 RingManager.shared.devices属性获取当前搜索到的设备

```Swift
RingManager.shared.startScan { devices in
        print("搜索到的设备列表 =========>\(String(describing: devices))")
}
```

#### 停止搜索附近的蓝牙设备，停止搜索不会清空已搜索到的设备列表，即不会清空RingManager.shared.devices

```Swift
RingManager.shared.stopScan()
```

#### 通过设备的uuid来连接指定设备，uuid由搜索到的设备模型DeviceInfo中获取

```Swift
RingManager.shared.startConnect(deviceUUID: "uuidString", resultBlock: { res in
            switch res {
            case .success(let deviceInfo):
                print("已连接设备 =========\(String(describing: deviceInfo.peripheralName))")
            case .failure(let error):
                print("连接失败 ========> \(error)")
            }
        })
```

#### 断开当前设备的连接

```Swift
RingManager.shared.disconnect()
```

#### 获取当前已连接的设备

```Swift
let currentDevice = RingManager.shared.currentDevice
```

#### 获取设备连接状态

```Swift
let isDidConnect = RingManager.shared.isDidConnect
```


#### 设备连接状态变化监听

```Swift
RingManager.shared.connectStateChangeBlock = { isConnected in
            print("是否已连接 ========\(isConnected)")
            
        }
```

### 设备通讯相关

#### 同步时间

```Swift
RingManager.shared.syncTime(date: Date()) { res in
                  switch res {
                  case .success(let isSuccess):
                      print("同步时间结果======\(isSuccess)")
                  case .failure(let error):
                      print("同步失败======\(error)")
             }
         }
```

#### 读取时间

```Swift
RingManager.shared.readTime { res in
              switch res {
              case .success(let value):
                  print("成功=====>\(value)毫秒")
              case .failure(let error):
                  print("失败=====>\(error)")
              }
          }
```

#### 读取软件版本号

```Swift
RingManager.shared.readAppVersion { res in
                switch res {
                case .success(let version):
                    print("软件版本号=====>\(version)")
                case .failure(let failure):
                    print("失败=====>\(failure)")
                }
            }
```

#### 读取硬件版本号

```Swift
RingManager.shared.readHardWareVersion { res in
                switch res {
                case .success(let version):
                    print("硬件版本号=====>\(version)")
                case .failure(let failure):
                    print("失败=====>\(failure)")
                }
            }
```

#### 读取电池电量，若返回的电池电量为101，则表示正在充电中

```Swift
RingManager.shared.readBattery { res in
                switch res {
                case .success(let value):
                    print("电量=====>\(value)")
                case .failure(let failure):
                    print("失败=====>\(failure)")
                }
            }
```

#### 读取电池充电状态，返回结果为ChargeStatus枚举类型，值有:

full：充满

charging：充电中

normal：正常未充电状态

```Swift
RingManager.shared.readChargeStatus { res in
                switch res {
                case .success(let state):
                    print("状态=====>\(state)")
                case .failure(let error):
                    print("失败=====>\(error)")
                }
            }
```

#### 输出实时测量心率值，单位BPM。只有当设置isOpenWave为true时，才会读取波形数据，并且通过tableBlock闭包回调。

```Swift
RingManager.shared.readHeartRate(progressBlock: { progress in
                print(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                print("序号 ====>\(seq)")
                print("数据个数 ====>\(num)")
                print("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case .success(let success):
                    print("成功=====>\(success)")
                case .failure(let failure):
                    print("失败=====>\(failure)")
                }
            }
```

#### 输出心率变异性，单位毫秒(ms)。只有当设置isOpenWave为true时，才会读取波形数据，并且通过tableBlock闭包回调。

```Swift
RingManager.shared.readHRV(progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
```

#### 输出实时测量血氧值。只有当设置isOpenWave为true时，才会读取波形数据，并且通过tableBlock闭包回调。

```Swift
RingManager.shared.readO2(progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
```

#### 读取当前温度，返回结果单位为摄氏度(℃)

```Swift
RingManager.shared.readTemperature { res in
                switch res {
                case .success(let value):
                    BDLogger.info("温度=====>\(value)")
                case .failure(let error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
```

#### 读取当天实时步数

```Swift
RingManager.shared.readSteps { res in
                switch res {
                case .success(let value):
                    print("步数=====>\(value)步")
                case .failure(let error):
                    print("失败=====>\(error)")
                }
            }
```

#### 清除实时步数

```Swift
RingManager.shared.clearSteps { res in
                switch res {
                case .success(let isSuccess):
                    print("结果=====>\(isSuccess)")
                case .failure(let error):
                    print("失败=====>\(error)")
                }
            }
```

#### 读取本地历史数据，并且内部会将每一条数据存入到数据库中。关于如何从数据库中获取数据，见数据库管理类RingDBManager部分说明

```Swift
RingManager.shared.readDatas { progress, dataModel in
                print(" 进度 =====>\(progress)==\(dataModel)")
            } resultBlock: { res in
                switch res {
                case .success(let state):
                    print("结果=====>\(state)")
                case .failure(let error):
                    print("失败=====>\(error)")
                }
            }
```

该API获取设备历史数据，每获取到一条历史信息，都会通过progressBlock闭包回调，并在获取全部结果之后，通过resultBlock回调最终结果。其中dataModel为设备数据模型，相关属性如下：

```swift
public final class RingDataModel: NSObject,TableCodable {
    // 总个数
    public var total:UInt32 = 0
    // 序号，1开始
    public var serialNum:UInt32 = 0
    // 时间戳,秒
    public var timestamp:UInt32 = 0
    // 当天截止当前累计步数
    public var stepsOfTheDay:UInt16 = 0
    // 心率,0无效
    public var rate = 0
    // 血氧,0无效
    public var O2 = 0
    // 心率变异性,0无效
    public var hrv = 0
    // 精神压力指数,0无效
    public var mentalStress = 0
    // 温度，有符号的
    public var temp:Float = 0
    // 运动激烈程度 0: 静止  0x65:运动
    public var isRunning = false
    // 睡眠类型 0：无效 1：清醒 2：浅睡 3：深睡 4.眼动期
    public var sleepType = 0
    // RR 期间个数
    public var RRNums = 0
    // RR数组
    public var rrs:[Int] = []
}
```

返回的结果state为ReadDataResult枚举类型，值有: 

```swift
public enum ReadDataResult {
    case empty // 无数据
    case complete // 完成
}
```



#### 删除全部本地数据历史记录

```Swift
RingManager.shared.clearRingData { res in
                switch res {
                case .success(let isSuccess):
                    print("结果=====>\(isSuccess)")
                case .failure(let failure):
                    print("失败=====>\(failure)")
                }
            }
```

#### 采集周期设置，采集周期设置单位为秒(s)

```Swift
RingManager.shared.setFrequency(time: time) { res in
                    switch res {
                    case .success(let isSuccess):
                        print("结果=====>\(isSuccess)")
                    case .failure(let failure):
                        print("失败=====>\(failure)")
                    }
                }
```

#### 采集周期读取，读取到的采集周期为秒(s)

```Swift
RingManager.shared.readFrequency { res in
                switch res {
                case .success(let value):
                    print("成功=====>\(value)秒")
                case .failure(let error):
                    print("失败=====>\(error)")
                }
            }
```

#### 恢复出厂设置

```Swift
RingManager.shared.reset { res in
                switch res {
                case .success(let isSuccess):
                    print("成功=====>\(isSuccess)")
                case .failure(let error):
                    print("失败=====>\(error)")
                }
            }
```

### OTA相关
#### 固件升级，参数fileUrl为固件文件所在的本地路径，升级进度以及结果通过handle进行回调，

```Swift
if let path = Bundle.main.path(forResource: "otafileName", ofType: nil) {
    let url = URL(fileURLWithPath: path)
    RingManager.shared.startOTA(url) { res in
        switch res {
        case .start:
            print("开始升级 =====>")
        case .progress(let value):
            print("升级进度 =====>\(value)")
        case .success:
            print("升级成功 =====>")
        case .fail(let errorString):
            print("升级失败 =====>\(errorString)")
        }
    }
}
```

### 数据库管理类RingDBManager相关
使用 func readDatas(progressBlock: @escaping (Double, RingDataModel)->Void,
                   resultBlock: @escaping (Result<ReadDataResult, ReadError>)->Void)从设备中获取到的本地历史数据，都会被保存到本地数据库中，访问数据库需要使用RingDBManager类，内部提供了一个单例对象用来操作相关数据，单例对象可通过RingDBManager.shared来获取，以下是相关的API说明。

#### 从数据库中获取指定时间到目前为止的所有历史数据，timestamp参数为10位的时间戳

```Swift
public func getObjects(from timestamp:TimeInterval) -> [RingDataModel]
```

#### 从数据库中获取某一天的历史数据（获取到的是该日期当天0时到24时的数据）

```Swift
public func getObjects(of date:Date) -> [RingDataModel]
```

#### 从数据库中获取距离当前时间最近的一条历史数据

```Swift
public func getLatestObject() -> RingDataModel?
```

#### 从数据库中获取某一天的睡眠数据(获取到的是该日期前一天18时到该日期18时的数据)，该部分接口得到的数据主要用于睡眠的计算

```Swift
public func getSleepObjects(of date:Date) -> [RingDataModel]
```

#### 删除本地数据库所有历史数据

```Swift
public func deleteAll() -> Bool
```

#### 删除从指定时间到目前为止的所有历史数据，timestamp参数为10位的时间戳

```Swift
public func deleteAllBeforeTimestamp(timestamp:TimeInterval) -> Bool
```

### 逻辑算法相关

该部分代码在RingManager类中，使用RingManager.shared获取单例，然后调用相关API即可

#### 步行距离计算，steps参数为步数，stepSize参数为步长，单位为厘米(cm)，返回结果为距离，单位为米(m)

```Swift
func calculateDistance(steps:Int,stepSize:Int) -> Float
```

#### 睡眠时间计算，获取指定日期的睡眠数据及零星睡眠数据。返回值是一个元组，元组的第一个元素($0.0)是睡眠数据集合，第二个元素($0.1)是一个二维数组，是多个零星睡眠段的集合。$0.0数组中的第一个数据点的时间为入睡时间，最后一个数据点的时间为醒来时间，中间的各个数据点时间差累加即为睡眠时间。零星睡眠时长计算同理，使用$0.1数组中的数据分段计算即可。

```Swift
func caculateSleepData(targetDate: Date) -> ([RingDataModel], [[RingDataModel]])
```

#### 获取睡眠时长，传入睡眠时间数据点集合，即可得出睡眠时长，返回睡眠时长单位为分钟(min)

```Swift
func calculateSleepTimes(sleepDatas:[RingDataModel]) -> Int
```

### 日志配置
#### 设置日志保存路径，默认保存在沙盒的Document中。可通过以下API修改默认保存路径
```Swift
func configLogPath(directoryPath: String = defaultLogDirectoryPath)
```

### 常见问答Q&A
##### Q：戒指的数据是如何产生的，产生的数据结构是怎么样的？
##### A：戒指每隔一定时间（默认是5分钟）就会进行一次自动测试，测试的内容包括心率、血氧、心率变异性、睡眠状态等，从而产生一个采样数据点，一个数据点对应一个RingDataModel模型对象，该采样数据会存储在戒指当中，随着时间的推移，戒指中存储的数据点会越来越多，但是最多只会保存最近7天的数据。


##### Q：如何使用SDK从戒指中读取数据？
##### A：连接上戒指后，戒指中的数据不会主动上报，需要自己调用相应的SDK方法去获取，可使用以下方法去读取戒指中的数据
```Swift
 func readDatas(progressBlock: @escaping (Double, RingDataModel)->Void, resultBlock: @escaping (Result<ReadDataResult, ReadError>)->Void)
```
 注：首次调用该方法，将会读取戒指中存储的全部历史数据点，成功获取全部历史数据之后，再调用该方法，只会读取戒指中未被读取过的新的数据点，若戒指无新数据产生或者戒指中数据已被读取过，调用该方法获取到的数据将会为空。该方法内部会将获取到的所有数据点都存入到SDK内置的本地数据库中。


##### Q：如何从SDK内置的数据库中获取指定日期的数据？
##### A：当我们将戒指中的数据读取上来之后，可使用RingDBManager管理类获取相关数据，可使用getObjects(of date:Date)获取指定日期数据。如获取今天的数据
```Swift
// 从数据库中获取今日数据
let date = Date()
let datasOfToday = RingDBManager.shared.getObjects(of: date)
```


##### Q：使用该SDk开发App，获取数据的一般流程？
##### A：在连接设备之后，使用以下方法读取戒指中的数据
```
func readDatas(progressBlock: @escaping (Double, RingDataModel)->Void, resultBlock: @escaping (Result<ReadDataResult, ReadError>)->Void)
```
获取成功之后，再调用以下方法从数据库中获取指定日期的数据，从而得到最新数据。
```
func getObjects(of date:Date) -> [RingDataModel]
```
##### Q：如何获取睡眠数据？
##### A：连接设备之后，使用以下方法读取戒指中的数据
```
func readDatas(progressBlock: @escaping (Double, RingDataModel)->Void, resultBlock: @escaping (Result<ReadDataResult, ReadError>)->Void)
```
获取成功之后，再调用以下方法从数据库中获取指定日期的睡眠数据。
```
func caculateSleepData(targetDate: Date) -> ([RingDataModel], [[RingDataModel]])
```
返回值是一个元组，元组的第一个元素($0.0)是睡眠数据集合，其中第一个数据点即为睡眠入睡点的数据，最后一个数据点即为睡眠醒来点的数据。
元组的第二个元素($0.1)是一个二维数组，是多个零星睡眠段的集合。其中的每个数组的含义与上面所述相同。

##### Q：获取到睡眠数据之后如何获得入睡时间、醒来时间、睡眠时间，如何统计清醒时长、浅睡时长、深睡时长、眼动期时长？
##### A：如下例子所示
```
        // 获取昨晚的睡眠数据
        let date = Date()
        let allDatasOfSleeps = RingManager.shared.caculateSleepData(targetDate: date)
        let datas = allDatasOfSleeps.0
        print("入睡时间 ======>\(String(describing: datas.first?.timestamp))")
        print("醒来时间 ======>\(String(describing: datas.last?.timestamp))")
   
        let sleepTimes = RingManager.shared.calculateSleepTimes(sleepDatas: datas)
        print("睡眠时间 ======>\(sleepTimes)分钟")
        
        
        var lastModel:RingDataModel?
        // 清醒时长，单位秒
        var wakeTimes:UInt32 = 0
        // 浅睡时长，单位秒
        var lightSleepTimes:UInt32 = 0
        // 深睡时长，单位秒
        var deepSLeepTimes:UInt32 = 0
        // 眼动期时长，单位秒
        var eyesTimes:UInt32 = 0
        datas.forEach { model in
            if let tempLastModel = lastModel {
                switch model.sleepType {
                case 1:// 清醒
                    wakeTimes += model.timestamp - tempLastModel.timestamp
                case 2:// 浅睡
                    lightSleepTimes += model.timestamp - tempLastModel.timestamp
                case 3:// 深睡
                    deepSLeepTimes += model.timestamp - tempLastModel.timestamp
                case 4:// 眼动
                    eyesTimes += model.timestamp - tempLastModel.timestamp
                default :
                    break
                }
                lastModel = model
            }else{
                lastModel = model
            }
        }
        
        print("清醒时长 ======>\(wakeTimes)")
        print("浅睡时长 ======>\(lightSleepTimes)")
        print("深睡时长 ======>\(deepSLeepTimes)")
        print("眼动时长 ======>\(eyesTimes)")
```


## Author

weicb

## License

Rings-SDK is available under the MIT license. See the LICENSE file for more info.
