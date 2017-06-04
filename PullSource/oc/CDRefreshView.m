//
//  CRMRefreshView.m
//  test
//
//  Created by chdo on 2017/6/2.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import "CDRefreshView.h"


#define ScreenW [[UIScreen mainScreen] bounds].size.width
#define ScreenH [[UIScreen mainScreen] bounds].size.height

typedef enum : NSUInteger {
    CDRefreshStateNormal,      // 普通
    CDRefreshStatePulling,     // 拉动中
    CDRefreshStateRefreshing   // 刷新中
} CDRefreshState;

@interface CDRefreshView()
{
    UIScrollView *scroll;
    
    CGFloat pullMark;
    UIEdgeInsets originInset;
    CGPoint      originOffset;
    
    UIActivityIndicatorView *loading;
}

@property (nonatomic, assign) CDRefreshState state;

@end

static void *CDRefreshViewContext = &CDRefreshViewContext;

@implementation CDRefreshView

-(instancetype)init{
    self = [super init];

    pullMark = 60;
    [self setFrame:CGRectMake(0, -pullMark, ScreenW, pullMark)];
    [self setBackgroundColor:[UIColor clearColor]];
    
    _state = CDRefreshStateNormal;

    loading = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
    [loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    loading.hidesWhenStopped = NO;
    [self addSubview:loading];
    
    return self;
}

-(void)setRefreshAction:(void (^)())refreshAction {
    _refreshAction = refreshAction;
    pullMark = 60;
    [self setFrame:CGRectMake(0, -pullMark, ScreenW, pullMark)];
    [self setBackgroundColor:[UIColor clearColor]];
    
    _state = CDRefreshStateNormal;
    
    
   
}

-(void)setState:(CDRefreshState)state {
    
    if (_state != state) {
        _state = state;
    } else {
        return;
    }
    switch (state) {
        case CDRefreshStateNormal:
            // 进入普通模式
        {
            [UIView animateWithDuration:0.25 animations:^{
                scroll.contentInset = originInset;
                scroll.contentOffset = originOffset;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case CDRefreshStatePulling:
            break;
        case CDRefreshStateRefreshing:
            // 进入刷新状态
            [UIView animateWithDuration:0.25 animations:^{
                [self setAlpha:1];
                UIEdgeInsets inset = scroll.contentInset;
                inset.top = pullMark + inset.top;
                scroll.contentInset = inset;
                CGPoint offset = scroll.contentOffset;
                offset.y = -inset.top;
                scroll.contentOffset = offset;
            } completion:^(BOOL finished) {
                if(self.refreshAction){
                    self.refreshAction();
                    [self startAnimation];
                }
            }];
            break;
    }
}


-(void)didMoveToSuperview {
    
    scroll = (UIScrollView *)self.superview;
    originInset = scroll.contentInset;
    originOffset = scroll.contentOffset;
    
    [scroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew  context:CDRefreshViewContext];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"] && context == CDRefreshViewContext) {
        
        // 如果是在刷新中则返回
        if (_state == CDRefreshStateRefreshing) {
            return;
        }
        
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        // 在拖动状态下只有CDRefreshStatePulling
        if (scroll.isDragging) {
            self.state = CDRefreshStatePulling;
        
            CGFloat per = scroll.contentOffset.y / pullMark;
            per = MIN(per, 0);
            per = MAX(per, -1);
            
            [self performProgressChange:-per];
            
        // 在开始减速状态下，若超过标准值，则触发刷新事件
        } else if (scroll.isDecelerating) {
            if (-offset.y > pullMark) {
                //触发刷新事件
                self.state = CDRefreshStateRefreshing;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


-(void)startRefresh {
    self.state = CDRefreshStateRefreshing;
}

-(void)stopRefreshing{
    [self stopAnimation];
    
    if (scroll.contentOffset.y > pullMark) {
        _state = CDRefreshStateNormal;
        [UIView animateWithDuration:0.25 animations:^{
            scroll.contentInset = originInset;
            [self setAlpha:0];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.state = CDRefreshStateNormal;
    }
}

-(void)startAnimation{
    [loading startAnimating];
}

-(void)stopAnimation{
    [loading stopAnimating];
}

-(void)performProgressChange: (CGFloat)per {
    
    if (self.pullAction) {
        self.pullAction(self, per);
    } else {
        [self setAlpha:powf(per, 2.5)];    
    }
}


-(void)dealloc {
    [scroll removeObserver:self forKeyPath:@"contentOffset"];
}

@end
