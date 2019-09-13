//
//  DBNote.h
//  AppMov

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBNote : NSObject{
  NSInteger noteId;
  NSString *title;
  NSString *regDate;
}

@property (nonatomic, assign) NSInteger noteId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *regDate;

@end

NS_ASSUME_NONNULL_END
