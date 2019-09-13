//
//  DBGenre.h
//  AppMov

//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBGenre : NSObject{
  NSInteger genreId;
  NSString *name;
}

@property (nonatomic, assign) NSInteger genreId;
@property (nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
