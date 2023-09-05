//
//  CXGeneralAPI.h
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXBaseAPI.h"
#import "CXRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

//================================================
//            在baseapi基础上，参数外露，直接配置
//================================================

@interface CXGeneralAPI : CXBaseAPI
/** 根据模块派生的CXRequestModel子类.每个模块有属于自己的CXRequestModel子类 */
@property (strong, nonatomic) CXRequestModel *requestModel;
/** 参数 */
@property (strong, nonatomic) NSMutableDictionary *params;
@property (nonatomic, copy) NSString *serverRoot;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, copy) NSString *actionPath;
@property (nonatomic, copy) NSString *apiVersion;
@property (nonatomic, copy) NSString *portName;
@property (nonatomic, assign) CXHttpRequestType  requestType;


+ (instancetype)requestModelWithActionPath:(NSString *)actionPath;

@end

NS_ASSUME_NONNULL_END
