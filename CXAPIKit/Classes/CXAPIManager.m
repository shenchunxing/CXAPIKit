//
//  CXAPIManager.m
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXAPIManager.h"
#import <CXNetworking/CXHTTPClient.h>
#import <CXNetworking/CXRequestModel.h>
#import <CXNetworking/CXResponseModel.h>
#import "CXBaseAPI.h"
#import "CXBatchAPIRequest.h"

@interface CXAPIManager ()

/* 请求任务表 */
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSURLSessionTask *> *requestTaskMap;
/* api集合 */
@property (strong, nonatomic) NSMutableSet <CXBaseAPI *> *requests;

@end

@implementation CXAPIManager

+ (instancetype)shareInstance {
    
    static CXAPIManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.requestTaskMap = [NSMutableDictionary dictionary];
        self.requests = [NSMutableSet set];
    }
    return self;
}

- (BOOL)sendRequest:(CXBaseAPI *)api {
    
    if (api.isLoading) {
        return NO;
    }
    [self sendRequest:api fromBatchRequest:nil withDispatchGroup:nil];
    return YES;
}

- (BOOL)sendBatchRequest:(CXBatchAPIRequest *)request {
    
    NSParameterAssert(request);
    NSAssert(request.apisSet.count > 0, @"Count of api should be more than 0");
    if (request.isLoading) {
        return NO;
    }
    //展示loading
    [self safeAsyncOnMainThread:^{
        request.loading = YES;
        [request.presenter apiShowBeginHUD:request];
    }];
    
    dispatch_group_t batch_api_group = dispatch_group_create();
    //批量无序发送
    for (CXBaseAPI *api in request.apisSet) {
        if (api.isLoading) {
            continue;
        }
        dispatch_group_enter(batch_api_group);
        [self sendRequest:api fromBatchRequest:request withDispatchGroup:batch_api_group];
    }
    //所有请求发送完成执行该方法
    dispatch_group_notify(batch_api_group, dispatch_get_main_queue(), ^{
        request.loading = NO;
        if (request->_canceled) {
            [request.presenter apiHideBeginHUD:request];
            return;
        }
        if (!request.error) {
            [request.presenter api:request showSuccessHUD:nil];
            if (request.requestSuccessHandler) {
                request.requestSuccessHandler(request);
            }
        }else{
            [request.presenter api:request showFailureHUD:request.error];
            if (request.requestFailureHandler) {
                request.requestFailureHandler(request, request.error);
            }
        }
    });
    return YES;
}

- (NSInteger)sendRequest:(CXBaseAPI *)api
        fromBatchRequest:(CXBatchAPIRequest *)batchRequest
       withDispatchGroup:(dispatch_group_t)dispatchGroup  {
 
    NSParameterAssert(api);
    
    //如果请求完成时才释放，把api都加到数组中
    if (api.isDeallocUntilCompletion) {
        @synchronized (self) {
            if (![self.requests containsObject:api]) {
                [self.requests addObject:api];
            }
        }
    }
    
    [self safeAsyncOnMainThread:^{
        if (!batchRequest || batchRequest.enableAPIPresenters) {
            [api.presenter apiShowBeginHUD:api];
        }
    }];
    //从每个封装的api中拿到请求模型
    CXRequestModel *requestModel = api.apiRequestModel;
    requestModel.parameters = [api reformedParams];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(api) weakApi = api;
    
    typeof(api.presenter) presenter = api.presenter;
    [self safeAsyncOnMainThread:^{
        api.loading = YES;
    }];
    //真正发送请求是CXHTTPClient
    NSURLSessionTask *task = [[CXHTTPClient shareInstance] sendRequestWithRequestModel:requestModel progress:^(NSProgress * _Nullable progress) {
        
        __strong typeof(weakApi) strongApi = weakApi;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //进度条响应
        [strongSelf handleProgress:progress withAPI:strongApi];
    } callback:^(CXResponseModel * _Nullable responseModel) {
        __strong typeof(weakApi) strongApi = weakApi;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        // api was dealloced
        if (!strongApi) {
            //隐藏api
            if (!batchRequest || batchRequest.enableAPIPresenters) {
                [presenter apiHideBeginHUD:strongApi];
            }
        }
        //响应
        [strongSelf handleResponse:responseModel withAPI:strongApi fromBatchRequest:batchRequest];
        //离开队列组
        if (dispatchGroup) {
            dispatch_group_leave(dispatchGroup);
        }
    }];
    [task resume];
    api->_requestId = task.taskIdentifier;
    @synchronized (self) {
        self.requestTaskMap[@(task.taskIdentifier)] = task;
    }
    return task.taskIdentifier;
}


#pragma mark - progress handler
- (void)handleProgress:(NSProgress *)progress withAPI:(CXBaseAPI *)api {
    if (api.apiProgressBlock) {
        [self safeAsyncOnMainThread:^{
            api.apiProgressBlock(api, progress);
        }];
    }
}


#pragma mark - response handler
- (void)handleResponse:(CXResponseModel *)response
               withAPI:(CXBaseAPI *)api
      fromBatchRequest:(CXBatchAPIRequest *)batchRequest{
    
    // 默认是继续响应的，回调数据。
    //项目中不再继续响应是因为登录token过期的情况，需要立刻退出当前页面回到登录页面
    if (!response.isContinueResponse) {
        [self safeAsyncOnMainThread:^{
            if (!batchRequest || batchRequest.enableAPIPresenters) {
                [api.presenter apiHideBeginHUD:api];
            }
        }];
        [self removeRequest:api response:response];
        return;
    }
    void (^requestCompletionBlock)(CXResponseModel *) = ^(CXResponseModel *response) {
        
        api.loading = NO;
        if ([response isSuccess]) {
            // 成功
            [self handleSuccessWithResponse:response api:api fromBatchRequest:batchRequest];
        } else {
            
            // 被取消
            if (response.sessionTask.error.code == -999) {
                if (!batchRequest || batchRequest.enableAPIPresenters) {
                    [api.presenter apiHideBeginHUD:api];
                }
            }
            else {
                // 失败
                [self handleFailureWithResponse:response api:api fromBatchRequest:batchRequest];
            }
        }
    };
    //回到主线程回调
    [self safeAsyncOnMainThread:^{
        requestCompletionBlock(response);
    }];
    //api调用结束，需要清除掉
    [self removeRequest:api response:response];
}

#pragma mark - success handler
- (void)handleSuccessWithResponse:(CXResponseModel *)response
                              api:(CXBaseAPI *)api
                 fromBatchRequest:(CXBatchAPIRequest *)batchRequest{
    // 展示成功提示语
    if (!batchRequest || batchRequest.enableAPIPresenters) {
        [api.presenter api:api showSuccessHUD:response.responseObject];
    }
    
    // 成功回调之前做点事情，目前什么都没做，预留了接口而已
    BOOL valid = [api beforePerformSuccessWithResponse:response.responseObject];
    if (!valid) return;
    
    //成功后，在封装的api内部解析数据
    if (api.apiSuccessHandler) {
        
        id reformedResponse = response.responseObject;
        
        if (api.dataReformer) {
            
            // get reformed response from reformer (delegete)
            reformedResponse = [api.dataReformer api:api reformResponse:reformedResponse];
        }else {
            reformedResponse = [api apiReformResponse:reformedResponse];
        }
        api.apiSuccessHandler(api, reformedResponse);
    }
    
    // 成功回调之后做点事情，目前什么都没做，预留了接口而已
    [api afterPerformSuccessWithResponse:response.responseObject];
}

#pragma mark - failure handler
- (void)handleFailureWithResponse:(CXResponseModel *)response
                              api:(CXBaseAPI *)api
                 fromBatchRequest:(CXBatchAPIRequest *)batchRequest{
    // for failure api hud
    if (!batchRequest || batchRequest.enableAPIPresenters) {
        [api.presenter api:api showFailureHUD:response.error];
    }
    
    // cancel unfinished api request from batch request
    if (batchRequest && batchRequest.cancelUnfinishedRequestWhenAnyAPIFailed) {
        for (CXBaseAPI *subapi in batchRequest.apisSet) {
            if (![subapi isEqual:api]) {
                [subapi cancel];
            }
        }
    }
    // get last error for batch request
    if (batchRequest) {
        batchRequest.error = response.error;
    }
    // for api
    BOOL valid = [api beforePerformFailureWithResponse:response.responseObject];
    if (!valid) return;
    
    if (api.apiFailureHandler) {
        api.apiFailureHandler(api, response.error);
    }

    
    [api afterPerformFailureWithResponse:response.responseObject];
}

- (void)removeRequest:(CXBaseAPI *)api response:(CXResponseModel *)response {
    
    // remove cached request from map
    @synchronized (self) {
        [self.requestTaskMap removeObjectForKey:@(response.sessionTask.taskIdentifier)];
        if ([self.requests containsObject:api]) {
            [self.requests removeObject:api];
        }
    }
}


#pragma mark - thread safe
- (void)safeAsyncOnMainThread:(void(^)(void))action {
    if ([[NSThread currentThread] isMainThread]) {
        action();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            action();
        });
    }
}

- (void)cancelRequestWithRequestId:(NSInteger)requestId {
    
    @synchronized (self) {
        NSNumber *key = @(requestId);
        NSURLSessionTask *task = self.requestTaskMap[key];
        [self.requestTaskMap removeObjectForKey:key];
        if (task) {
            [task cancel];
        }
    }
}

- (void)cancelAllRequest {
    
    @synchronized (self) {
        [self.requestTaskMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSURLSessionTask * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        [self.requestTaskMap removeAllObjects];
    }
}

@end
