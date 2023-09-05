//
//  CXHTTPClient.h
//  CXNetworking
//
//  Created by shenchunxing on 2021/3/26.
//

#import <AFNetworking/AFNetworking.h>
#import "CXHTTPProxy.h"
NS_ASSUME_NONNULL_BEGIN

@class CXRequestModel,CXResponseModel;
@interface CXHTTPClient : AFHTTPSessionManager

/* 切片,强制持有方式，外部不能强持有 */
@property (nonatomic, strong) id<CXHTTPProxy> proxy;

+ (instancetype)shareInstance;


/**
 网络请求

 @param requestModel 请求requestModel
 @param progressBlock 进度
 @param callback 回调CXResponseModel
 @return task
 */
- (nonnull NSURLSessionTask*)sendRequestWithRequestModel:(nonnull CXRequestModel *)requestModel
                                                     progress:(nullable void (^)(NSProgress *_Nullable progress))progressBlock
                                                     callback:(nullable void (^)(CXResponseModel *_Nullable responseModel))callback;

//不要进度条
- (nonnull NSURLSessionTask*)sendRequestWithRequestModel:(nonnull CXRequestModel *)requestModel
                                                callback:(nullable void (^)(CXResponseModel *_Nullable responseModel))callback;

/**
 检测网络是否可用

 @param block block
 */
- (void)checkNetworkAvailable:(void(^)(BOOL isAvailable))block;
@end

NS_ASSUME_NONNULL_END
