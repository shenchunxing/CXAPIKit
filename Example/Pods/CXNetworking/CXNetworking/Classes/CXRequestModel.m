//
//  CXRequestModel.m
//  CXNetworking
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXRequestModel.h"
#import "CXNetworkConfig.h"

@implementation CXRequestModel

+ (instancetype)modelWithActionPath:(const NSString *)actionPath {
    
    CXRequestModel *model = [[self alloc] init];
    model.actionPath = (NSString *)actionPath;
    return model;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.requestType = CXHttpRequestTypeGet;
        self.serverRoot = kProjectAPIRoot;
        self.portName = kCXPortName;
        self.apiVersion = @"v1";
        self.serializerType = CXRequestSerializerTypeJson;
    }
   return self;
}

- (NSString *)convertURLPart:(NSString *)urlPart {
    NSMutableString  *mutableString = [urlPart mutableCopy];
    
    if ([mutableString hasPrefix:@"/"]) {
        [mutableString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    if ([mutableString hasSuffix:@"/"]) {
        [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 1, 1)];
    }
    
    return [mutableString copy];
}

- (void)setServerRoot:(NSString *)serverRoot {
    _serverRoot = [self convertURLPart:serverRoot];
}

- (void)setPortName:(NSString *)portName {
    _portName = [self convertURLPart:portName];
}

- (void)setApiVersion:(NSString *)apiVersion {
    _apiVersion = [self convertURLPart:apiVersion];
}

- (void)setServiceName:(NSString *)serviceName {
    _serviceName = [self convertURLPart:serviceName];
}

- (void)setActionPath:(NSString *)actionPath {
    _actionPath = [self convertURLPart:actionPath];
}


@end
