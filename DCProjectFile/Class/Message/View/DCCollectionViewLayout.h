//
//  DCCollectionViewLayout.h
//  DCProjectFile
//
//  Created  on 2023/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCCollectionViewLayout : UICollectionViewLayout
@property (nonatomic) CGFloat minimumLineSpacing; //行间距

@property (nonatomic) CGFloat minimumInteritemSpacing; //item间距

@property (nonatomic) CGSize itemSize; //item大小

@property (nonatomic) UIEdgeInsets sectionInset;

- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
