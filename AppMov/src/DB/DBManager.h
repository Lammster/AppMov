//
//  Igs

#import <Foundation/Foundation.h>
#import <sqlite3.h>


NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject {
  sqlite3 *db;
  //Contador para solo hacer 10 intentos máximo al realizar una operación en la
  //base de datos y no se quede trabada el app
  int _lockCount;
}

@property (nonatomic, strong) NSString *DBName;

- (BOOL)isDBExist;
- (NSString*)getDBPath;

- (int)execQuery:(NSString*)query;

//inicio de querys
- (void)addNote:(NSString*)note;
- (void)updateNote:(NSInteger)notId not:(NSString*)note;
- (NSMutableArray*)SelectAllNote;
- (void)DeleteNote:(NSInteger*)Id;
- (void)InsertFilms:(NSMutableDictionary*)data;
- (void)InsertGenre:(NSMutableDictionary*)data;
- (NSMutableArray*)getAllMov;
- (NSMutableArray*)SelectAllGenId:(NSInteger)idMov;
- (NSMutableArray*)SelectAllMov;
@end

NS_ASSUME_NONNULL_END
