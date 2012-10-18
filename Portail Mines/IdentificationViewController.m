//
//  IdentificationViewController.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "IdentificationViewController.h"

@interface IdentificationViewController ()

@end

@implementation IdentificationViewController

@synthesize delegue=_delegue, password=_password, username=_username, label=_label, boutton=_boutton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _password.secureTextEntry = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self blocageReseau:@"Chargement"];
    // Do any additional setup after loading the view from its nib.
}

-(void)blocageReseau:(NSString *)chaine {
    [_password setEnabled:NO];
    [_username setEnabled:NO];
    [_label setText:chaine];
    [_boutton setEnabled:NO];
}

-(void)message:(NSString *)chaine etFixe:(BOOL)repete {
    [_label setText:chaine];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(effaceMessage) userInfo:nil repeats:repete];
}

-(void)effaceMessage {
    [_label setText:@""];
}

-(void)connecte {
    [_activite stopAnimating];
    [_password setEnabled:YES];
    [_username setEnabled:YES];
    [_label setText:@""];
    [_boutton setEnabled:YES];
    [_username becomeFirstResponder];
}

-(IBAction)dismiss:(id)sender {
    if ([_username isFirstResponder]) {
        [_username resignFirstResponder];
    }
    else {
        [_password resignFirstResponder];    
    }
    [_activite startAnimating];
    [_delegue identification:[_username text] andPassword:[_password text]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _password) {
        if (![_username.text isEqualToString:@""]) {
            [self dismiss:nil];
        }
    }
    else {
        if (![_password.text isEqualToString:@""]) {
            [self dismiss:nil];
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
