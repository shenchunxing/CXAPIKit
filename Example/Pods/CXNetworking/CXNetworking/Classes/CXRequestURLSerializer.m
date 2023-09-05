//
//  CXRequestURLSerializer.m
//  CXNetworking
//
//  Created by shenchunxing on 2021/3/26.
//

#import "CXRequestURLSerializer.h"
#import "CXRequestModel.h"
#import "CXHTTPClient.h"

@implementation CXRequestURLSerializer

+ (NSString *)URLForRequest:(CXRequestModel *)request {
    
    NSString *urlString = request.serverRoot;
    
    if (request.portName.length > 0) {
        urlString = [urlString stringByAppendingFormat:@"/%@", request.portName];
    }
    
    if (request.apiVersion.length > 0) {
       urlString = [urlString stringByAppendingFormat:@"/%@", request.apiVersion];
    }
    
    if (request.serviceName.length > 0) {
        urlString = [urlString stringByAppendingFormat:@"/%@", request.serviceName];
    }
    
    if (request.actionPath.length > 0) {
        urlString = [urlString stringByAppendingFormat:@"/%@", request.actionPath];
    }

    NSURL *url = [NSURL URLWithString:urlString];
    
    return url.absoluteString;
}

@end
