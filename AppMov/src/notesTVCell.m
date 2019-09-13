//
//  notesTVCell.m
//  AppMov


#import "notesTVCell.h"

@implementation notesTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
  [_titleLbl release];
  [super dealloc];
}
@end
