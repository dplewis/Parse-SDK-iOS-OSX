/*
 *  Copyright (c) 2014, Parse, LLC. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Parse.
 *
 *  As with any software that integrates with the Parse platform, your use of
 *  this software is subject to the Parse Terms of Service
 *  [https://www.parse.com/about/terms]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import "DeletionCollectionViewController.h"

#if __has_include(<Bolts/BFTask.h>)
#import <Bolts/BFTask.h>
#else
#import "BFTask.h"
#endif

@import ParseCore;

@interface DeletionCollectionViewController() <UIAlertViewDelegate>

@end

@implementation DeletionCollectionViewController

#pragma mark -
#pragma mark Init

- (instancetype)initWithClassName:(NSString *)className {
    self = [super initWithClassName:className];
    if (self) {
        self.title = @"Deletion Collection";
        self.pullToRefreshEnabled = YES;
        self.objectsPerPage = 10;
        self.paginationEnabled = YES;
    }
    return self;
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;

    layout.sectionInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    layout.minimumInteritemSpacing = 5.0f;

    self.collectionView.allowsMultipleSelection = YES;
    self.navigationItem.rightBarButtonItems = @[
        self.editButtonItem,
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addTodo:)]
    ];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;

    const CGRect bounds = UIEdgeInsetsInsetRect(self.view.bounds, layout.sectionInset);
    CGFloat sideSize = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) / 2.0f - layout.minimumInteritemSpacing;
    layout.itemSize = CGSizeMake(sideSize, sideSize);
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    if (editing) {
        self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                          target:self
                                                          action:@selector(deleteSelectedItems:)];
    } else {
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    }
}

- (void)addTodo:(id)sender {
    if ([UIAlertController class]) {
        UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"Add Todo"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

        __block UITextField *titleTextField = nil;
        [alertDialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            titleTextField = textField;

            titleTextField.placeholder = @"Name";
        }];

        [alertDialog addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alertDialog addAction:
         [UIAlertAction actionWithTitle:@"Save"
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    PFObject *object = [PFObject objectWithClassName:self.parseClassName
                                                                          dictionary:@{ @"title":titleTextField.text }];

                                    [[object saveInBackground] continueWithSuccessBlock:^id(BFTask *task) {
                                        return [self loadObjects];
                                    }];
                                }]];

        [self presentViewController:alertDialog animated:YES completion:nil];
    } else {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Add Todo"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Save", nil];

        [view setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [view textFieldAtIndex:0].placeholder = @"Name";

        [view show];
    }
}

- (void)deleteSelectedItems:(id)sender {
    [self removeObjectsAtIndexPaths:self.collectionView.indexPathsForSelectedItems];
}

#pragma mark - UICollectionViewDataSource

- (PFCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
                                  object:(PFObject *)object {
    PFCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath object:object];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = object[@"title"];

    cell.contentView.layer.borderWidth = 1.0f;
    cell.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;

    return cell;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) return;

    PFObject *object = [PFObject objectWithClassName:self.parseClassName
                                          dictionary:@{ @"title": [alertView textFieldAtIndex:0].text }];

    [[object saveEventually] continueWithSuccessBlock:^id(BFTask *task) {
        return [self loadObjects];
    }];
}

@end
