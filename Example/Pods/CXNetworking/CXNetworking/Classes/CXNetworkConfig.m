//
//  CXNetworkConfig.m
//  CXNetworking
//
//  Created by shenchunxing on 2021/5/30.
//

#import "CXNetworkConfig.h"

NSString *kProjectAPIRoot = @"http://192.168.2.16";

@implementation CXNetworkConfig

+ (instancetype)shared {
    
    static CXNetworkConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CXNetworkConfig alloc] init];
    });
    return instance;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        // 其他业务线可以选择创建分类文件放进主工程
        if (![self conformsToProtocol:@protocol(CXNetworkConfigInitialProtocol)]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"You should implement a category of CXNetworkConfig class and then conform the <CXNetworkConfigInitialProtocol> protocol to init all ivars in -initDefaultsInformation method" userInfo:nil];
        }
        
        [(id <CXNetworkConfigInitialProtocol>)self initConfig];
    }
    return self;
}
@end
