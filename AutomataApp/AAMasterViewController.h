//
//  AAMasterViewController.h
//  AutomataApp
//
//  Created by Ortal on 9/28/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AADetailViewController;

#import <CoreData/CoreData.h>

@interface AAMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) AADetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
