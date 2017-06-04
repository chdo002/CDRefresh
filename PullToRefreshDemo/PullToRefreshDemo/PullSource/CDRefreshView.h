//
//  CRMRefreshView.h
//  test
//
//  Created by chdo on 2017/6/2.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDRefreshView : UIView

@property(nonatomic, copy) void(^refreshAction)();
@property(nonatomic, copy) void(^pullAction)(UIView *refView, CGFloat per);

-(void)startRefresh;
-(void)stopRefreshing;

@end
