//
//  movie.m
//  AppMov




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "movieDown.h"
#import "AppDelegate.h"
#import "DBManager.h"

@interface movieDown(){
  AppDelegate *adelegate;
  BOOL _sendError;
}

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation movieDown

- (void)initDown{
  
  adelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  [self setSession:[self backgroundSession:@"com.appmov.exp"]];
  [self sendToUrl:[NSString stringWithFormat:@"%@movie/popular?", adelegate.urlBase ]];
  
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
  
  // Create NSURLSession object
  //NSURLSession *sessionn = [NSURLSession sharedSession];
  url = [NSString stringWithFormat:@"%@%@", url, params];
  NSURL *urld = [NSURL URLWithString:url];
 //[req setHTTPMethod:@"GET"];
 // [req setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
  NSURLSessionDownloadTask *stask = [self.session downloadTaskWithURL:urld];
  [stask resume];
  
  // Create a NSURL object.
/*  NSURL *urld = [NSURL URLWithString:url];
  
  // Create NSURLSessionDataTask task object by url and session object.
  NSURLSessionDataTask *task = [sessionn dataTaskWithURL:urld completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    
    // Print response JSON data in the console.
    NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
    
  }];
  
  // Begin task.
  [task resume];*/
  
  
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
      [dbMng InsertFilms:[dic objectForKey:@"results"]];
      
      [self finishConnection:@""];
    }
  }
}

- (void)finishConnection:(NSString *)res {
  if(self.delegate != nil) {
    [self.delegate movieDownDelegateComplete:res];
  }
}

- (void)finishWithError:(NSString *)err {
  if(self.delegate != nil) {
    [self.delegate movieDownDelegateEndsWithError:err];
  }
}


@end
