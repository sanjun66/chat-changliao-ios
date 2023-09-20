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

#import "YCDownloadDB.h"
#import "YCDownloader.h"
#import "YCDownloadSession.h"
#import "YCDownloadTask.h"
#import "YCDownloadUtils.h"
#import "YCDownloadItem.h"
#import "YCDownloadManager.h"

FOUNDATION_EXPORT double YCDownloadSessionVersionNumber;
FOUNDATION_EXPORT const unsigned char YCDownloadSessionVersionString[];

