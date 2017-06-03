//
//  CRMRefreshView.h
//  test
//
//  Created by chdo on 2017/6/2.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRMRefreshView : UIView

@property(nonatomic, copy) void(^pullAction)();

-(void)startRefresh;
-(void)stopRefreshing;

@end
