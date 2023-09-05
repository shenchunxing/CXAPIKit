//
//  CXRequestParamConstructor.h
//  CXNetworking
//
//  Created by shenchunxing on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CXRequestModel;
@interface CXRequestParamConstructor : NSObject

//根据CXRequestModel，获取参数
+ (NSMutableDictionary *)parametersForRequest:(CXRequestModel *)requestModel;

/**
 头部参数

 @param requestModel CXRequestModel
 @return 头部参数
 */
+ (NSMutableDictionary *)headersForRequest:(CXRequestModel *)requestModel;
@end

NS_ASSUME_NONNULL_END
