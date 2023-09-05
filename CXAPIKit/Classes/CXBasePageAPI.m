//
//  CXBasePageAPI.m
//  CXAPIKit
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXBasePageAPI.h"

NSString *const kCXAPIPageNumberKeyPageSize = @"pageSize";     /// pageSize
NSString *const kCXAPIPageNumberKeyPageIndex = @"curPage";   /// pageIndex
const NSInteger kCXAPIDefaultPageSize = 10;
@interface CXBasePageAPI ()
@property (assign, nonatomic) NSInteger currentPageSize;
@end

@implementation CXBasePageAPI

#pragma mark - override
- (NSInteger)apiCurrentPageSizeForResponse:(id)response {
    NSString *exceptionName =
    [NSString stringWithFormat:@"Fail to get page size for response %@.", response];
    NSString *exceptionReason =
    [NSString stringWithFormat:@"API should override %@", NSStringFromSelector(_cmd)];
    @throw [[NSException alloc] initWithName:exceptionName
                                      reason:exceptionReason
                                    userInfo:nil];
}

- (NSInteger)apiDefaultPageSize {
    return kCXAPIDefaultPageSize;
}

- (NSString *)apiPageNumberKey {
    return kCXAPIPageNumberKeyPageIndex;
}

- (NSString *)apiPageSizeKey {
    return kCXAPIPageNumberKeyPageSize;
}

#pragma mark - operate
- (BOOL)start {
    self.pageNumber = 1;
    self.currentPageSize = NSNotFound;
    return [super start];
}

- (BOOL)startForNextPage {
    self.pageNumber += 1;
    
    BOOL success = [super start];
    
    //如果接口调用失败，回到上一页
    if (!success) {
        self.pageNumber -= 1;
    }
    
    return success;
}

#pragma mark - interceptor
- (BOOL)beforePerformSuccessWithResponse:(id)response {
    BOOL valid = [super beforePerformSuccessWithResponse:response];
    
    self.currentPageSize = [self apiCurrentPageSizeForResponse:response];
    
    return valid;
}

- (BOOL)beforePerformFailureWithResponse:(id)response {
    
    BOOL valid = [super beforePerformFailureWithResponse:response];
    if (self.pageNumber > 0) {
        self.pageNumber -= 1;
    }
    return valid;
}
#pragma mark - override

//先拿到默认参数，再加上分页需要的size和num参数
- (NSDictionary *)reformedParams {
    
    NSAssert([self apiPageNumberKey], @"Api page number key can't be nil");
    
    NSMutableDictionary *paramsM = [super reformedParams].mutableCopy;
    paramsM[[self apiPageSizeKey]] = @(self.apiDefaultPageSize).stringValue;
    paramsM[[self apiPageNumberKey]] = @(self.pageNumber).stringValue;
    return paramsM;
}

#pragma mark getter
- (BOOL)hasNextPage {
    return self.currentPageSize == NSNotFound ||
    self.currentPageSize >= self.apiDefaultPageSize;
}

- (void)setPageNumber:(NSInteger)pageNumber {
    NSAssert(pageNumber >= 0, @"Page number can't be negative number.");
    
    _pageNumber = pageNumber;
}
@end
