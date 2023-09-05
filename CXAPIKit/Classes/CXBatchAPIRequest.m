//
//  CXBatchAPIRequest.m
//  CXAPIKit
//
//  Created by shenchunxing on 2021/6/6.
//

#import "CXBatchAPIRequest.h"
#import "CXBasePageAPI.h"
#import "CXAPIManager.h"

@interface CXBatchAPIRequest ()
@property (strong, nonatomic) NSMutableSet <CXBaseAPI *> *apisSet;
@end
@implementation CXBatchAPIRequest

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.cancelUnfinishedRequestWhenAnyAPIFailed = YES;
        self.enableAPIPresenters = NO;
    }
    return self;
}


- (void)addAPIRequest:(CXBaseAPI *)api {
    
    NSCParameterAssert(api);
    NSAssert([api isKindOfClass:[CXBaseAPI class]], @"Api is not a valid type.");
    NSAssert(![api isKindOfClass:[CXBasePageAPI class]], @"Batch api request unsupport page api type.");
    @synchronized (self) {
        [self.apisSet addObject:api];
    }
}

- (void)addBatchAPIRequests:(id <NSFastEnumeration>)apis {
    
    NSCParameterAssert(apis);
    @synchronized (self) {
        for (CXBaseAPI *api in apis) {
            NSAssert([api isKindOfClass:[CXBaseAPI class]], @"Api is not a valid type.");
            NSAssert(![api isKindOfClass:[CXBasePageAPI class]], @"Batch api request unsupport page api type.");
            [self.apisSet addObject:api];
        }
    }
}

- (void)retry {
    NSAssert(self.apisSet.count > 0, @"Count of api should be more than 0");
    
    for (CXBaseAPI *subapi in self.apisSet) {
        subapi->_retry = YES;
    }
    
    _canceled = NO;
    [[CXAPIManager shareInstance] sendBatchRequest:self];
}

- (BOOL)start {
    NSAssert(self.apisSet.count > 0, @"Count of api should be more than 0");
    
    if (self.isLoading) return NO;
    
    _canceled = NO;
    [[CXAPIManager shareInstance] sendBatchRequest:self];
    
    return YES;
}

- (void)cancel {
    NSAssert(self.apisSet.count > 0, @"Count of api should be more than 0");
    
    _canceled = YES;
    @synchronized (self) {
        for (CXBaseAPI *subapi in self.apisSet) {
            [subapi cancel];
        }
    }
}



- (NSMutableSet<CXBaseAPI *> *)apisSet {
    
    if (_apisSet == nil) {
        _apisSet = [[NSMutableSet alloc] init];
        
    }
    return _apisSet;
}
@end
