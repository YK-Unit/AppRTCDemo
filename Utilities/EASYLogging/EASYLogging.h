/**
 * In order to provide fast and flexible logging, this project uses Cocoa Lumberjack.
 * 
 * The Google Code page has a wealth of documentation if you have any questions.
 * http://code.google.com/p/cocoalumberjack/
 * 
 * Here's what you need to know concerning how logging is setup for EASYFramework:
 * 
 * There are 4 log levels:
 * - Error
 * - Warning
 * - Info
 * - Verbose
 * 
 * In addition to this, there is a Trace flag that can be enabled.
 * When tracing is enabled, it spits out the methods that are being called.
 * 
 * Please note that tracing is separate from the log levels.
 * For example, one could set the log level to warning, and enable tracing.
 * 
 * All logging is asynchronous, except errors.
 * To use logging within your own custom files, follow the steps below.
 * 
 * Step 1:
 * Import this header in your implementation file:
 * 
 * #import "EASYLogging.h"
 * 
 * Step 2:
 * Define your logging level in your implementation file:
 * 
 * // Log levels: off, error, warn, info, verbose
 * static const int EASYLogLevel = EASY_LOG_LEVEL_VERBOSE;
 * 
 * If you wish to enable tracing, you could do something like this:
 * 
 * // Log levels: off, error, warn, info, verbose
 * static const int EASYLogLevel = EASY_LOG_LEVEL_INFO | EASY_LOG_FLAG_TRACE;
 * 
 * Step 3:
 * Replace your NSLog statements with EASYLog statements according to the severity of the message.
 * 
 * NSLog(@"Fatal error, no dohickey found!"); -> EASYLogError(@"Fatal error, no dohickey found!");
 * 
 * EASYLog has the same syntax as NSLog.
 * This means you can pass it multiple variables just like NSLog.
 * 
 * You may optionally choose to define different log levels for debug and release builds.
 * You can do so like this:
 * 
 * // Log levels: off, error, warn, info, verbose
 * #if DEBUG
 *   static const int EASYLogLevel = EASY_LOG_LEVEL_VERBOSE;
 * #else
 *   static const int EASYLogLevel = EASY_LOG_LEVEL_WARN;
 * #endif
 * 
 * Xcode projects created with Xcode 4 automatically define DEBUG via the project's preprocessor macros.
 * If you created your project with a previous version of Xcode, you may need to add the DEBUG macro manually.
**/

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

// Define logging context for every log message coming from the EASY framework.
// The logging context can be extracted from the DDLogMessage from within the logging framework.
// This gives loggers, formatters, and filters the ability to optionally process them differently.

#define EASY_LOG_CONTEXT 5222

// Configure log levels.

#define EASY_LOG_FLAG_ERROR   (1 << 0) // 0...00001
#define EASY_LOG_FLAG_WARN    (1 << 1) // 0...00010
#define EASY_LOG_FLAG_INFO    (1 << 2) // 0...00100
#define EASY_LOG_FLAG_VERBOSE (1 << 3) // 0...01000

#define EASY_LOG_LEVEL_OFF     0                                              // 0...00000
#define EASY_LOG_LEVEL_ERROR   (EASY_LOG_LEVEL_OFF   | EASY_LOG_FLAG_ERROR)   // 0...00001
#define EASY_LOG_LEVEL_WARN    (EASY_LOG_LEVEL_ERROR | EASY_LOG_FLAG_WARN)    // 0...00011
#define EASY_LOG_LEVEL_INFO    (EASY_LOG_LEVEL_WARN  | EASY_LOG_FLAG_INFO)    // 0...00111
#define EASY_LOG_LEVEL_VERBOSE (EASY_LOG_LEVEL_INFO  | EASY_LOG_FLAG_VERBOSE) // 0...01111

// Setup fine grained logging.
// The first 4 bits are being used by the standard log levels (0 - 3)
// 
// We're going to add tracing, but NOT as a log level.
// Tracing can be turned on and off independently of log level.

#define EASY_LOG_FLAG_TRACE     (1 << 4) // 0...10000


// Setup the usual boolean macros.

#define EASY_LOG_ERROR   (EASYLogLevel & EASY_LOG_FLAG_ERROR)
#define EASY_LOG_WARN    (EASYLogLevel & EASY_LOG_FLAG_WARN)
#define EASY_LOG_INFO    (EASYLogLevel & EASY_LOG_FLAG_INFO)
#define EASY_LOG_VERBOSE (EASYLogLevel & EASY_LOG_FLAG_VERBOSE)
#define EASY_LOG_TRACE   (EASYLogLevel & EASY_LOG_FLAG_TRACE)

// Configure asynchronous logging.
// We follow the default configuration,
// but we reserve a special macro to easily disable asynchronous logging for debugging purposes.

#define EASY_LOG_ASYNC_ENABLED   YES

#define EASY_LOG_ASYNC_ERROR     ( NO && EASY_LOG_ASYNC_ENABLED)
#define EASY_LOG_ASYNC_WARN      (YES && EASY_LOG_ASYNC_ENABLED)
#define EASY_LOG_ASYNC_INFO      (YES && EASY_LOG_ASYNC_ENABLED)
#define EASY_LOG_ASYNC_VERBOSE   (YES && EASY_LOG_ASYNC_ENABLED)
#define EASY_LOG_ASYNC_TRACE     (YES && EASY_LOG_ASYNC_ENABLED)

// Define logging primitives.

#define EASYLogError(frmt, ...)    LOG_OBJC_MAYBE(EASY_LOG_ASYNC_ERROR,   EASYLogLevel, EASY_LOG_FLAG_ERROR,  \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define EASYLogWarn(frmt, ...)     LOG_OBJC_MAYBE(EASY_LOG_ASYNC_WARN,    EASYLogLevel, EASY_LOG_FLAG_WARN,   \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define EASYLogInfo(frmt, ...)     LOG_OBJC_MAYBE(EASY_LOG_ASYNC_INFO,    EASYLogLevel, EASY_LOG_FLAG_INFO,    \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define EASYLogVerbose(frmt, ...)  LOG_OBJC_MAYBE(EASY_LOG_ASYNC_VERBOSE, EASYLogLevel, EASY_LOG_FLAG_VERBOSE, \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define EASYLogTrace()             LOG_OBJC_MAYBE(EASY_LOG_ASYNC_TRACE,   EASYLogLevel, EASY_LOG_FLAG_TRACE, \
                                                  EASY_LOG_CONTEXT, @"%@: %@", THIS_FILE, THIS_METHOD)

#define EASYLogTrace2(frmt, ...)   LOG_OBJC_MAYBE(EASY_LOG_ASYNC_TRACE,   EASYLogLevel, EASY_LOG_FLAG_TRACE, \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)


#define EASYLogCError(frmt, ...)      LOG_C_MAYBE(EASY_LOG_ASYNC_ERROR,   EASYLogLevel, EASY_LOG_FLAG_ERROR,   \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define EASYLogCWarn(frmt, ...)       LOG_C_MAYBE(EASY_LOG_ASYNC_WARN,    EASYLogLevel, EASY_LOG_FLAG_WARN,    \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define EASYLogCInfo(frmt, ...)       LOG_C_MAYBE(EASY_LOG_ASYNC_INFO,    EASYLogLevel, EASY_LOG_FLAG_INFO,    \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define EASYLogCVerbose(frmt, ...)    LOG_C_MAYBE(EASY_LOG_ASYNC_VERBOSE, EASYLogLevel, EASY_LOG_FLAG_VERBOSE, \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define EASYLogCTrace()               LOG_C_MAYBE(EASY_LOG_ASYNC_TRACE,   EASYLogLevel, EASY_LOG_FLAG_TRACE, \
                                                  EASY_LOG_CONTEXT, @"%@: %s", THIS_FILE, __FUNCTION__)

#define EASYLogCTrace2(frmt, ...)     LOG_C_MAYBE(EASY_LOG_ASYNC_TRACE,   EASYLogLevel, EASY_LOG_FLAG_TRACE, \
                                                  EASY_LOG_CONTEXT, frmt, ##__VA_ARGS__)

// Setup logging for EASYStream (and subclasses such as EASYStreamFacebook)

#define EASY_LOG_FLAG_SEND      (1 << 5)
#define EASY_LOG_FLAG_RECV_PRE  (1 << 6) // Prints data before it goes to the parser
#define EASY_LOG_FLAG_RECV_POST (1 << 7) // Prints data as it comes out of the parser

#define EASY_LOG_FLAG_SEND_RECV (EASY_LOG_FLAG_SEND | EASY_LOG_FLAG_RECV_POST)

#define EASY_LOG_SEND      (EASYLogLevel & EASY_LOG_FLAG_SEND)
#define EASY_LOG_RECV_PRE  (EASYLogLevel & EASY_LOG_FLAG_RECV_PRE)
#define EASY_LOG_RECV_POST (EASYLogLevel & EASY_LOG_FLAG_RECV_POST)

#define EASY_LOG_ASYNC_SEND      (YES && EASY_LOG_ASYNC_ENABLED)
#define EASY_LOG_ASYNC_RECV_PRE  (YES && EASY_LOG_ASYNC_ENABLED)
#define EASY_LOG_ASYNC_RECV_POST (YES && EASY_LOG_ASYNC_ENABLED)

#define EASYLogSend(format, ...)     LOG_OBJC_MAYBE(EASY_LOG_ASYNC_SEND, EASYLogLevel, EASY_LOG_FLAG_SEND, \
                                                    EASY_LOG_CONTEXT, format, ##__VA_ARGS__)

#define EASYLogRecvPre(format, ...)  LOG_OBJC_MAYBE(EASY_LOG_ASYNC_RECV_PRE, EASYLogLevel, EASY_LOG_FLAG_RECV_PRE, \
                                                    EASY_LOG_CONTEXT, format, ##__VA_ARGS__)

#define EASYLogRecvPost(format, ...) LOG_OBJC_MAYBE(EASY_LOG_ASYNC_RECV_POST, EASYLogLevel, EASY_LOG_FLAG_RECV_POST, \
                                                    EASY_LOG_CONTEXT, format, ##__VA_ARGS__)

#if DEBUG
static const int EASYLogLevel = EASY_LOG_LEVEL_VERBOSE;
#else
static const int EASYLogLevel = EASY_LOG_LEVEL_WARN;
#endif


//Added by Zhiyu Zhang
#define EASYLogStartEngine \
        [DDLog addLogger:[DDASLLogger sharedInstance]];[DDLog addLogger:[DDTTYLogger sharedInstance]]
