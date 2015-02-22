//
//  UncaughtExceptionHandler.m
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

#import "UncaughtExceptionHandler.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"%@", exception.callStackSymbols);
}

NSUncaughtExceptionHandler *uncaughtExceptionHandlerPointer = &uncaughtExceptionHandler;