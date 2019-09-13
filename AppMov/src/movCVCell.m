//
//  movCVCell.m
//  AppMov

#import "movCVCell.h"

@implementation movCVCell



- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  
  if (self) {
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"movCVCell"
                                                          owner:self
                                                        options:nil];
    
    if ([arrayOfViews count] < 1) {
      return nil;
    }
    if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
      return nil;
    }
    self = [arrayOfViews objectAtIndex:0];
    
  }
  
  return self;
  
}

- (void)dealloc {
  [_posterImg release];
  [_nameLbl release];
  [_genLbl release];
  [super dealloc];
}
@end
