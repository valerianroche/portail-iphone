//
//  IdentificationViewController.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"

@interface IdentificationViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) FirstViewController *delegue;
@property (nonatomic, strong) IBOutlet UITextField *username;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *boutton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
-(IBAction)dismiss:(id)sender;
-(void)message:(NSString *)chaine etFixe:(BOOL)repete;
-(void)blocageReseau:(NSString *)chaine;
-(void)connecte;

@end
