//
//  CRMRefreshView.m
//  test
//
//  Created by chdo on 2017/6/2.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import "CRMRefreshView.h"

typedef enum : NSUInteger {
    CRMRefreshStateNormal,      // 普通
    CRMRefreshStatePulling,     // 拉动中
    CRMRefreshStateRefreshing   // 刷新中
} CRMRefreshState;

@interface CRMRefreshView()
{
    UIScrollView *scroll;
    
    CGFloat pullMark;
    UIEdgeInsets originInset;
    CGPoint      originOffset;
    
    UIActivityIndicatorView *loading;
}

@property (nonatomic, assign) CRMRefreshState state;

@end

@implementation CRMRefreshView

-(instancetype)init{
    self = [super init];

    pullMark = 60;
    [self setFrame:CGRectMake(0, -pullMark, ScreenW, pullMark)];
    [self setBackgroundColor:[UIColor clearColor]];
    
    _state = CRMRefreshStateNormal;

    loading = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
    [loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    loading.hidesWhenStopped = NO;
    [self addSubview:loading];
    
    return self;
}

-(void)setState:(CRMRefreshState)state {
    if (_state != state) {
        _state = state;
    } else {
        return;
    }
    
    switch (state) {
        case CRMRefreshStateNormal:
            [self toogleIntoNoramlState];
            break;
        case CRMRefreshStatePulling:
            // 此处还没做下拉进度回调
            break;
        case CRMRefreshStateRefreshing:
            [self toogleIntoRefreshState];
            break;
    }
}


-(void)didMoveToSuperview {
    
    scroll = (UIScrollView *)self.superview;
    originInset = scroll.contentInset;
    originOffset = scroll.contentOffset;
    
    [scroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew  context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        // 如果是在刷新中则返回
        if (_state == CRMRefreshStateRefreshing) {
            return;
        }
        
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        // 在拖动状态下只有CRMRefreshStatePulling
        if (scroll.isDragging) {
            self.state = CRMRefreshStatePulling;
        // 在开始减速状态下，若超过标准值，则触发刷新事件
        } else if (scroll.isDecelerating) {
            if (-offset.y > pullMark) {
                //触发刷新事件
                self.state = CRMRefreshStateRefreshing;
            } else {
                self.state = CRMRefreshStateNormal;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


-(void)startRefresh {
    self.state = CRMRefreshStateRefreshing;
}

-(void)stopRefreshing{
    self.state = CRMRefreshStateNormal;
    [self stopAnimation];
}

-(void)toogleIntoNoramlState{
    
    [UIView animateWithDuration:0.25 animations:^{
        scroll.contentInset = originInset;
        scroll.contentOffset = originOffset;
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)toogleIntoRefreshState{
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets inset = scroll.contentInset;
        inset.top = pullMark + inset.top;
        scroll.contentInset = inset;
        
        CGPoint offset = scroll.contentOffset;
        offset.y = -inset.top;
        scroll.contentOffset = offset;
    } completion:^(BOOL finished) {
        if(self.pullAction){
            self.pullAction();
            [self startAnimation];
        }
    }];
}


-(void)startAnimation{
    [loading startAnimating];
}

-(void)stopAnimation{
    [loading stopAnimating];
}




-(void)dealloc {
    [scroll removeObserver:self forKeyPath:@"contentOffset"];
    [scroll removeObserver:self forKeyPath:@"contentInset"];
}

@end
