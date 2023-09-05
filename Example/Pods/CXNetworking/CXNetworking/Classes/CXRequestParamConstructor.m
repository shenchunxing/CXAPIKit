//
//  CXRequestParamConstructor.m
//  CXNetworking
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXRequestParamConstructor.h"
#import "CXRequestModel.h"
#import "CXNetworkConfig.h"

@implementation CXRequestParamConstructor

+ (NSMutableDictionary *)parametersForRequest:(CXRequestModel *)requestModel {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    //添加业务参数
    [params addEntriesFromDictionary:requestModel.parameters];
    
    return params;
}

+ (NSMutableDictionary *)headersForRequest:(CXRequestModel *)requestModel {
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    //添加共通参数
//    headers[@"token"] = [[CXDataCenter sharedData] getObjectByKey:@"token"];
    headers[@"system"] = kCXSystem;
    return headers;
}


+ (NSString *)cx_operateId {
    //TODO:添加操作id
    return @"";
}

+ (NSString *)cx_operateName {
    //TODO:添加操作名
    return @"";
}

+ (NSString *)cx_roleName {
    return @"";
}

@end
