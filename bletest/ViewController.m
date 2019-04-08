//
//  ViewController.m
//  bletest
//
//  Created by shilu lai on 2019/4/4.
//  Copyright © 2019 shilu lai. All rights reserved.
//





#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "test2ViewController.h"
@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong ) CBCentralManager *manager;// 中心设备
@property (nonatomic,strong ) NSMutableArray   <CBPeripheral*>*devices;// 扫描到的外围设备
@property (nonatomic, strong) NSMutableArray   *connectSuccess;//链接成功的的外设
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
 
    
    UIButton *btn2 =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    [btn2 addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitle:@"next" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    self.navigationItem.leftBarButtonItem = leftBar;
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.devices = [NSMutableArray array];
    self.connectSuccess = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //创建下啦刷新
    //UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    //rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"Drop Scan"];
    
    //[rc addTarget:self action:@selector(redreshTableView) forControlEvents:UIControlEventValueChanged];
    
    //self.refreshControl = rc;
    [self startScan];
    
    
}
-(void)rightBarButtonClick
{
    test2ViewController *test =[[test2ViewController alloc]init];
    test.connectSuccess =self.connectSuccess;
    [self.navigationController pushViewController:test animated:YES];
    
}
/*
 * 字符串转为颜色值
 */
- (UIColor *) stringTOColor:(NSString *)str
{
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }
    unsigned red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color= [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
    return color;
}

/*
 * 开始扫描
 */
-(void) startScan{
    NSLog(@"scan....");
    
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    
    //[self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    //3秒后停止。(开启扫描后会不停的扫描)
    [self performSelector:@selector(stopScan) withObject:nil afterDelay:15];
}

/**
 *  停止扫描
 */
-(void)stopScan{
    [self.manager stopScan];
    NSLog(@"stopScan....");
}

//中心设备状态改变的代理必须实现
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBManagerStatePoweredOn:
            NSLog(@"蓝牙已打开");
            //自动开始扫描
            [self startScan];
            break;
        case CBManagerStateUnknown:
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"蓝牙未打开");
            
            break;
        case CBManagerStateResetting:
            //            [self showInfo:@"蓝牙初始化中"];
            break;
        case CBManagerStateUnsupported:
            NSLog(@"蓝牙不支持状态");
            
            //            [self showInfo:@"蓝牙不支持状态"];
            break;
        case CBManagerStateUnauthorized:
            //            [self showInfo:@"蓝牙设备未授权"];
            break;
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  扫描蓝牙的代理
 *
 *  @param central           中心设备
 *  @param peripheral        扫描到的蓝牙
 *  @param advertisementData 在ios中蓝牙广播信息中通常会包含以下4种类型的信息。ios的蓝牙通信协议中不接受其他类型的广播信息。
 因此需要注意的是，如果需要在扫描设备时，通过蓝牙设备的Mac地址来唯一辨别设备，那么需要与蓝牙设备的硬件工程师沟通好：将所需要的Mac地址放到一下几种类型的广播信息中。
 通常放到kCBAdvDataManufacturerData这个字段中。
 kCBAdvDataIsConnectable = 1;
 kCBAdvDataLocalName = XXXXXX;
 kCBAdvDataManufacturerData = <XXXXXXXX>;
 kCBAdvDataTxPowerLevel = 0;
 *  @param RSSI              信号强度
 */
//扫描到的蓝牙设备添加到devices数组中，刷新列表
-(void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                 RSSI:(NSNumber *)RSSI{
    if (![self.devices containsObject:peripheral]) {
        [self.devices addObject:peripheral];
        [self.tableView reloadData];
        NSLog(@"发现外围设备:%@---RSSI:%@---advertisementData:%@",peripheral,RSSI,advertisementData);
    }
}
/**
 *  蓝牙连接成功时候的代理
 *
 *  @param central    中心设备
 *  @param peripheral 当前连接的设备
 */
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"%@名字的蓝牙连接成功",peripheral.name);
    //cell.detailTextLabel.text = @"已连接";
    [self.connectSuccess addObject:peripheral];
    
}
/**
 *  蓝牙链接失败的代理
 *
 *  @param central    中心设备
 *  @param peripheral 当前连接的外设
 *  @param error      错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;{
    NSLog(@"%@名字的蓝牙连接失败",peripheral.name);
}
/**
 *  蓝牙断开连接的代理
 *
 *  @param central    中心设备
 *  @param peripheral 当前需要断开连接的外设
 *  @param error      错误信息
 */
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@名字的蓝牙断开链接",peripheral.name);
    for(int i=0;i<_connectSuccess.count;i++){
        CBPeripheral *p = [_connectSuccess objectAtIndex:i];
        if ([p.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            [self.connectSuccess removeObject:p];
        }
        
    }
    
    /*for (CBPeripheral *p in self.connectSuccess) {
     if ([p.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
     [self.connectSuccess removeObject:p];
     }
     }*/
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.devices.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell1 = [tableView
                           dequeueReusableCellWithIdentifier:@"cell"];
    if (cell1==nil) {
        cell1 =[ [UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
        //cell1.txtDeviceAddre.text=self.devices[indexPath.row].identifier;
        NSString *c = [NSString stringWithFormat:@"%@",self.devices[indexPath.row].name];
        cell1.textLabel.text = c;
 
    return cell1;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CBPeripheral *peripheral=  self.devices[indexPath.row];
    [self.manager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES, CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES, CBConnectPeripheralOptionNotifyOnNotificationKey: @YES}];
    
}
@end
