//
//  DeviceTableVC.m
//  OCRingsSDKDemo
//
//  Created by JianDan on 2025/3/5.
//

#import <RingsSDK/RingsSDK.h>
#import "DeviceTableVC.h"
#import "OCRingsSDKDemo-Swift.h"

@protocol DeviceTableViewCellDelegate <NSObject>
- (void)didTapConnectButton:(DeviceInfo *)device;
@end


@interface DeviceTableViewCell : UITableViewCell

@property (nonatomic, weak) id<DeviceTableViewCellDelegate> delegate;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *macLabel;
@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, strong) DeviceInfo *device;

- (void)configureWithDevice:(DeviceInfo *)device;

@end

@implementation DeviceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }

    return self;
}

- (void)setupUI {
    // 设备名称
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.nameLabel];

    // MAC地址
    self.macLabel = [[UILabel alloc] init];
    self.macLabel.font = [UIFont systemFontOfSize:14];
    self.macLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.macLabel];

    // 连接按钮
    self.connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.connectButton setTitle:@"连接" forState:UIControlStateNormal];
    [self.connectButton addTarget:self action:@selector(connectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.connectButton];

    // 布局约束（使用frame或者Masonry都可以）
    self.nameLabel.frame = CGRectMake(15, 10, 200, 20);
    self.macLabel.frame = CGRectMake(15, 35, 200, 20);
    self.connectButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 80, 20, 60, 30);
}

- (void)configureWithDevice:(DeviceInfo *)device {
    self.device = device;
    self.nameLabel.text = device.peripheralName ? : @"未知设备";

    // 获取MAC地址
    NSData *macData = device.advertisementData[@"kCBAdvDataManufacturerData"];
    NSString *macAddress = @"";

    if (macData && macData.length >= 8) {
        const unsigned char *bytes = macData.bytes;
        macAddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                      bytes[7], bytes[6], bytes[5], bytes[4], bytes[3], bytes[2]];
    }

    self.macLabel.text = macAddress;
}

- (void)connectButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapConnectButton:)]) {
        [self.delegate didTapConnectButton:self.device];
    }
}

@end

@interface DeviceTableVC ()<UITableViewDelegate, UITableViewDataSource, DeviceTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<DeviceInfo *> *deviceList;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation DeviceTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备列表";
    self.deviceList = [NSMutableArray array];
    [self setupUI];
    [self startScan];
}

- (void)setupUI {
    // 表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[DeviceTableViewCell class] forCellReuseIdentifier:@"DeviceCell"];
    [self.view addSubview:self.tableView];

    // 下拉刷新
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshDeviceList) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;

    // 刷新按钮
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(startScan)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)startScan {
    [BDLog info:@"开始扫描设备"];
    [[BCLRingManager shared] stopScan];
    [self.deviceList removeAllObjects];
    [self.tableView reloadData];

    [[BCLRingManager shared] startScanDevicesWithCompletion:^(NSArray *_Nullable devices, NSString *_Nullable error) {
        if (error) {
            [BDLog error:[NSString stringWithFormat:@"扫描失败：%@", error]];
            return;
        }

        [self.deviceList removeAllObjects];
        [self.deviceList addObjectsFromArray:devices];
        [self.tableView reloadData];
    }];
}

- (void)refreshDeviceList {
    [self startScan];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];

    cell.delegate = self;
    [cell configureWithDevice:self.deviceList[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - DeviceTableViewCellDelegate

- (void)didTapConnectButton:(DeviceInfo *)device {
    [BDLog info:[NSString stringWithFormat:@"正在连接设备：%@", device.peripheralName]];

    [[BCLRingManager shared] connectDeviceWithUUID:device.uuidString
                                        completion:^(BOOL success, NSString *_Nullable deviceName, NSString *_Nullable error) {
        if (success) {
            [BDLog info:[NSString stringWithFormat:@"设备连接成功：%@", deviceName]];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [BDLog info:[NSString stringWithFormat:@"设备连接失败：%@", error]];
        }
    }];
}

@end
