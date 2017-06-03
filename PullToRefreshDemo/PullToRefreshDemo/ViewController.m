//
//  ViewController.m
//  PullToRefreshDemo
//
//  Created by chdo on 2017/6/3.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+CDPullRefresh.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.table addPullRefresh:^{
        NSLog(@"pulled");
    }];
    
}


- (IBAction)startRefresh:(id)sender {
    [self.table startRefresh];
}

- (IBAction)stopRefresh:(id)sender {
    [self.table stopRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
