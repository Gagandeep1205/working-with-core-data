//
//  CommunityVC.m
//  coreData
//
//  Created by Gagandeep Kaur  on 07/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import "CommunityVC.h"
#import "AppDelegate.h"

@interface CommunityVC ()

@end

@implementation CommunityVC

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:142/255.f green:68/255.f blue:173/255.f alpha:1.f]];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:142/255.f green:68/255.f blue:173/255.f alpha:1.f];

    UIBarButtonItem *addDetails = [[UIBarButtonItem alloc] initWithTitle:@"Add Details" style:UIBarButtonItemStylePlain target:self action:@selector(actionBtnAddDetails:)];
    [addDetails setTintColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItem = addDetails;
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewWillAppear:(BOOL)animated{

    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:142/255.f green:68/255.f blue:173/255.f alpha:1.f]];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Detail" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"Detail: %@", [info valueForKey:@"detail"]);
     
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - button actions

- (void) actionBtnAddDetails : (UIBarButtonItem *)btn{

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Add a detail"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    
    UIAlertAction * done = [UIAlertAction
                               actionWithTitle:@"Done"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
                                   NSManagedObjectContext *context = [self managedObjectContext];
                                   NSString *text = [alert.textFields objectAtIndex:0].text;
                                   NSManagedObject *newDetail = [NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:context];
                                   [newDetail setValue:text forKey:@"detail"];
                                   
                                   NSError *error = nil;
                                   if (![context save:&error]) {
                                       NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                                   }
                                   else{
                                   
                                       NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                                       NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Detail"];
                                       self.details = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                                       
                                       [self.tableView reloadData];

                                   }
                                   [self dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
    }];
    [alert addAction:cancel];
    [alert addAction:done];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - core data functions

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Detail"];
    self.details = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}


#pragma mark - tableView delegates and data sources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _details.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSManagedObject *detail = [self.details objectAtIndex:indexPath.row];
    [cell.textLabel setText:[detail valueForKey:@"detail"]];
    return cell;
}


@end
