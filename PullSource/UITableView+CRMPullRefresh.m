//
//  UITableView+CRMPullRefresh.m
//  test
//
//  Created by chdo on 2017/6/2.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import "UITableView+CRMPullRefresh.h"
#import "CRMRefreshView.h"
#import "objc/runtime.h"

@implementation UITableView (CRMPullRefresh)

static const char refreshKey = '\0';

-(void)startRefresh{
    
    CRMRefreshView *refresh = objc_getAssociatedObject(self, &refreshKey);
    [refresh startRefresh];
}

-(void)stopRefreshing{
    
    CRMRefreshView *refresh = objc_getAssociatedObject(self, &refreshKey);
    [refresh stopRefreshing];
}

-(void)addPullRefresh:(void (^)())refreshAction {
    
    CRMRefreshView *refresh = [[CRMRefreshView alloc] init];
    [self addSubview:refresh];
    
    [refresh setPullAction:refreshAction];

    objc_setAssociatedObject(self, &refreshKey, refresh, OBJC_ASSOCIATION_ASSIGN);
    
}

@end
