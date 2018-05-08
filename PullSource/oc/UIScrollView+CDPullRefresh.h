//
//  UITableView+CRMPullRefresh.h
//  test
//
//  Created by chdo on 2017/6/2.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (CDPullRefresh)

-(void)addPullRefresh:(void(^)(void))refreshAction;
-(void)addPullRefresh:(void (^)(void))refreshAction progressHandler: (void (^)(UIView *refView, CGFloat per))pullingAction;
-(void)startRefresh;
-(void)stopRefreshing;

@end
