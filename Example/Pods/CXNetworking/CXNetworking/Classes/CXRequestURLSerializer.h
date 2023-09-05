//
//  CXRequestURLSerializer.h
//  CXNetworking
//
//  Created by shenchunxing on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CXRequestModel;
@interface CXRequestURLSerializer : NSObject

/**
 解析URL

 @param request 请求模型
 @return 完整URL
 */
+ (NSString *)URLForRequest:(CXRequestModel *)request;

@end

NS_ASSUME_NONNULL_END
