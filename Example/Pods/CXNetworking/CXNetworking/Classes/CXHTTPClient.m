//
//  CXHTTPClient.m
//  CXNetworking
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXHTTPClient.h"
#import "CXRequestModel.h"
#import "CXResponseModel.h"
#import "CXRequestURLSerializer.h"
#import "CXNetworkConfig.h"
#import "CXRequestParamConstructor.h"

static CXHTTPClient *instance = nil;

static NSTimeInterval kCXNetworkingTimeout = 20.0;
static NSTimeInterval kCXNetworkingFileTimeout = 1800.0;

@interface CXHTTPClient ()
/* 是否有网络 */
@property (nonatomic, assign) BOOL whetherHaveNetwork;
@end

@implementation CXHTTPClient

+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        instance = [[CXHTTPClient alloc] initWithSessionConfiguration:defaultConfig];
                
        //请求序列化，默认使用AFHTTPRequestSerializer
        //配置
        instance.requestSerializer = [AFJSONRequestSerializer serializer];
        instance.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        
        //默认只支持json
        [instance.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        instance.requestSerializer.timeoutInterval = kCXNetworkingTimeout;
        
        //响应序列化
        instance.responseSerializer = [AFJSONResponseSerializer serializer];
        //处理网络请求的返回的数据Null问题
        ((AFJSONResponseSerializer *)instance.responseSerializer).removesKeysWithNullValues = YES;
        instance.whetherHaveNetwork = YES;
        //配置服务器地址
        kProjectAPIRoot = kCXProjectAPIRoot;
    });
    return instance;
}



- (nonnull NSURLSessionTask *)sendRequestWithRequestModel:(nonnull CXRequestModel *)requestModel
                                                     progress:(nullable void (^)(NSProgress *_Nullable progress))progressBlock
                                                     callback:(nullable void (^)(CXResponseModel *_Nullable responseModel))callback {
    
    
    NSParameterAssert(requestModel.serverRoot.length > 0);
    NSParameterAssert(requestModel.serviceName.length > 0);
    
    NSURLSessionTask *sessionTask = nil;
    if (!self.whetherHaveNetwork) {
        CXResponseModel *responseModel = [[CXResponseModel alloc] init];
        responseModel.sessionTask = sessionTask;
        callback(responseModel);
        return sessionTask;
    }
    
    if (self.proxy && [self.proxy respondsToSelector:@selector(beforeRequestSendWithRequestObject:)]) {
        !self.proxy?:[self.proxy beforeRequestSendWithRequestObject:requestModel];
    }
    
    //URL解析
    NSString *urlString = [CXRequestURLSerializer URLForRequest:requestModel];
    //参数解析
    NSMutableDictionary *mutableParameters = [CXRequestParamConstructor parametersForRequest:requestModel];
    NSDictionary *headers = [CXRequestParamConstructor headersForRequest:requestModel].copy;
    NSDictionary *parameters = [mutableParameters copy];
    
    
    //设置请求序列化，jsonh和http，默认json
    switch (requestModel.serializerType) {
        case CXRequestSerializerTypeJson:
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
            [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            break;
        case CXRequestSerializerTypeHttp:
            self.requestSerializer = [AFHTTPRequestSerializer serializer];
            self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
            [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            break;
    }
    //请求超时时间设置
    if (requestModel.timeout > kCXNetworkingTimeout) {
        self.requestSerializer.timeoutInterval = requestModel.timeout;
    }
    //根据请求类型：get or post 设置超时时间
    if (requestModel.requestType == CXHttpRequestTypeGet || requestModel.requestType == CXHttpRequestTypePost) {
        self.requestSerializer.timeoutInterval = requestModel.timeout > kCXNetworkingTimeout ? requestModel.timeout : kCXNetworkingTimeout;
    }else {
        self.requestSerializer.timeoutInterval = kCXNetworkingFileTimeout;
    }
    
    //成功回调，返回CXResponseModel
    void (^successBlock)(NSURLSessionTask *, id) = ^(NSURLSessionTask *task, id response) {
        
        CXResponseModel *responseModel = [[CXResponseModel alloc] init];
        responseModel.responseObject = response;
        responseModel.sessionTask = task;
        
        if (self.proxy && [self.proxy respondsToSelector:@selector(shouldContinueResponse:withResponseObject:)]) {
            //判断是否需要中断处理
            responseModel.isContinueResponse = [self.proxy shouldContinueResponse:responseModel withResponseObject:response];
        }
        
        if(callback) {
            callback(responseModel);
        }
        //只要不是下载文件，就需要设置cookie
        if (requestModel.requestType != CXHttpRequestTypeGETDownload) {
            [self setCookieWithResponse:task.response];
        }
    };
    
    //失败回调，返回CXResponseModel
    void (^failureBlock)(NSURLSessionTask *, NSError *) = ^(NSURLSessionTask *task, NSError *error) {
        
        CXResponseModel *responseModel = [[CXResponseModel alloc] init];
        responseModel.sessionTask = task;
        
        if(callback) {
            callback(responseModel);
        }
        //只要不是下载文件，就需要设置cookie
        if (requestModel.requestType != CXHttpRequestTypeGETDownload) {
            [self setCookieWithResponse:task.response];
        }
    };
    
    
    //这里进行真正的请求
    switch (requestModel.requestType) {
            //get
            case CXHttpRequestTypeGet:
                
                sessionTask =  [self GET:urlString parameters:parameters headers:headers progress:progressBlock success:successBlock failure:failureBlock];
            break;
            //文件下载
            case CXHttpRequestTypeGETDownload: {
            
                NSURLRequest *request = [instance.requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:parameters error:nil];
                sessionTask =[self downloadTaskWithRequest:request progress:progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    
                    NSString *fullPath =  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:response.suggestedFilename];
                    return [NSURL fileURLWithPath:fullPath];
                    //完成回调
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    
                    if (error) {
                        failureBlock(sessionTask, error);
                    }else{
                        successBlock(sessionTask, filePath);
                    }
                    
                }];
            }
            break;
            //post
            case CXHttpRequestTypePost: {
                
                if (requestModel.bodyData) {
                    sessionTask = [self POST:urlString parameters:requestModel.bodyData headers:headers progress:progressBlock success:successBlock failure:failureBlock];
                }else{
                    sessionTask = [self POST:urlString parameters:parameters headers:headers progress:progressBlock success:successBlock failure:failureBlock];

                }
            }
            
            break;
            //文件上传
            case CXHttpRequestTypePostUpload:
            
                sessionTask = [self POST:urlString parameters:parameters headers:headers constructingBodyWithBlock:requestModel.constructingBodyWithBlock progress:progressBlock success:successBlock failure:failureBlock];
            
            break;
            
            case CXHttpRequestTypeSOAPPost:
            //TODO:soap post
                
            break;
        case CXHttpRequestTypePut: {
            
            sessionTask = [self PUT:urlString parameters:parameters headers:headers success:successBlock failure:failureBlock];
        }
            break;
            case CXHttpRequestTypeHead: {
                sessionTask = [self HEAD:urlString parameters:parameters headers:headers success:^(NSURLSessionDataTask * _Nonnull task) {
                    successBlock(task,nil);
                } failure:failureBlock];
        }
            break;
        case CXHttpRequestTypeDelete: {
                sessionTask = [self DELETE:urlString parameters:parameters headers:headers success:successBlock failure:failureBlock];
        }
                break;
    }
    
    return sessionTask;
}

- (NSURLSessionTask *)sendRequestWithRequestModel:(CXRequestModel *)requestModel callback:(void (^)(CXResponseModel * _Nullable))callback
{
    return [self sendRequestWithRequestModel:requestModel progress:nil callback:callback];
}

//设置cookie
- (void)setCookieWithResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *cookieString = [[httpResponse allHeaderFields] valueForKey:@"Set-Cookie"];
    if(cookieString.length>0){
        NSString *sidStr1 = [[cookieString componentsSeparatedByString:@"sid="] lastObject];
        NSString *sid = [[sidStr1 componentsSeparatedByString:@";"] firstObject];
        if (![sid containsString:@"deleteMe"]) {
            [[NSUserDefaults standardUserDefaults] setObject:cookieString forKey:@"CXHttpCookie"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
        }
        
    }
}


- (void)checkNetworkAvailable:(void(^)(BOOL isAvailable))block {
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            self.whetherHaveNetwork = NO;
        }else {
            self.whetherHaveNetwork = YES;
        }
        !block?:block(self.whetherHaveNetwork);
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
