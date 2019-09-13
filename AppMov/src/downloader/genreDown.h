//
//  genreDown.h
//  AppMov


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol genreDownDelegate <NSObject>

- (void)genreDownComplete:(NSString*)MsgCor;
- (void)genreDownEndsWithError:(NSString*)errMsg;

@end


@import Foundation;
typedef void (^CompletionHandler)(void);

@interface genreDown : NSObject<NSURLSessionDelegate,
NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>{
  id <genreDownDelegate> _delegate;
}
@property (nonatomic, strong) id delegate;
@property (strong, nonatomic) NSString *serverURL;



- (void)initDown;

@end

NS_ASSUME_NONNULL_END
