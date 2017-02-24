//
//  WHYPullDownView.h
//  WHYPullDownViewDemo
//
//  Created by wanghongyun on 2017/2/24.
//  Copyright © 2017年 wanghongyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHYPullDownView;

@protocol WHYPullDownViewDatasource <NSObject>

/**
 返回 section 个数

 @param pullDownView pullDownView
 @return section 个数
 */
- (NSInteger)numberOfSectionInPullDownView:(WHYPullDownView *)pullDownView;

/**
 返回 sectionView

 @param pullDownView pullDownView
 @param section section 索引
 @return sectionView
 */
- (__kindof UIView *)pullDownView:(WHYPullDownView *)pullDownView viewOfSection:(NSInteger)section;

/**
  返回每个 section 的行数

 @param pullDownView pullDownView
 @param section section 索引
 @return 行数
 */
- (NSInteger)pullDownView:(WHYPullDownView *)pullDownView numberOfRowsInSection:(NSInteger)section;

/**
  返回每行的 cell

 @param pullDownView pullDownView
 @param indexPath cell 索引
 @return cell
 */
- (__kindof UITableViewCell *)pullDownView:(WHYPullDownView *)pullDownView cellOfIndexPath:(NSIndexPath *)indexPath;

@optional

/**
  返回 sectionView 的宽度

 @param pullDownView pullDownView
 @param section section 索引
 @return 宽度
 */
- (CGFloat)pullDownView:(WHYPullDownView *)pullDownView widthOfSectionView:(NSInteger)section;

/**
 返回每行 cell 的高度

 @param pullDownView pullDownView
 @param indexPath cell 索引
 @return  cell 高度
 */
- (CGFloat)pullDownView:(WHYPullDownView *)pullDownView cellHeightOfIndexPath:(NSIndexPath *)indexPath;

/**
 返回每两个 sectionView 之间的分割线

 @param pullDownView pullDownView
 @return 分割线
 */
- (__kindof UIView *)seperatorViewBetweenSectionInPullDownView:(WHYPullDownView *)pullDownView;

@end

@protocol WHYPullDownViewDelegate <NSObject>

@optional

/**
 选中 sectionView 代理

 @param pullDownView pullDownView
 @param section section 索引
 */
- (void)pullDownView:(WHYPullDownView *)pullDownView didSelectedSection:(NSInteger)section;

/**
 取消选中 sectionView 代理

 @param pullDownView pullDownView
 @param section section 索引
 */
- (void)pullDownView:(WHYPullDownView *)pullDownView didDeselectedSection:(NSInteger)section;

/**
 选中 cell 代理

 @param pullDownView pullDownView
 @param indexPath cell 索引
 */
- (void)pullDownView:(WHYPullDownView *)pullDownView didSelectedCell:(NSIndexPath *)indexPath;

/**
 取消选中 cell 代理

 @param pullDownView pullDownView
 @param indexPath cell 索引
 */
- (void)pullDownView:(WHYPullDownView *)pullDownView didDeselectedCell:(NSIndexPath *)indexPath;

@end

@interface WHYPullDownView : UIView

#pragma mark - property

@property (nonatomic, strong) id<WHYPullDownViewDelegate> delegate;

@property (nonatomic, strong) id<WHYPullDownViewDatasource> dataSource;

#pragma mark - method

/**
 获取可重用 cell

 @param identifier cell 重用标识符
 @return  cell
 */
- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:( NSString *)identifier;

/**
 获取sectionView,
 如果不用此方法获取 sectionView 那么会造成显示的 View 与选中的 View 不是同一个, 所以必须先用此方法获取 sectionView
 
 @param section 组索引
 @return 返回 nil 或者一个 View, 当返回值为 nil 时需要创建调用者创建一个 View
 */
- (__kindof UIView *)dequeueReusableSectionViewWithSection:(NSInteger)section;

/**
 重载数据
 */
- (void)reloadData;

/**
 选中某一个 section

 @param section section 的索引
 */
- (void)selectAtSection:(NSInteger)section;

/**
 取消选中某一个 section

 @param section section 的索引
 */
- (void)deselectAtSection:(NSInteger)section;

@end
