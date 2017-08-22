//
//  ViewController.m
//  ScanRecognite
//
//  Created by hbj on 2017/8/22.
//  Copyright © 2017年 宝剑. All rights reserved.
//

#import "ViewController.h"
#import "ScanRecogniteVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
}


- (IBAction)clickAction:(UIButton *)sender {
    ScanRecogniteVC *scanVC = [[ScanRecogniteVC alloc] init];
    [self presentViewController:scanVC animated:YES completion:^{
        NSLog(@"跳转到扫图界面");
    }];
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
