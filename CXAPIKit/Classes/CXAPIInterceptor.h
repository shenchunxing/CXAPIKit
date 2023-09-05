//
//  CXAPIInterceptor.h
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import <Foundation/Foundation.h>

//================================================
//                切片入口代理
//================================================

NS_ASSUME_NONNULL_BEGIN
@class CXBaseAPI;
@protocol CXAPIInterceptor <NSObject>

@optional

- (BOOL)api:(CXBaseAPI *)api beforePerformSuccessWithResponse:(id)response;
- (void)api:(CXBaseAPI *)api afterPerformSuccessWithResponse:(id)response;
- (BOOL)api:(CXBaseAPI *)api beforePerformFailureWithResponse:(id)response;
- (void)api:(CXBaseAPI *)api afterPerformFailureWithResponse:(id)response;

@end

NS_ASSUME_NONNULL_END
