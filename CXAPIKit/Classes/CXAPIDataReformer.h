//
//  TDFAPIDataReformer.h
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import <Foundation/Foundation.h>


//================================================
//                数据加工代理
//================================================

NS_ASSUME_NONNULL_BEGIN
@class CXBaseAPI;
@protocol CXAPIDataReformer <NSObject>

@required
- (id)api:(CXBaseAPI *)api reformResponse:(id)response;

@end

NS_ASSUME_NONNULL_END
