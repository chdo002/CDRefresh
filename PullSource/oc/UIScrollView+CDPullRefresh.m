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

typedef enum : NSUInteger {
    AATRefreshTypeLoading,
    AATRefreshTypeText,
    AATRefreshTypeGIF,
} AATRefreshType;

@implementation UIScrollView (CDPullRefresh)

static NSString *refreshKey = @"refreshKey";

-(void)startRefresh{
    
    CDRefreshView *refresh = objc_getAssociatedObject(self, &refreshKey);
    [refresh startRefresh];
}

-(void)stopRefreshing{
    
    CDRefreshView *refresh = objc_getAssociatedObject(self, &refreshKey);
    [refresh stopRefreshing];
}

-(void)addPullRefresh:(void (^)(void))refreshAction {
    [self addPullRefresh:refreshAction progressHandler:nil];
}

-(void)addPullRefresh:(void (^)(void))refreshAction progressHandler: (void (^)(UIView *refView, CGFloat per))pullingAction {
    
    CDRefreshView *refresh = objc_getAssociatedObject(self, &refreshKey);
    if(!refresh){
        refresh = [[CDRefreshView alloc] init];
        [self addSubview:refresh];
    }
    
    [refresh setRefreshAction:refreshAction];
    [refresh setPullAction:pullingAction];
    
    objc_setAssociatedObject(self, &refreshKey, refresh, OBJC_ASSOCIATION_ASSIGN);
    
}

@end
