//
//  HFCrashMonitor.h
//  HFBugMonitor
//
//  Created by CoderHF on 2018/11/5.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*!
 *  @brief  崩溃监控
 */
@interface HFCrashMonitor : NSObject

/**
 开启全局监控
 */
+ (void)startMonitoring;

@end

NS_ASSUME_NONNULL_END
