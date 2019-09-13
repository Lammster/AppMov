//
//  menuTabVC.m
//  AppMov


#import "menuTabVC.h"
#import "notesTVCell.h"
#import "DBManager.h"
#import "DBNote.h"
#import "AppDelegate.h"
#import "movCVCell.h"
#import "DBMovie.h"
#import "DBGenre.h"

@interface menuTabVC (){
  AppDelegate *adelegate;
}
@property (nonatomic, strong) NSMutableArray *notesArr;
@property (nonatomic, strong) NSMutableArray *movArr;

@end

@implementation menuTabVC
static NSString * const reuseId = @"movCVCell";
- (void)viewDidLoad {
    [super viewDidLoad];
  adelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.notesArr = [[NSMutableArray alloc] init];
  DBManager *dbMng = [[DBManager alloc] init];
  self.notesArr =  [dbMng SelectAllNote];
  self.movArr = [[NSMutableArray alloc] init];
  self.movArr = [dbMng getAllMov];
  [self.movieCV registerClass:[movCVCell class]
          forCellWithReuseIdentifier:reuseId];
  self.movieCV.alwaysBounceVertical = YES;
  
 
  [self.overlayView setHidden:NO];
   dispatch_async(dispatch_get_main_queue(), ^{
      [self.overlayView setHidden:NO];
   });
   
  dispatch_queue_t myCustomQueue;
  myCustomQueue = dispatch_queue_create("com.igs.movDownload", NULL);
  dispatch_async(myCustomQueue, ^{
    adelegate.movDown.delegate = self;
    [adelegate.movDown initDown];
  });
}

- (BOOL)prefersStatusBarHidden{
  return YES;
}

/******************************************************
 *********** inicia Table *****************************
 ******************************************************/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.notesArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath
{
  
  notesTVCell *cell = nil;
  static NSString *CellIdentifier = @"notesTVCell";
  
  cell = (notesTVCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if(!cell)
  {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"notesTVCell" owner:nil
                                                           options:nil];
    for(id currentObject in topLevelObjects)
    {
      if([currentObject isKindOfClass:[notesTVCell class]])
      {
        cell = (notesTVCell *)currentObject;
        break;
      }
    }
  }
  [cell.titleLbl setText:((DBNote*)[self.notesArr objectAtIndex:[indexPath row]]).title];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

  NSInteger index = [indexPath row];
  UIAlertController * alert=   [UIAlertController
                                alertControllerWithTitle:@"Nota"
                                message:@"Editar nota"
                                preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction* ok =
  [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                       NSArray * textfields = alert.textFields;
                       UITextField *namefield = textfields[0];
                      
                       if (![namefield.text isEqualToString:@""]) {
                         ((DBNote*)[self.notesArr objectAtIndex:index]).title = namefield.text;
                         DBManager *dbMng = [[DBManager alloc] init];
                         [dbMng updateNote:((DBNote*)[self.notesArr objectAtIndex:index]).noteId
                                       not:namefield.text];
                         [self.listDataTV reloadData];
                       }else{
                         [menuTabVC showSinglMessage:self Title:@"Aviso"
                                                  Message:@"no puede dejar el campo vacío"];
                       }
                           
   
                     }];
  UIAlertAction* cancel =
  [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                           [alert dismissViewControllerAnimated:YES completion:nil];
                           
                         }];
  
  [alert addAction:ok];
  [alert addAction:cancel];
  
  [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"nota...";
  }];
  
  [self presentViewController:alert animated:YES completion:nil];
  
  
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return YES if you want the specified item to be editable.
  return YES;
  
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) { //agrega codigo para eliminar
    DBManager *dbMng = [[DBManager alloc] init];
    [dbMng DeleteNote:((DBNote*)[self.notesArr objectAtIndex:indexPath.row]).noteId];
    [self.notesArr removeObjectAtIndex:indexPath.row];
    [self.listDataTV deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
  return @"Eliminar";
}

- (void)dealloc {
  [_listDataTV release];
  [_movieCV release];
  [_overlayView release];
  [_ContentNotView release];
  [_tabBar release];
  [super dealloc];
}
- (IBAction)filmBtn:(id)sender {
  [self.movieCV setHidden:NO];
  [self.ContentNotView setHidden:YES];
}

- (IBAction)noteBtn:(id)sender {
  [self.movieCV setHidden:YES];
  [self.ContentNotView setHidden:NO];
}

- (IBAction)addNoteClicked:(id)sender {
  
  UIAlertController * alert=   [UIAlertController
                                alertControllerWithTitle:@"Nota"
                                message:@"Agregar nota"
                                preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                NSArray * textfields = alert.textFields;
                                UITextField *namefield = textfields[0];
                                if (![namefield.text isEqualToString:@""]) {
                                   [self.notesArr removeAllObjects];
                                   DBManager *dbMng = [[DBManager alloc] init];
                                   [dbMng addNote:namefield.text];
                                   self.notesArr =  [dbMng SelectAllNote];
                                   [self.listDataTV reloadData];
                                }else{
                                  [menuTabVC showSinglMessage:self Title:@"Aviso"
                                                      Message:@"no puede dejar el campo vacío"];
                                }
                                 }];
  UIAlertAction* cancel =
  [UIAlertAction actionWithTitle:@"Cancel"
                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                           }];
  
  [alert addAction:ok];
  [alert addAction:cancel];
  
  [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"nota...";
  }];
  
  [self presentViewController:alert animated:YES completion:nil];
  
}

+ (void)showSinglMessage:(UIViewController *)vc Title:(NSString *)title Message:(NSString *)msg {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *dlg = [UIAlertController
                              alertControllerWithTitle:title
                              message:msg
                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *acceptBtn = [UIAlertAction
                                actionWithTitle:@"Aceptar"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction* ac) {
                                }];
    [dlg addAction:acceptBtn];
    [vc presentViewController:dlg animated:NO completion:nil];
  });
}

- (void)movieDownDelegateComplete:(NSString*)MsgCor{
  NSLog(@"al parecer termino");
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.overlayView setHidden:NO];
  });
  dispatch_queue_t myCustomQueue;
  myCustomQueue = dispatch_queue_create("com.igs.genCDownload", NULL);
  dispatch_async(myCustomQueue, ^{
    adelegate.genDown.delegate = self;
    [adelegate.genDown initDown];
  });
}

- (void)movieDownDelegateEndsWithError:(NSString*)errMsg{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.overlayView setHidden:YES];
  });
  [menuTabVC showSinglMessage:self Title:@"Aviso"
                      Message:@"error al descargar datos"];
}

- (void)genreDownComplete:(NSString*)MsgCor{
  dispatch_async(dispatch_get_main_queue(), ^{
    DBManager *dbMng = [[DBManager alloc] init];
    self.movArr = [[NSMutableArray alloc] init];
    self.movArr = [dbMng getAllMov];
    [self.movieCV reloadData];
    [self.overlayView setHidden:YES];
  });
}

- (void)genreDownEndsWithError:(NSString*)errMsg{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.overlayView setHidden:YES];
  });
  [menuTabVC showSinglMessage:self Title:@"Aviso"
                      Message:@"error al descargar datos"];
}

/* ****************************************************
 * *** Inicia CollectionView
 * **************************************************** */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [self.movArr count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  movCVCell *cell  = (movCVCell*)[self.movieCV
                                  dequeueReusableCellWithReuseIdentifier:reuseId
                                  forIndexPath:indexPath];
  if(!cell) {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:reuseId owner:nil options:nil];
    for(id currentObject in topLevelObjects)
    {
      if([currentObject isKindOfClass:[movCVCell class]])
      {
        cell = (movCVCell *)currentObject;
        break;
      }
    }
  }
  int ind = (int)[indexPath row];
  DBMovie *mov = [[DBMovie alloc] init];
  mov = [self.movArr objectAtIndex:[indexPath row]];
  NSMutableString *genName = [NSMutableString stringWithFormat:@""];;
  [cell.nameLbl setText:mov.nameFilm];
  if ([mov.genArr count] != 0) {
    for (DBGenre *gen in mov.genArr) {
      [genName appendString:[NSString stringWithFormat:@"%@, ", gen.name]];
    }
  }else{
    [genName appendString:[NSString stringWithFormat:@"there is no gender  "]];
  }
  genName = (NSMutableString*)[genName substringToIndex:[genName length]-2];
  [cell.genLbl setText:genName];
  if ([mov.poster hasPrefix:@"/"]) {
    [self downloadImage:(int)[indexPath row]inImageView:cell.posterImg];
  }
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGRect vrect = self.movieCV.frame;
  float cellWidth = (vrect.size.width) / 4.0;
  return CGSizeMake(cellWidth+16.5, cellWidth*2.70);
 
}
/* ****************************************************
 * *** Termina CollectionView
 * **************************************************** */
- (IBAction)downloadImage:(int)pos inImageView:(UIImageView*)imgView {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   DBMovie *mov = [[DBMovie alloc] init];
                   mov = [self.movArr objectAtIndex:pos];
                   NSString *url =[NSString stringWithFormat:@"%@%@",adelegate.urlImg, mov.poster];
                   NSURL *imgURL = [NSURL URLWithString:url];
                   NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
                   dispatch_sync(dispatch_get_main_queue(), ^{
                     //Carga la imagen en su celda
                       imgView.image = [UIImage imageWithData:imgData];
                   });
                 });
}

@end



