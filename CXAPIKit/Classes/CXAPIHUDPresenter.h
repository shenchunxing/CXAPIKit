//
//  TDFAPIHUDPresenter.h
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "CXAPIProtocol.h"
//================================================
//                HUD展示代理
//================================================


@class CXBaseAPI;
@protocol CXAPIHUDPresenter <NSObject>

@required
/**
 展示无网络视图
 */
- (void)apiShowNoNetworkView:(id<CXAPIProtocol>)api;
/**
 展示请求开始HUD
 */
- (void)apiShowBeginHUD:(id<CXAPIProtocol>)api;

/**
 隐藏请求开始HUD
 */
- (void)apiHideBeginHUD:(id<CXAPIProtocol>)api;

/**
 展示请求成功HUD
 
 @param response 响应数据
 */
- (void)api:(id<CXAPIProtocol>)api showSuccessHUD:(id)response;

/**
 展示请求失败HUD
 
 @param error 错误信息
 */
- (void)api:(id<CXAPIProtocol>)api showFailureHUD:(NSError *)error;

@end

