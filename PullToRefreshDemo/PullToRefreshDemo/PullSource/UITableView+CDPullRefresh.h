//
//  UITableView+CRMPullRefresh.h
//  test
//
//  Created by chdo on 2017/6/2.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (CDPullRefresh)

-(void)addPullRefresh:(void(^)())refreshAction;

-(void)startRefresh;
-(void)stopRefreshing;

@end
