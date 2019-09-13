//
//  DBMovie.h
//  AppMov
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBMovie : NSObject {
  NSInteger filmId;
  NSString *nameFilm;
  NSString *poster;
  NSString *date;
  NSMutableArray * genDic;
  
}

@property (nonatomic, assign) NSInteger filmId;
@property (nonatomic, retain) NSString *nameFilm;
@property (nonatomic, retain) NSString *poster;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSMutableArray *genArr;
@end

NS_ASSUME_NONNULL_END
