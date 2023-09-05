//
//  CXNetworkConfig.h
//  CXNetworking
//
//  Created by shenchunxing on 2021/5/30.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * _Nonnull kProjectAPIRoot;

#define CX_NC_FOR_KEY(key) \
({ \
id value = [CXNetworkConfig shared].key; \
NSAssert(value, @"%@ can not be nil, you should setup it in CXNetworkConfig init category.", @#key); \
value; \
})

#define CX_NC_SET_API(value)\
[CXNetworkConfig shared].projectAPIRoot = value;

#define kCXProjectAPIRoot CX_NC_FOR_KEY(projectAPIRoot)
#define kCXSystem CX_NC_FOR_KEY(system)
#define kCXPortName CX_NC_FOR_KEY(portName)

NS_ASSUME_NONNULL_BEGIN
@protocol CXNetworkConfigInitialProtocol <NSObject>
@required
- (void)initConfig;
@end

@interface CXNetworkConfig : NSObject

/* api root地址 */
@property (nonatomic, copy) NSString *projectAPIRoot;

/* 系统 */
@property (nonatomic, copy) NSString *system;

/* 端口 */
@property (nonatomic, copy) NSString *portName;

+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
