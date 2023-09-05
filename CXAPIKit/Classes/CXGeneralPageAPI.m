//
//  CXGeneralPageAPI.m
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXGeneralPageAPI.h"
#import <CXNetworking/CXRequestModel.h>

@implementation CXGeneralPageAPI
#pragma mark - override
- (CXRequestModel *)apiRequestModel {
    return self.requestModel;
}

- (NSDictionary *)apiRequestParams {
    return self.params;
}

- (NSInteger)apiCurrentPageSizeForResponse:(id)response {
    NSAssert(self.currentPageSizeBlock, @"Block to parsing page size can't be nil.");
    
    return self.currentPageSizeBlock(response);
}

- (NSInteger)apiDefaultPageSize {
    if (self.defaultPageSize > 0) {
        return self.defaultPageSize;
    }
    
    return [super apiDefaultPageSize];
}

- (id)apiReformResponse:(id)response {
    
    if (self.dataReformer) {
        return [self.dataReformer api:self reformResponse:response];
    }
    return response;
}

- (NSString *)apiPageNumberKey {
    if (self.pageNumberKey) {
        return self.pageNumberKey;
    }
    return [super apiPageNumberKey];
}

- (NSString *)apiPageSizeKey {
    if (self.pageSizeKey) {
        return self.pageSizeKey;
    }
    return [super apiPageSizeKey];
}

#pragma mark - getter
- (NSMutableDictionary *)params {
    if (_params == nil) {
        _params = [NSMutableDictionary dictionary];
    }
    
    return _params;
}
@end
