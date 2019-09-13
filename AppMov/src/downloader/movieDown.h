//
//  movie.h
//  AppMov

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol movieDownDelegate <NSObject>

- (void)movieDownDelegateComplete:(NSString*)MsgCor;
- (void)movieDownDelegateEndsWithError:(NSString*)errMsg;

@end


@import Foundation;
typedef void (^CompletionHandler)(void);
@interface movieDown : NSObject <NSURLSessionDelegate,
NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>{
  id <movieDownDelegate> _delegate;
}
@property (nonatomic, strong) id delegate;
@property (strong, nonatomic) NSString *serverURL;



- (void)initDown;


@end

NS_ASSUME_NONNULL_END
