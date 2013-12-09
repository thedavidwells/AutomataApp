//
//  AATestStringsViewController.m
//  AutomataApp
//
//  Created by Ortal on 12/7/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import "AATestStringsViewController.h"

typedef NS_ENUM(NSInteger, AAAcceptStatus) {
    AAAcceptStatusNone,
    AAAcceptStatusAccept,
    AAAcceptStatusReject
};

@interface TestString : NSObject
@property (nonatomic, copy) NSString *string;
@property (nonatomic, assign) AAAcceptStatus acceptStatus;
@end

@implementation TestString
@end

@interface AATestStringsViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *testStrings; // array of TestString
@end

@implementation AATestStringsViewController

#pragma mark - Model

- (void)addTestString:(NSString *)string {
    TestString *testString = [[TestString alloc] init];
    testString.string = string;
    testString.acceptStatus = AAAcceptStatusNone;
    [self.testStrings addObject:testString];
    
    // add to table view
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.testStrings.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeTestStringAtIndex:(NSInteger)index {
    [self.testStrings removeObjectAtIndex:index];
    
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UIViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testStrings = [NSMutableArray array];
    self.detailViewController = (AADetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

#pragma mark - UI Events

- (IBAction)refreshTapped:(id)sender {
    DFAutomaton *automaton = [self.detailViewController automatonForCurrentDrawing];
    if (!automaton) {
        for (TestString *testString in self.testStrings) {
            testString.acceptStatus = AAAcceptStatusNone;
        }
        return;
    }
    
    for (TestString *testString in self.testStrings) {
        testString.acceptStatus = [automaton acceptsString:testString.string] ? AAAcceptStatusAccept : AAAcceptStatusReject;
    }
    [self.tableView reloadData];
}

- (IBAction)addTapped:(id)sender {
    UIAlertView *addTestStringView = [[UIAlertView alloc] initWithTitle:@"Test String"
                                                                message:@"Enter in a new test string."
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
    addTestStringView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addTestStringView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        // cancel tapped, do nothing
        return;
    }
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    [self addTestString:textField.text];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    TestString *testString = self.testStrings[indexPath.row];
    cell.textLabel.text = testString.string;
    UIColor *color;
    switch (testString.acceptStatus) {
        case AAAcceptStatusNone:
            color = [UIColor blackColor];
            break;
        case AAAcceptStatusAccept:
            color = [UIColor greenColor];
            break;
        case AAAcceptStatusReject:
            color = [UIColor redColor];
            break;
    }
    cell.textLabel.textColor = color;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeTestStringAtIndex:indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
