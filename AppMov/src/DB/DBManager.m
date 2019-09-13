//


#import "AppDelegate.h"
#import "DBManager.h"
#import "DBNote.h"
#import "DBMovie.h"
#import "DBGenre.h"

@implementation DBManager

@synthesize DBName;

- (id)init {
  if(self = [super init]) {
    self.DBName = @"appmov.db";
  // BOOL p = [self isDBExist];
  }
  return self;
}

- (void)dealloc {
  [DBName release];
  [super dealloc];
}

- (BOOL)isDBExist {
  AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  BOOL control = NO;
  NSFileManager *fmng = [NSFileManager defaultManager];
  NSArray *fileList = [fmng contentsOfDirectoryAtPath:delegate.homeDir error:nil];
  for(NSString *s in fileList) {
    if([s isEqualToString:DBName]) {
      control = YES;
    }
  }
  fmng = nil;
  fileList = nil;
  delegate = nil;

  return control;
}

- (NSString*)getDBPath {
  AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  NSString *dbPath;
  
  NSFileManager *fmng = [NSFileManager defaultManager];
  dbPath = [[[NSString alloc] initWithString:
             [delegate.homeDir stringByAppendingPathComponent:DBName]] autorelease];
  
  if([fmng fileExistsAtPath:dbPath] == NO) {
    [fmng copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DBName]
                  toPath:dbPath
                   error:NULL];
  }
  fmng = nil;
  delegate = nil;
  
  return dbPath;
}


//Consulta generica para todos los querys que no regresen renglones (INSERT, UPDATE, DELETE, etc.)
//Para no tener que programar todo el manejo de la base de datos en este tipo de querys
- (int)execQuery:(NSString *)query {
  sqlite3_stmt *statement;
  bool dbUnlocked = false;
  int lid = 0; //Id insertado (cuando se inserta en la base de datos)
  
  @try {
    NSString *dbPath = [self getDBPath];
    
    if((sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK)) {
      return -1;
    } else {
      sqlite3_busy_timeout(db, 500);
      const char *squery = [query cStringUsingEncoding:NSUTF8StringEncoding];
      
      _lockCount = 0;
      while (!dbUnlocked && (_lockCount < 10)) {
        if(sqlite3_prepare_v2(db, squery, -1, &statement, NULL) == SQLITE_OK) {
          if(sqlite3_step(statement) == SQLITE_DONE) {
          } else {
            NSLog(@">>>>Error(CRMDB): %@ (%s)",query,sqlite3_errmsg(db));
          }
          dbUnlocked = true;
          NSString *serr = [NSString stringWithFormat:@"%s",sqlite3_errmsg(db)];
          if([serr rangeOfString:@"database is locked"].location != NSNotFound) {
            dbUnlocked = false;
            sqlite3_finalize(statement);
          }
        } else {
          NSString *serr = [NSString stringWithFormat:@"%s",sqlite3_errmsg(db)];
          if([serr rangeOfString:@"database is locked"].location != NSNotFound) {
            dbUnlocked = false;
            sqlite3_finalize(statement);
          } else {
            dbUnlocked = true;
          }
        }
        _lockCount++;
      }
      if(lid <= 0) {
        lid = ((int)sqlite3_last_insert_rowid(db));
      }
      sqlite3_finalize(statement);
      sqlite3_close(db);
    }
    
    dbPath = nil;
  } @catch (NSException *e) {
    sqlite3_finalize(statement);
    sqlite3_close(db);
  }
  if(_lockCount >= 10) {
    NSLog(@">>>>Error (CRMDB): Base de datos bloqueada. %@",query);
  }
  return lid;
}

- (sqlite3_stmt*)openDBConnection:(NSString *)query {
  NSString *dbPath = [self getDBPath];
  sqlite3_stmt *statement = nil;
  bool dbUnlocked = false;
  bool opened = false;
  
  @try {
    int ptr = sqlite3_open([dbPath UTF8String], &db);
    dbPath = nil;
    
    if(ptr != SQLITE_OK) {
      NSLog(@">>>>>Error(CRMDB): No se pudo abrir la base de datos");
      return nil;
    }
    
    sqlite3_busy_timeout(db, 500);
    _lockCount = 0;
    while(!dbUnlocked && (_lockCount<10)) {
      if(sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        opened = true;
        dbUnlocked = true;
        break;
      } else {
        NSString *serr = [NSString stringWithFormat:@"%s",sqlite3_errmsg(db)];
        if([serr rangeOfString:@"database is locked"].location != NSNotFound) {
          dbUnlocked = false;
        } else {
          dbUnlocked = true;
        }
      }
      _lockCount++;
    }
    
    if(!opened) {
      sqlite3_finalize(statement);
      sqlite3_close(db);
    }
  } @catch (NSException *e) {
    sqlite3_finalize(statement);
    sqlite3_close(db);
  }
  if(_lockCount >= 10) {
    NSLog(@"Error (CRMDB): La base de datos está bloquedada. %@", query);
  }
  
  return statement;
}

- (void)closeDBConnection:(sqlite3_stmt*)statement {
  sqlite3_finalize(statement);
  sqlite3_close(db);
}

//inicia query

- (void)updateNote:(NSInteger)notId not:(NSString*)note{
  NSString *queryExp = [NSString stringWithFormat:@"UPDATE notes SET title='%@' WHERE notes_id = '%li'",
                        note,
                        notId
                        ];
  
  
  [self execQuery:queryExp];
}

- (void)addNote:(NSString *)note{
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  NSString *date = [NSString stringWithFormat:@"%@", [df stringFromDate:[NSDate date]]];
  NSString *queryExpdate = [NSString stringWithFormat:
                            @"INSERT OR REPLACE INTO notes (title, reg_date) VALUES ('%@', '%@')",
                            note,
                            date
                            ];
  NSLog(@"");
  [self execQuery:queryExpdate];
  
}

- (NSMutableArray*)SelectAllNote{
  NSMutableArray *notsArr = [[NSMutableArray alloc] init];
  sqlite3_stmt *sqlStatement;
  NSString *sqlAssistence =  [NSString stringWithFormat:@"SELECT * FROM notes"];
  sqlStatement = [self openDBConnection:sqlAssistence];
  
  if (sqlStatement == nil) {
    return nil;
  }
  while(sqlite3_step(sqlStatement) == SQLITE_ROW)
  {
    DBNote *not = [[DBNote alloc] init];
    
    not.noteId = sqlite3_column_int(sqlStatement, 0);
    not.title = [NSString stringWithUTF8String:(char*) sqlite3_column_text(sqlStatement, 1)];
    [notsArr addObject:not];
  }
  [self closeDBConnection:sqlStatement];
  return notsArr;
  
}

- (void)DeleteNote:(NSInteger*)Id{
  NSString *queryExpdate = [NSString stringWithFormat:
                            @"DELETE FROM notes WHERE notes_id = '%lu'", Id];
  NSLog(@"");
  [self execQuery:queryExpdate];
  
}
- (void)Delete{
  NSString *queryExpdate = [NSString stringWithFormat:
                            @"DELETE FROM films_genres"];
  NSLog(@"");
  [self execQuery:queryExpdate];
  
}


- (void)InsertFilms:(NSMutableDictionary*)data{
  int count = 0;
  int countGen = 0;
  [self Delete];
  NSMutableString *query = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO films (film_id, name_film, poster, release_date) VALUES"];
  
   NSMutableString *queryGen = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO films_genres (film_id, genre_id) VALUES"];
  
  
  for (NSMutableDictionary *dic in data) {
    if(count >= 300) {
      count = 0;
      query = (NSMutableString*)[query substringToIndex:[query length]-1];
      [self execQuery:query];
      query = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO films (film_id, name_film, poster, release_date) VALUES"];
    }
    if(countGen >= 300) {
      countGen = 0;
      queryGen = (NSMutableString*)[queryGen substringToIndex:[queryGen length]-1];
      [self execQuery:queryGen];
      queryGen = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO films_genres (film_id, genre_id) VALUES"];
    }
    
    [query appendString:[NSString stringWithFormat:@" ('%@', '%@', '%@', '%@'),",
                         [dic valueForKey:@"id"],
                         [dic valueForKey:@"original_title"],
                         [dic valueForKey:@"poster_path"],
                         [dic valueForKey:@"release_date"]]];
    for (NSMutableArray *arr in [dic valueForKey:@"genre_ids"]) {
      if(countGen >= 300) {
        countGen = 0;
        queryGen = (NSMutableString*)[queryGen substringToIndex:[queryGen length]-1];
        [self execQuery:queryGen];
        queryGen = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO films_genres (film_id, genre_id) VALUES"];
      }
      [queryGen appendString:[NSString stringWithFormat:@" ('%@', '%@'),",
                           [dic valueForKey:@"id"],
                           arr]];
      countGen++;
    }
    count++;
    
  }
  query = (NSMutableString*)[query substringToIndex:[query length]-1];
  [self execQuery:query];
  queryGen = (NSMutableString*)[queryGen substringToIndex:[queryGen length]-1];
  [self execQuery:queryGen];
  
}


- (void)InsertGenre:(NSMutableDictionary*)data{
  int countGen = 0;
  NSMutableString *queryGen = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO genres (genre_id, name) VALUES"];
  
  for (NSMutableDictionary *dic in data) {
    if(countGen >= 300) {
      countGen = 0;
      queryGen = (NSMutableString*)[queryGen substringToIndex:[queryGen length]-1];
      [self execQuery:queryGen];
      queryGen = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO genres (genre_id, name) VALUES"];
    }
      [queryGen appendString:[NSString stringWithFormat:@" ('%@', '%@'),",
                              [dic valueForKey:@"id"],
                              [dic valueForKey:@"name"]]];
      countGen++;
    
  }
 
  queryGen = (NSMutableString*)[queryGen substringToIndex:[queryGen length]-1];
  [self execQuery:queryGen];
}

- (NSMutableArray*)SelectAllMov{
  NSMutableArray *notsArr = [[NSMutableArray alloc] init];
  sqlite3_stmt *sqlStatement;
  NSString *sqlAssistence =  [NSString stringWithFormat:@"SELECT * FROM films"];
  sqlStatement = [self openDBConnection:sqlAssistence];
  
  if (sqlStatement == nil) {
    return nil;
  }
  while(sqlite3_step(sqlStatement) == SQLITE_ROW)
  {
    DBMovie *mov = [[DBMovie alloc] init];
    
    mov.filmId = sqlite3_column_int(sqlStatement, 0);
    mov.nameFilm = [NSString stringWithUTF8String:(char*) sqlite3_column_text(sqlStatement, 1)];
    mov.poster = [NSString stringWithUTF8String:(char*) sqlite3_column_text(sqlStatement, 2)];
    mov.date = [NSString stringWithUTF8String:(char*) sqlite3_column_text(sqlStatement, 3)];
    [notsArr addObject:mov];
  }
  [self closeDBConnection:sqlStatement];
  return notsArr;
  
}

- (NSMutableArray*)getAllMov {
  NSMutableArray *plist = [[NSMutableArray alloc] init];
  plist = [self SelectAllMov];
  for(DBMovie *prod in plist) {
    prod.genArr = [self SelectAllGenId:prod.filmId];
  }
  return plist;
}


- (NSMutableArray*)SelectAllGenId:(NSInteger)idMov{
  NSMutableArray *notsArr = [[NSMutableArray alloc] init];
  sqlite3_stmt *sqlStatement;
  NSString *sqlAssistence =
    [NSString stringWithFormat:
     @"SELECT  g.* FROM films_genres fg INNER JOIN genres g ON (g.genre_id = fg.genre_id) WHERE  film_id = '%li'", idMov];
  sqlStatement = [self openDBConnection:sqlAssistence];
  
  if (sqlStatement == nil) {
    return nil;
  }
  while(sqlite3_step(sqlStatement) == SQLITE_ROW)
  {
    DBGenre *gen = [[DBGenre alloc] init];
    
    gen.genreId = sqlite3_column_int(sqlStatement, 0);
    gen.name = [NSString stringWithUTF8String:(char*) sqlite3_column_text(sqlStatement, 1)];
    [notsArr addObject:gen];
  }
  [self closeDBConnection:sqlStatement];
  return notsArr;
  
}

- (NSMutableArray*)SelectAllfilmgGenId{
  NSMutableArray *notsArr = [[NSMutableArray alloc] init];
  sqlite3_stmt *sqlStatement;
  NSString *sqlAssistence =
  [NSString stringWithFormat:
   @"SELECT * FROM films_genres"];
  sqlStatement = [self openDBConnection:sqlAssistence];
  
  if (sqlStatement == nil) {
    return nil;
  }
  while(sqlite3_step(sqlStatement) == SQLITE_ROW)
  {
    DBGenre *gen = [[DBGenre alloc] init];
    
    gen.genreId = sqlite3_column_int(sqlStatement, 0);
    gen.name = [NSString stringWithUTF8String:(char*) sqlite3_column_text(sqlStatement, 1)];
    [notsArr addObject:gen];
  }
  [self closeDBConnection:sqlStatement];
  return notsArr;
  
}


@end












