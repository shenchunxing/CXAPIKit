//
//  CXBaseAPI.h
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "CXAPIProtocol.h"
#import "CXAPIInterceptor.h"
#import "CXAPIHUDPresenter.h"
#import "CXAPIDataReformer.h"

NS_ASSUME_NONNULL_BEGIN

//================================================
//                基础api请求类
//================================================

/**
 API响应成功
 
 response: api返回的数据
 */
typedef void(^CXApiSuccessHandler)(__kindof CXBaseAPI *api, id response);
/**
 API响应失败
 
 error: api返回的错误信息
 */
typedef void(^CXApiFailureHandler)(__kindof CXBaseAPI *api, NSError *error);

/**
 API执行进度
 
 progress: api执行进度信息
 */
typedef void(^CXApiProgressBlock)(__kindof CXBaseAPI *api, NSProgress *progress);

@class CXRequestModel;
@interface CXBaseAPI : NSObject<CXAPIProtocol>
{
    @package
    NSInteger _requestId;
    BOOL _retry;
}

/**
 当前API是否在加载
 */
@property (assign, nonatomic, getter=isLoading) BOOL loading;

/**
 是否请求完成时才释放
 */
@property (assign, nonatomic, getter=isDeallocUntilCompletion) BOOL deallocUntilCompletion;

//================================================
//                业务子类可重载方法
//================================================
/** required
 返回请求必须的信息
 
 子类必须覆盖此方法，以提供请求的必要信息，不调用super
 
 @return 见CXRequestModel定义，因该为CXRequestModel的派生类
 */
- (CXRequestModel *)apiRequestModel;

/** required
 返回请求参数
 
 子类可以覆盖此方法，以提供请求的参数，可以不调用super
 
 这里不推荐直接设置apiRequestModel的parameters设置参数
 应使用此方法返回自定义参数
 
 @return 请求参数
 */
- (NSDictionary *)apiRequestParams;

/** optional
 API响应模型转换
 
 同reformer，如果是简单的转换，可以直接在此方法里面完成
 如果转换比较复杂，可以通过reformer创建一个类来对响应数据进行解析
 
 注：请求失败的情况下不会执行转换
 
 @param response 响应数据
 @return 转化后的回调
 */
- (id)apiReformResponse:(id)response;


/* hud 展示代理 */
@property (nonatomic, strong) id<CXAPIHUDPresenter> presenter;
/* 切片代理 */
@property (nonatomic, weak) id<CXAPIInterceptor> interceptor;
/* 数据加工代理 */
@property (nonatomic, weak) id<CXAPIDataReformer> dataReformer;

/**
 API响应成功
 
 response: api返回的数据
 */
@property (copy, nonatomic) void (^apiSuccessHandler)(__kindof CXBaseAPI *api, id response);

/**
 API响应失败
 
 error: api返回的错误信息
 */
@property (copy, nonatomic) void (^apiFailureHandler)(__kindof CXBaseAPI *api, NSError *error);

/**
 API执行进度
 
 progress: api执行进度信息
 */
@property (copy, nonatomic) void (^apiProgressBlock)(__kindof CXBaseAPI *api, NSProgress *progress);


//================================================
//                基础子类可重载方法
//================================================
/**
 切片方法，基础子类可以从4个时间点进行切片
 */
- (BOOL)beforePerformSuccessWithResponse:(id)response;
- (void)afterPerformSuccessWithResponse:(id)response;
- (BOOL)beforePerformFailureWithResponse:(id)response;
- (void)afterPerformFailureWithResponse:(id)response;

/**
 返回加工后的参数
 
 一般业务子类应该使用apiRequestParams，尽量避免使用此方法
 基础子类可以使用这个方法，对参数进行改造
 使用时需要调用super
 
 @return 返回加工后的参数
 */
- (NSDictionary *)reformedParams;

@end

NS_ASSUME_NONNULL_END
