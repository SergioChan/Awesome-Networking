//
//  ViewController.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ANManager sharedInstance] testRequestCompletion:^{
        NSLog(@"completed!");
    } success:^(id object, ...) {
        NSLog(@"success!");
    } failure:^(NSError *error) {
        NSLog(@"error!");
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
