//
//  test2ViewController.m
//  bletest
//
//  Created by shilu lai on 2019/4/4.
//  Copyright © 2019 shilu lai. All rights reserved.
//
// 提供订阅的特征
#define SERVICE_UUID @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
// 提供只写的特征
#define WRITE_CHAR_UUID @"49535343-8841-43F4-A8D4-ECBE34729BB3"
// 提供通知的特征
#define NOTIFI_CHAR_UUID @"49535343-1E4D-4BD9-BA61-23C647249616"

#define WRITE_NOTIFI_CHAR_UUID @"49535343-ACA3-481C-91EC-D85E28A60318"

#import "test2ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "JQCPCLTool.h"
@interface test2ViewController ()<CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)CBCharacteristic *characteristic;
@property (nonatomic, strong)CBCharacteristic *notifiCharacteristic;
@property (nonatomic,strong)CBPeripheral *Peripheral;
@property (nonatomic, strong)JQCPCLTool *cpclManager;
@end

@implementation test2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.connectSuccess.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell1 = [tableView
                              dequeueReusableCellWithIdentifier:@"cell"];
    if (cell1==nil) {
        cell1 =[ [UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    CBPeripheral *peripheral=  self.connectSuccess[indexPath.row];
    NSString *c = [NSString stringWithFormat:@"%@",peripheral.identifier.UUIDString];
    cell1.textLabel.text = c;
    
    return cell1;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 发现指定的服务
    CBPeripheral *peripheral=  self.connectSuccess[indexPath.row];
    self.Peripheral = peripheral;
    peripheral.delegate =self;
    CBUUID *serviceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
    [peripheral discoverServices:@[serviceUUID]];
   
    
}
/**
 *  已经发现服务
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        //[self getAllCharacteristicsFromKeyfob:peripheral];
        CBUUID *charUUID = [CBUUID UUIDWithString:WRITE_CHAR_UUID];
        CBUUID *notifiCharUUID = [CBUUID UUIDWithString:NOTIFI_CHAR_UUID];
        // 发现指定服务的指定特征
        if (peripheral.services.count !=0) {
            for (CBService *service in peripheral.services) {
                if ([service.UUID.UUIDString isEqualToString:SERVICE_UUID]) {
                    NSLog(@"发现服务: %@", service.UUID.UUIDString);
                    [peripheral discoverCharacteristics:@[charUUID, notifiCharUUID] forService:service];
                }
            }
        }else{
           //sb
            NSLog(@"失败");
        }
        
    }
    else {
          NSLog(@"失败");
    }
}

/**
 *  已经发现特征
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        if (service.characteristics.count!=0) {
            
            // 发现指定服务的指定特征
            for (CBCharacteristic *characteristic in service.characteristics) {

                // 发现了可写的特征
                if ([characteristic.UUID.UUIDString isEqualToString:WRITE_CHAR_UUID]) {
                    
                    self.characteristic = characteristic;
                    //  [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
                
                // 发现了提供订阅的特征
                if ([characteristic.UUID.UUIDString isEqualToString:NOTIFI_CHAR_UUID]) {
                    self.notifiCharacteristic = characteristic;
                    // 订阅特征
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
            
            if (self.characteristic && self.notifiCharacteristic) {
                // 通知代理此时真正连接上提供指定服务和特征的外围设备
                [self writedata];
            }
            
        }else{
               NSLog(@"失败");
        }
    }
    else {
              NSLog(@"失败");
    }
}
-(void)writedata
{
    self.cpclManager = [JQCPCLTool CPCLManager];
    [self.cpclManager reset];
    
    [self.cpclManager pageSetup:570 pageHeight:720 qty:1];
    
    [self.cpclManager drawText:150  text_y:0  text:@"测试工地" fontSize:2  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawQrCode:30 start_y:80 text:@"https://test.hyj-kj.com/apply/downLoad/?isScan=1&orderNum=hyj06342019011553300" rotate:0 ver:0 lel:0];
    [self.cpclManager drawText:170  text_y:80  text:@"第1联(电子联单)" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:170  text_y:130  text:@"工单:hyj0274201808220001" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:170  text_y:180  text:@"土方单位:深圳市金鼎盛土石方有限公司" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:240   text:@"泥头车牌：粤B32961" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:280  text:@"驾驶司机：粤B3219S1" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:320  text:@"所属车队：临时车" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:360  text:@"放行人员：赖世路" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:400  text:@"今日车次：1" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:440  text:@"倒土方式：自倒" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:480  text:@"渣土类型：好土" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:520  text:@"价格：1元" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:560  text:@"入场时间：2018-08-22  15:39:53" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:600  text:@"进场时间：2018-08-22  15:40:05（白班）" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    
     NSData *data =  [self.cpclManager print:0 skip:0 peripheral:self.Peripheral];
    
    [self write:self.Peripheral data:data];
    
    
}
-(void)write:(CBPeripheral *)Peripheral data:(NSData *)datas
{
    if(self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
    {
        //        NSLog(@"self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse");
        [Peripheral writeValue:datas forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }else
    {
        //        NSLog(@"else");
        [Peripheral writeValue:datas forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
    
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%@",peripheral);
    NSLog(@"数据写入成功");
    //[self.discoveredPeripheral readValueForCharacteristic:self.notifiCharacteristic];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
