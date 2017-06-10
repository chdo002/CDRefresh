//
//  ViewController.m
//  PullToRefreshDemo
//
//  Created by chdo on 2017/6/3.
//  Copyright © 2017年 chdo. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+CDPullRefresh.h"

@interface ViewController ()<UITableViewDataSource>
{
    int rowNumber;
}
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _table.dataSource = self;
    
    rowNumber = 16;
    
    [self.table addPullRefresh:^{
        NSLog(@"pulled");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSLog(@"trigged");
            rowNumber++;
            [self.table reloadData];
            [self.table stopRefreshing];
        });
    }];
    
    
//    [self.table setContentInset:UIEdgeInsetsMake(200, 0, 0, 0)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rowNumber;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setText: [NSString stringWithFormat:@"--%ld", (long)indexPath.row]];
    return cell;
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
