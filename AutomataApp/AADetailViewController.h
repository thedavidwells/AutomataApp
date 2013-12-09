//
//  AADetailViewController.h
//  AutomataApp
//
//  Created by Ortal on 9/28/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFAutomaton.h"

@interface AADetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
- (DFAutomaton *)automatonForCurrentDrawing;
@end
