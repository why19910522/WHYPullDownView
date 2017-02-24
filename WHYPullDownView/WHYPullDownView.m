//
//  WHYPullDownView.m
//  WHYPullDownViewDemo
//
//  Created by wanghongyun on 2017/2/24.
//  Copyright © 2017年 wanghongyun. All rights reserved.
//

#import "WHYPullDownView.h"

@interface WHYPullDownView ()<UITableViewDelegate, UITableViewDataSource>

{
    BOOL isAnimating;
}

@property (nonatomic, strong) NSMutableArray<UIView *> *sectionViews;

@property (nonatomic, assign) NSInteger sectionCount;

@property (nonatomic, assign) NSInteger currentSection;

@property (nonatomic, assign) NSInteger rowCount;

@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *tableBgView;

@property (nonatomic, assign) BOOL firstLoading;

@end

@implementation WHYPullDownView

- (UIView *)dequeueReusableSectionViewWithSection:(NSInteger)section {
    if (self.sectionViews.count > section) return self.sectionViews[section];
    return nil;
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    return [self.tableView dequeueReusableCellWithIdentifier:identifier];
}

#pragma mark - 点击事件
- (void)tapTableBgView {
    [self deselectAtSection:self.currentSection];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch        = touches.allObjects.firstObject;
    CGPoint locationPoint = [touch locationInView:self];
    
    for (NSInteger section = 0; section < self.sectionCount; section++) {
        
        if (CGRectContainsPoint(self.sectionViews[section].frame, locationPoint)) {
            
            if (self.currentSection == -1) {
                [self selectAtSection:section];
                return;
            }
            
            if (section != self.currentSection) {
                [self deselectAtSection:self.currentSection completion:^{
                    [self selectAtSection:section completion:nil];
                }];
            }else {
                [self deselectAtSection:self.currentSection];
            }
            
            return;
        }
    }
}

- (void)selectAtSection:(NSInteger)section {
    [self selectAtSection:section completion:nil];
}

- (void)selectAtSection:(NSInteger)section completion:(void(^)())completion {
    
    if (isAnimating) return;
    
    if (section < 0 || section > self.sectionCount - 1) return;
    
    if ([self.delegate respondsToSelector:@selector(pullDownView:didSelectedSection:)])
        [self.delegate pullDownView:self didSelectedSection:section];
    
    self.currentSection = section;
    
    [self loadTableViewWithCompletion:completion];
}

- (void)deselectAtSection:(NSInteger)section {
    [self deselectAtSection:section completion:nil];
}

- (void)deselectAtSection:(NSInteger)section completion:(void(^)())completion {
    
    if (isAnimating) return;
    
    if (section < 0 || section > self.sectionCount - 1) return;
    
    if ([self.delegate respondsToSelector:@selector(pullDownView:didDeselectedSection:)])
        [self.delegate pullDownView:self didDeselectedSection:section];
    
    self.currentSection = -1;
    
    [self removeTableViewWithCompletion:completion];
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentSection = -1;
        self.firstLoading   = YES;
        isAnimating         = NO;
    }
    return self;
}

#pragma mark - load and reload
- (void)reloadData {
    
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
    
    [self loadSection];
}

- (void)loadTableViewWithCompletion:(void(^)())completion {
    
    self.tableBgView                 = [UIView new];
    self.tableBgView.frame           = CGRectMake(0,
                                                  CGRectGetMaxY(self.frame),
                                                  self.superview.bounds.size.width,
                                                  self.superview.bounds.size.height - self.bounds.size.height);
    self.tableBgView.backgroundColor = [UIColor blackColor];
    self.tableBgView.alpha           = 0.0;
    [self.tableBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(tapTableBgView)]];
    [self.superview addSubview:self.tableBgView];
    
    self.tableView                 = [UITableView new];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.bounces         = NO;
    [self.superview addSubview:self.tableView];
    
    CGRect tableFrame = CGRectZero;
    tableFrame.origin = self.tableBgView.frame.origin;
    
    CGFloat tableHeight    = 0;
    NSInteger tempRowCount = self.rowCount > 6 ? 6 : self.rowCount;
    
    for (int row = 0; row < tempRowCount; row++) {
        tableHeight += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    tableFrame.size      = CGSizeMake(self.tableBgView.bounds.size.width, 0);
    self.tableView.frame = tableFrame;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableBgView.alpha = 0.3;
        self.tableView.frame   = CGRectMake(self.tableView.frame.origin.x,
                                            self.tableView.frame.origin.y,
                                            self.tableView.frame.size.width,
                                            tableHeight);
        isAnimating            = YES;
    } completion:^(BOOL finished) {
        isAnimating = NO;
        if (completion)
            completion();
    }];
}

- (void)removeTableViewWithCompletion:(void(^)())completion {
    [UIView animateWithDuration:0.5 animations:^{
        self.tableBgView.alpha = 0.0;
        self.tableView.frame   = CGRectMake(self.tableView.frame.origin.x,
                                            self.tableView.frame.origin.y,
                                            self.tableView.frame.size.width,
                                            0);
        isAnimating            = YES;
    } completion:^(BOOL finished) {
        isAnimating = NO;
        [self.tableBgView removeFromSuperview];
        [self.tableView removeFromSuperview];
        
        if (completion)
            completion();
    }];
}

- (void)loadSection {
    
    if (self.sectionCount == 0) return;
    if (![self.dataSource respondsToSelector:@selector(pullDownView:viewOfSection:)]) return;
    
    UIView *sectionView = nil;
    CGRect sectionFrame = CGRectZero;
    
    for (int section = 0; section < self.sectionCount; section++) {
        
        sectionFrame.size = [self sectionViewSizeAtSection:section];
        
        if (sectionView != nil) {
            sectionFrame.origin = CGPointMake(CGRectGetMaxX(sectionView.frame), 0);
        }else {
            sectionFrame.origin = CGPointZero;
        }
        
        sectionView = [self.dataSource pullDownView:self viewOfSection:section];
        sectionView.frame = sectionFrame;
        [self addSubview:sectionView];
        [self.sectionViews addObject:sectionView];
    }
    
    [self loadSeperatorView];
}

- (void)loadSeperatorView {
    
    if (![self.dataSource respondsToSelector:@selector(seperatorViewBetweenSectionInPullDownView:)]) return;
    
    UIView *sep      = nil;
    
    for (int section = 0; section < self.sectionCount - 1; section++) {
        
        sep = [self.dataSource seperatorViewBetweenSectionInPullDownView:self];
        sep.center  = CGPointMake(CGRectGetMaxX(self.sectionViews[section].frame),
                                  self.bounds.size.height * 0.5);
        
        [self addSubview:sep];
    }
}

- (CGSize)sectionViewSizeAtSection:(NSInteger)section {
    [self layoutIfNeeded];
    
    if ([self.dataSource respondsToSelector:@selector(pullDownView:widthOfSectionView:)]) {
        return CGSizeMake([self.dataSource pullDownView:self widthOfSectionView:section], self.bounds.size.height);
    }else {
        return self.defaultSectionViewSize;
    }
    
}

#pragma mark -  override super method
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.firstLoading) {
        [self loadSection];
        self.firstLoading = NO;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(pullDownView:numberOfRowsInSection:)])
        return [self.dataSource pullDownView:self numberOfRowsInSection:section];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(pullDownView:cellOfIndexPath:)]) {
        
        UITableViewCell *cell = [self.dataSource pullDownView:self
                                              cellOfIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                 inSection:self.currentSection]];
        if (cell == nil) {
            return [UITableViewCell new];
        } else {
            return cell;
        }
    }

    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(pullDownView:cellHeightOfIndexPath:)])
        return [self.dataSource pullDownView:self
                       cellHeightOfIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                inSection:self.currentSection]];
    return 44;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pullDownView:didSelectedCell:)])
        [self.delegate pullDownView:self
                    didSelectedCell:[NSIndexPath indexPathForRow:indexPath.row
                                                       inSection:self.currentSection]];
}

#pragma mark - get 方法
- (NSInteger)rowCount {
    return [self tableView:self.tableView numberOfRowsInSection:0];
}

- (NSInteger)sectionCount {
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionInPullDownView:)])
        return [self.dataSource numberOfSectionInPullDownView:self];
    return 0;
}

- (CGSize)defaultSectionViewSize {
    return CGSizeMake(self.bounds.size.width / self.sectionCount, self.bounds.size.height);
}

- (NSMutableArray<UIView *> *)sectionViews {
    if (_sectionViews == nil) {
        _sectionViews = [NSMutableArray arrayWithCapacity:self.sectionCount];
    }
    return _sectionViews;
}

@end
