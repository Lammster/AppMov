//
//  menuTabVC.h
//  AppMov


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface menuTabVC : UIViewController<UITabBarDelegate>
@property (retain, nonatomic) IBOutlet UITableView *listDataTV;
@property (retain, nonatomic) IBOutlet UICollectionView *movieCV;
@property (retain, nonatomic) IBOutlet UIView *overlayView;
@property (retain, nonatomic) IBOutlet UIView *ContentNotView;
@property (retain, nonatomic) IBOutlet UITabBar *tabBar;

- (IBAction)filmBtn:(id)sender;
- (IBAction)noteBtn:(id)sender;



- (IBAction)addNoteClicked:(id)sender;


@end

NS_ASSUME_NONNULL_END
