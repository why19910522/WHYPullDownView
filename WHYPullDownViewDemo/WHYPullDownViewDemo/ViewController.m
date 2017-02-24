//
//  ViewController.m
//  WHYPullDownViewDemo
//
//  Created by wanghongyun on 2017/2/24.
//  Copyright © 2017年 wanghongyun. All rights reserved.
//

#import "ViewController.h"
#import "WHYPullDownView.h"

@interface ViewController ()<WHYPullDownViewDelegate, WHYPullDownViewDatasource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WHYPullDownView *pullDownView = [[WHYPullDownView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 40)];
    
    pullDownView.delegate = self;
    pullDownView.dataSource = self;
    
    [self.view addSubview:pullDownView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WHYPullDownViewDatasource
- (NSInteger)numberOfSectionInPullDownView:(WHYPullDownView *)pullDownView {
    return 4;
}

- (UIView *)pullDownView:(WHYPullDownView *)pullDownView viewOfSection:(NSInteger)section {
    
    UIView *view = [pullDownView dequeueReusableSectionViewWithSection:section];
    
    if (view == nil) {
        view = [UIView new];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    label.text = @"ce";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    
    [view addSubview:label];
    
    return view;
}

- (NSInteger)pullDownView:(WHYPullDownView *)pullDownView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)pullDownView:(WHYPullDownView *)pullDownView cellOfIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"ceshi";
    
    UITableViewCell *cell = [pullDownView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%zd----%zd", indexPath.section, indexPath.row];
    
    return cell;
}

- (UIView *)seperatorViewBetweenSectionInPullDownView:(WHYPullDownView *)pullDownView {
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    
    sep.backgroundColor = [UIColor redColor];
    
    return sep;
}

#pragma mark - WHYPullDownViewDelegate
- (void)pullDownView:(WHYPullDownView *)pullDownView didSelectedSection:(NSInteger)section {
    NSLog(@"didSelectedSection----%zd", section);
}

- (void)pullDownView:(WHYPullDownView *)pullDownView didDeselectedSection:(NSInteger)section {
    NSLog(@"didDeselectedSection----%zd", section);
}


@end
