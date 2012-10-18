//
//  FirstViewController.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IdentificationViewController;
@class Reseau;

@interface FirstViewController : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    @private
        BOOL premiere;
        IdentificationViewController *control;
        Reseau *reseauTest;
        NSTimer *timer;
        NSArray *messages;
}

@property (nonatomic, strong) IBOutlet UINavigationBar *barre;
@property (nonatomic, strong) IBOutlet UITableView *liste;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
-(void)supprimerVue;
-(void)identification:(NSString *)username andPassword:(NSString *)password;
-(IBAction)deconnexion:(id)sender;

@end
