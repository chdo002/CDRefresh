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
#define StatusH [[UIApplication sharedApplication] statusBarFrame].size.height
#define NaviH (StatusH + 40)
typedef enum : NSUInteger {
    CDRefreshStateNormal,      // 普通
    CDRefreshStatePulling,     // 拉动中
    CDRefreshStateRefreshing   // 刷新中
} CDRefreshState;
static UIViewController *refcontroller;
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
    
    pullMark = 40 + StatusH;
    [self setFrame:CGRectMake(0, -pullMark, ScreenW, pullMark)];
    [self setBackgroundColor:[UIColor clearColor]];
    
    _state = CDRefreshStateNormal;
    
    loading = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
    [loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    loading.hidesWhenStopped = NO;
    [self addSubview:loading];
    
    return self;
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self viewVC:self];
    self->scroll = (UIScrollView *)self.superview;
    originInset = self->scroll.contentInset;
    originOffset = self->scroll.contentOffset;
    
    [self->scroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew  context:CDRefreshViewContext];
    [self->scroll addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld   context:CDRefreshViewContext];
}

-(void)setRefreshAction:(void (^)(void))refreshAction {
    _refreshAction = refreshAction;
    pullMark = 60;
    [self setFrame:CGRectMake(0, -pullMark, ScreenW, pullMark)];
    [self setBackgroundColor:[UIColor clearColor]];
    
    _state = CDRefreshStateNormal;
}

-(void)setState:(CDRefreshState)state {
    
    //    if (_state != state) {
    //        _state = state;
    //    } else {
    //        return;
    //    }
    if (_state == state) {
        return;
    }
    
    switch (state) {
        case CDRefreshStateNormal:
            // 进入普通模式
        {
            [self setAlpha:0];
            [UIView animateWithDuration:0.25 animations:^{
                self->scroll.contentInset = self->originInset;
            } completion:^(BOOL finished) {
                self->_state = state;
            }];
        }
            break;
        case CDRefreshStatePulling:
            self->_state = state;
            break;
        case CDRefreshStateRefreshing:
            self->_state = state;
            [self setAlpha:1];
            
            // 进入刷新状态
            [UIView animateWithDuration:0.25 animations:^{
                
                UIEdgeInsets inset = self->scroll.contentInset;
                inset.top = self.frame.size.height + inset.top;
                self->scroll.contentInset = inset;
                CGPoint offset = self->scroll.contentOffset;
                offset.y = -inset.top;
                self->scroll.contentOffset = offset;
            } completion:^(BOOL finished) {
                if(self.refreshAction){
                    self.refreshAction();
                    [self startAnimation];
                }
            }];
            break;
    }
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
            
            CGFloat per = (scroll.contentOffset.y + originInset.top) / self.frame.size.height;
            per = MIN(per, 0);
            per = MAX(per, -1);
            
            [self performProgressChange:-per];
            
            // 在开始减速状态下，若超过标准值，则触发刷新事件
        } else if (scroll.isDecelerating) {
            UIViewController *vc = [self viewVC:self];
            if (vc.navigationController){
                if (-offset.y > (pullMark + NaviH)) {
                    //触发刷新事件
                    self.state = CDRefreshStateRefreshing;
                }
            } else {
                if (-offset.y > pullMark) {
                    //触发刷新事件
                    self.state = CDRefreshStateRefreshing;
                }
            }
        }
    } else if ([keyPath isEqualToString:@"contentInset"] && context == CDRefreshViewContext) {
        
        
        UIEdgeInsets oldoffset = [change[NSKeyValueChangeOldKey] UIEdgeInsetsValue];
        UIEdgeInsets newInset = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
        
        if (oldoffset.top == 0 && pullMark < newInset.top) {
            
            originInset = newInset;
            
            CGRect oldFrame = self.frame;
            CGRect newFrame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y - newInset.top, oldFrame.size.width, oldFrame.size.height);
            self.frame = newFrame;
            
            pullMark = pullMark + newInset.top;
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
    self.state = CDRefreshStateNormal;
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

-(UIViewController *)viewVC:(UIView *)res{
    if (refcontroller) {
        return refcontroller;
    }
    if ([res.nextResponder isKindOfClass:[UIViewController class]]) {
        refcontroller = (UIViewController *)res.nextResponder;
        return (UIViewController *)res.nextResponder;
    } else {
        return [self viewVC:(UIView *)res.nextResponder];
    }
}

-(void)dealloc {
    [scroll removeObserver:self forKeyPath:@"contentOffset"];
}

@end
