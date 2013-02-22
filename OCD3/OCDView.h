//
//  OCDView.h
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <UIKit/UIKit.h>

#import "OCDSelection.h"
#import "OCDNode.h"

@interface OCDView : UIView

- (OCDSelection *)selectAllWithIdentifier:(NSString *)identifier;
- (void)append:(OCDNode *)node;

@end
