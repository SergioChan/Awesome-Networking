//
//  ANOperation.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ANOperation.h"

static dispatch_queue_t http_request_operation_processing_queue() {
    static dispatch_queue_t af_http_request_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_http_request_operation_processing_queue = dispatch_queue_create("com.sergio.awesome-networking.http-request.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return af_http_request_operation_processing_queue;
}

static dispatch_group_t http_request_operation_completion_group() {
    static dispatch_group_t af_http_request_operation_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_http_request_operation_completion_group = dispatch_group_create();
    });
    
    return af_http_request_operation_completion_group;
}

@implementation ANOperation

@synthesize operationId;
@synthesize timestamp;

#pragma mark - Coding method
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.operationId = [[decoder decodeObjectForKey:@"id"] integerValue];
    self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:[NSNumber numberWithInteger:operationId] forKey:@"id"];
    [coder encodeObject:timestamp forKey:@"timestamp"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ANOperation *operation = [super copyWithZone:zone];
    
    operation.operationId = self.operationId;
    operation.timestamp = self.timestamp;
    
    return operation;
}

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (!self) {
        return nil;
    }
    self.operationId = (NSInteger)[[NSDate date] timeIntervalSince1970];
    self.timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return self;
}

- (void)setANCompletionBlockWithSuccess:(void (^)(ANOperation *operation, id responseObject))success
                              failure:(void (^)(ANOperation *operation, NSError *error))failure
{
    // completionBlock is manually nilled out in AFURLConnectionOperation to break the retain cycle.
    __weak ANOperation *weakSelf = self;
    self.completionBlock = ^{
        if (weakSelf.completionGroup) {
            dispatch_group_enter(weakSelf.completionGroup);
        }
        
        dispatch_async(http_request_operation_processing_queue(), ^{
            if (weakSelf.error) {
                if (failure) {
                    dispatch_group_async(weakSelf.completionGroup ?: http_request_operation_completion_group(), weakSelf.completionQueue ?: dispatch_get_main_queue(), ^{
                        failure(weakSelf, weakSelf.error);
                    });
                }
            } else {
                id responseObject = weakSelf.responseObject;
                if (weakSelf.error) {
                    if (failure) {
                        dispatch_group_async(weakSelf.completionGroup ?: http_request_operation_completion_group(), weakSelf.completionQueue ?: dispatch_get_main_queue(), ^{
                            failure(weakSelf, weakSelf.error);
                        });
                    }
                } else {
                    if (success) {
                        dispatch_group_async(weakSelf.completionGroup ?: http_request_operation_completion_group(), weakSelf.completionQueue ?: dispatch_get_main_queue(), ^{
                            success(weakSelf, responseObject);
                        });
                    }
                }
            }
            
            if (weakSelf.completionGroup) {
                dispatch_group_leave(weakSelf.completionGroup);
            }
        });
    };
}
@end
