//
//  HFBacktraceLogger.h
//  HFBugMonitor
//
//  Created by CoderHF on 2018/11/5.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @brief  线程堆栈上下文输出(网上抄的就是查看线程栈)
 */
@interface HFBacktraceLogger : NSObject

+ (NSString *)HF_backtraceOfAllThread;
+ (NSString *)HF_backtraceOfMainThread;
+ (NSString *)HF_backtraceOfCurrentThread;
+ (NSString *)HF_backtraceOfNSThread:(NSThread *)thread;

+ (void)HF_logMain;
+ (void)HF_logCurrent;
+ (void)HF_logAllThread;

+ (NSString *)backtraceLogFilePath;
+ (void)recordLoggerWithFileName: (NSString *)fileName;
@end

NS_ASSUME_NONNULL_END
