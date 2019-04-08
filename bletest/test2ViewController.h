//
//  test2ViewController.h
//  bletest
//
//  Created by shilu lai on 2019/4/4.
//  Copyright © 2019 shilu lai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface test2ViewController : UIViewController
@property (nonatomic, strong) NSMutableArray   *connectSuccess;//链接成功的的外设
@property(nonatomic, strong) UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
