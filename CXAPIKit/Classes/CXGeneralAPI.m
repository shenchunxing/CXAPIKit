//
//  CXGeneralAPI.m
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXGeneralAPI.h"
#import <CXNetworking/CXRequestModel.h>

@implementation CXGeneralAPI

+ (instancetype)requestModelWithActionPath:(NSString *)actionPath {
    CXGeneralAPI *api = [[CXGeneralAPI alloc] init];
    api.requestModel = [CXRequestModel modelWithActionPath:actionPath];
    return api;
}

- (void)setRequestType:(CXHttpRequestType)requestType {
    _requestType = requestType;
    if (!self.requestModel) return;
    self.requestModel.requestType = requestType;
}

- (void)setServerRoot:(NSString *)serverRoot {
    _serverRoot = serverRoot;
    if (!self.requestModel) return;
    self.requestModel.serverRoot = serverRoot;
}

- (void)setServiceName:(NSString *)serviceName {
    _serviceName = serviceName;
    if (!self.requestModel) return;
    self.requestModel.serviceName = serviceName;
}

- (void)setActionPath:(NSString *)actionPath {
    _actionPath = actionPath;
    if (!self.requestModel) return;
    self.requestModel.actionPath = actionPath;
}

- (void)setPortName:(NSString *)portName {
    _portName = portName;
    if (!self.requestModel) return;
    self.requestModel.portName = portName;
}

- (void)setApiVersion:(NSString *)apiVersion {
    _apiVersion = apiVersion;
    if (!self.requestModel) return;
    self.requestModel.apiVersion = apiVersion;
}

#pragma mark - override
- (CXRequestModel *)apiRequestModel {
    return self.requestModel;
}

- (NSDictionary *)apiRequestParams {
    return self.params;
}

- (id)apiReformResponse:(id)response {
    if (self.dataReformer) {
        return [self.dataReformer api:self reformResponse:response];
    }
    return response;
}
#pragma mark - getter

- (NSMutableDictionary *)params {
    if (_params == nil) {
        _params = [NSMutableDictionary dictionary];
    }
    
    return _params;
}
@end
