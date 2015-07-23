//
//  ANOperationQueue.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANOperationQueue : NSOperationQueue

@property (nonatomic, strong) NSMutableDictionary *requestSet;

- (BOOL)cancelOperationByOperationId:(NSInteger)operationId;
- (BOOL)cacheOperationByOperationId:(NSInteger)operationId;

- (NSArray *)getAllOperations;

+ (ANOperationQueue *) sharedInstance;

- (BOOL)cacheAllOperation;
- (BOOL)cancelAllOperation;

@end
