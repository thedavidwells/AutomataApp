//
//  AAAppDelegate.h
//  AutomataApp
//
//  Created by Ortal on 9/28/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
