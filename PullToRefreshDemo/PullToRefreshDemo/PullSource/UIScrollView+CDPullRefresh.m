//
//  UITableView+CRMPullRefresh.m
//  test
//
//  Created by chdo on 2017/6/2.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import "UIScrollView+CDPullRefresh.h"
#import "CDRefreshView.h"
#import "objc/runtime.h"

@implementation UIScrollView (CDPullRefresh)

static const char refreshKey = '\0';

-(void)startRefresh{
    
    CDRefreshView *refresh = objc_getAssociatedObject(self, &refreshKey);
    [refresh startRefresh];
}

-(void)stopRefreshing{
    
    CDRefreshView *refresh = objc_getAssociatedObject(self, &refreshKey);
    [refresh stopRefreshing];
}

-(void)addPullRefresh:(void (^)())refreshAction {
    
    CDRefreshView *refresh = [[CDRefreshView alloc] init];
    [self addSubview:refresh];
    
    [refresh setPullAction:refreshAction];

    objc_setAssociatedObject(self, &refreshKey, refresh, OBJC_ASSOCIATION_ASSIGN);
    
}

@end
