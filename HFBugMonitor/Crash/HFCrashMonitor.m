//
//  HFCrashMonitor.m
//  HFBugMonitor
//
//  Created by CoderHF on 2018/11/5.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import "HFCrashMonitor.h"
#import <UIKit/UIKit.h>
#import "HFBacktraceLogger.h"
void (*other_exception_caught_handler)(NSException * exception) = NULL;

@implementation HFCrashMonitor
{
    BOOL ignore;
}
static void __HF_exception_caught(NSException * exception) {
    NSDictionary * infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString * appInfo = [NSString stringWithFormat: @"Device: %@\nOS Version: %@\nOS System: %@", [UIDevice currentDevice].model, infoDict[@"CFBundleShortVersionString"], [[UIDevice currentDevice].systemName stringByAppendingString: [UIDevice currentDevice].systemVersion]];
    
    
    NSString *stackInfo = nil;
    stackInfo = [[exception callStackSymbols] debugDescription];
    
    //
    if (!stackInfo) {
        stackInfo = [HFBacktraceLogger HF_backtraceOfCurrentThread];
    }
    //可以在这里搞一下自己的数据库链接什么的，记录一下exception 信息  建议是显存本地 累计几次之后再用户再次打开app的时候，在应用进入后台时开启一个上传crash的任务
  
    
 
    HFCrashMonitor *crashObject = [HFCrashMonitor sharedInstance];
    NSException *customException = [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:nil];
    [crashObject performSelectorOnMainThread:@selector(handleException:) withObject:customException waitUntilDone:YES];


    if (other_exception_caught_handler != NULL) {
        (*other_exception_caught_handler)(exception);
    }
    
    
}


- (void)handleException:(NSException *)exception
{
    NSString *message = [NSString stringWithFormat:@"崩溃原因如下:\n%@\n",
                         [exception reason]];
    NSLog(@"%@",message);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"程序崩溃了"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"再活一次"
                                          otherButtonTitles:@"朕知道了", nil];
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!ignore) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    

}
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 0) {
        
    }else{
        ignore = YES;

    }
    
}
CF_INLINE NSString * __signal_name(int signal) {
    switch (signal) {
            /// 非法指令
        case SIGILL:
            return @"SIGILL";
            /// 计算错误
        case SIGFPE:
            return @"SIGFPE";
            /// 总线错误
        case SIGBUS:
            return @"SIGBUS";
            /// 无进程接手数据
        case SIGPIPE:
            return @"SIGPIPE";
            /// 无效地址
        case SIGSEGV:
            return @"SIGSEGV";
            /// abort信号
        case SIGABRT:
            return @"SIGABRT";
        default:
            return @"Unknown";
    }
}

CF_INLINE NSString * __signal_reason(int signal) {
    switch (signal) {
            /// 非法指令
        case SIGILL:
            return @"Invalid Command";
            /// 计算错误
        case SIGFPE:
            return @"Math Type Error";
            /// 总线错误
        case SIGBUS:
            return @"Bus Error";
            /// 无进程接手数据
        case SIGPIPE:
            return @"No Data Receiver";
            /// 无效地址
        case SIGSEGV:
            return @"Invalid Address";
            /// abort信号
        case SIGABRT:
            return @"Abort Signal";
        default:
            return @"Unknown";
    }
}

static void __HF_signal_handler(int signal) {
    __HF_exception_caught([NSException exceptionWithName: __signal_name(signal) reason: __signal_reason(signal) userInfo: nil]);
    [HFCrashMonitor _killApp];
}


#pragma mark - Public
+ (void)startMonitoring {
    [self sharedInstance];

    other_exception_caught_handler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(__HF_exception_caught);
    signal(SIGILL, __HF_signal_handler);
    signal(SIGFPE, __HF_signal_handler);
    signal(SIGBUS, __HF_signal_handler);
    signal(SIGPIPE, __HF_signal_handler);
    signal(SIGSEGV, __HF_signal_handler);
    signal(SIGABRT, __HF_signal_handler);
    
}


#pragma mark - Private
+ (void)_killApp {
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGILL, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
    kill(getpid(), SIGKILL);
}

static HFCrashMonitor *instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}


@end
