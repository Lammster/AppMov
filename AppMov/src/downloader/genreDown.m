//
//  genreDown.m
//  AppMov


#import "genreDown.h"
#import "AppDelegate.h"
#import "DBManager.h"

@interface genreDown(){
  AppDelegate *adelegate;
  BOOL _sendError;
}

@property (strong, nonatomic) NSURLSession *session;

@end
@implementation genreDown
- (void)initDown{
  
  adelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  [self setSession:[self backgroundSession:@"com.appmov.gen"]];
  [self sendToUrl:[NSString stringWithFormat:@"%@genre/movie/list?", adelegate.urlBase ]];
  
}

- (NSURLSession *)backgroundSession:(NSString*)sendId {
  static NSURLSession *urlSession;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    NSURLSessionConfiguration *bgConfig = [NSURLSessionConfiguration
                                           backgroundSessionConfigurationWithIdentifier:sendId];
    [bgConfig setHTTPMaximumConnectionsPerHost:50];
    urlSession = [NSURLSession sessionWithConfiguration:bgConfig
                                               delegate:self
                                          delegateQueue:nil];
    [bgConfig retain];
  });
  
  return urlSession;
}

- (void)sendToUrl:(NSString*)url{
  
  NSString *params = [NSString stringWithFormat:@"api_key=%@&language=en-US", adelegate.api_key];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                 timeoutInterval:60*3];
  
  url = [NSString stringWithFormat:@"%@%@", url, params];
  NSURL *urld = [NSURL URLWithString:url];
  NSURLSessionDownloadTask *stask = [self.session downloadTaskWithURL:urld];
  [stask resume];
  
}

/* *******************************************
 * *** Inicia delegado NSURLSession
 * ******************************************* */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
  [self eventResponse:location];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
  if(adelegate.bgSessionCompHandler) {
    CompletionHandler compHandler = adelegate.bgSessionCompHandler;
    adelegate.bgSessionCompHandler = nil;
    compHandler();
  }
  NSLog(@">>>>>Al parecer terminó");
}

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
}

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
}

- (void)URLSession:(NSURLSession*)session didBecomeInvalidWithError:(NSError *)error {
  NSLog(@">>>>>Error:%@",[error debugDescription]);
  _sendError = true;
  [self finishWithError:@"No se pudo conectar al servidor, por favor intentelo mas tarde."];
}

- (void)URLSession:(NSURLSession*)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
  NSLog(@">>>>>Error:%@",[error debugDescription]);
  if (error != nil) {
    [self finishWithError:@"Lo sentimos. No se ha podido procesar tu solicitud. Favor de revisar tu conexión a Internet y volver a intenar."];
  }
}
/* *******************************************
 * *** Termina delegado NSURLSession
 * ******************************************* */

- (void)eventResponse:(NSURL*)location {
  NSData *urlData = [NSData dataWithContentsOfURL:location];
  NSString *res = [[NSString alloc] initWithData:urlData
                                        encoding:NSUTF8StringEncoding];
  NSError *err = nil;
  NSData *data = [res dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                      options:kNilOptions
                                                        error:&err];
  if(!_sendError) {
    if(err != nil) {
      [self finishWithError:@"Lo sentimos. No se ha podido procesar tu solicitud. Favor de revisar tu conexión a Internet y volver a intenar."];
    }else if(dic==nil) {
      [self finishWithError:@"  "];
    } else if([[dic allKeys] containsObject:@"status_message"]) {
      [self finishWithError:[dic objectForKey:@"status_message"]];
    } else {
      
      
      BOOL _ifUpdate = false;
      DBManager *dbMng = [[DBManager alloc] init];
      [dbMng InsertGenre:[dic objectForKey:@"genres"]];
      
      
      [self finishConnection:@""];
    }
  }
}

- (void)finishConnection:(NSString *)res {
  if(self.delegate != nil) {
    [self.delegate genreDownComplete:res];
  }
}

- (void)finishWithError:(NSString *)err {
  if(self.delegate != nil) {
    [self.delegate genreDownEndsWithError:err];
  }
}

@end
