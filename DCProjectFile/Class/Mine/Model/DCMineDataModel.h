//
//  DCMineDataModel.h
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCMineDataModel : NSObject
@property (nonatomic, copy) NSString *imgName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *controller;

@end

NS_ASSUME_NONNULL_END
