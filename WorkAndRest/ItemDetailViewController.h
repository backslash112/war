//
//  NewTaskViewController.h
//  WorkAndRest
//
//  Created by YangCun on 14-3-24.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskItem.h"

@class ItemDetailViewController;
@class TaskItem;

@protocol ItemDetailViewControllerDelegate <NSObject>

- (void)addTaskViewControllerDidCancel:(ItemDetailViewController *)controller;
- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishAddingTask:(TaskItem *)item;
- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishEditingTask:(TaskItem *)item;

@end

@interface ItemDetailViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <ItemDetailViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) TaskItem *itemToEdit;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
