#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNArch, NSObject)

RCT_EXTERN__BLOCKING_SYNCHRONOUS_METHOD(getName)

RCT_EXTERN_METHOD(
    isProtectedZip:(NSString *)srcPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    zip:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    password:(NSString *)password
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    isProtectedRar:(NSString *)srcPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    rar:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    password:(NSString *)password
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    isProtectedSevenZip:(NSString *)srcPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    sevenZip:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    password:(NSString *)password
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    isProtectedPdf:(NSString *)srcPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    pdf:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    password:(NSString *)password
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
