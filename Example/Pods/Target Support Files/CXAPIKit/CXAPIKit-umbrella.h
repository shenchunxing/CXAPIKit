#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CXAPIDataReformer.h"
#import "CXAPIHUDPresenter.h"
#import "CXAPIInterceptor.h"
#import "CXAPIKit.h"
#import "CXAPIManager.h"
#import "CXAPIProtocol.h"
#import "CXBaseAPI.h"
#import "CXBasePageAPI.h"
#import "CXBatchAPIRequest.h"
#import "CXGeneralAPI.h"
#import "CXGeneralPageAPI.h"

FOUNDATION_EXPORT double CXAPIKitVersionNumber;
FOUNDATION_EXPORT const unsigned char CXAPIKitVersionString[];

