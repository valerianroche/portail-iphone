//
//  FirstViewController.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "FirstViewController.h"
#import "IdentificationViewController.h"
#import "Reseau.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Messages", @"Messages");
        self.tabBarItem.image = [UIImage imageNamed:@"first.png"];
        reseauTest = reseau;
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    _barre.topItem.title = @"Messages";
    _liste.delegate = self;
    _liste.dataSource = self;
    premiere = ![reseauTest dejaConnecte]; 
    if (!premiere) {
        [reseauTest connectionDispo];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"connectionDispo" object:nil];
    }
    if (!messages) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"mTelecharge" object:nil];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (premiere) {
        control = [[IdentificationViewController alloc] initWithNibName:@"IdentificationViewController" bundle:nil];
        
        [self presentViewController:control animated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"Pas de reseau" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"NoCookie" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"Cookie" object:nil];
        
        [self dispo];
        
        premiere = NO;
        [control setDelegue:self];
    }
}

-(void)majTable:(NSNotification *)notif {
    messages = [reseauTest getMessage];
    if (messages) {
        [_liste reloadData];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mTelecharge" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionDispo" object:nil];
    }
}

// ##################### Gère la connexion #########################

-(void)dispo {
    [[control activite] startAnimating];
    [reseauTest connectionDispo];
    [reseauTest getToken];
}

-(BOOL)reponse:(NSNotification *)notif {
    if ([[notif name] isEqualToString:@"Cookie"]) {
        if (timer) {
            [timer invalidate];
        }
        [control connecte];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Cookie" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NoCookie" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pas de reseau" object:nil];
    }
    else {
        [[control activite] stopAnimating];
        if ([[notif name] isEqualToString:@"Pas de reseau"]) {
            [control blocageReseau:@"Pas de réseau"];
        }
        if ([[notif name] isEqualToString:@"NoCookie"]) {
            [control blocageReseau:@"Le site ne répond pas"];
        }
        
        timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(dispo) userInfo:nil repeats:NO];
    }
    return YES;
}

-(void)identification:(NSString *)username andPassword:(NSString *)password {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(supprimerVue) name:@"Ok" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(echec) name:@"Non" object:nil];
    
    [reseauTest identification:username andPassword:password];
}

-(void)echec {
    [[control activite] stopAnimating];
    [control message:@"Identifiant/Mdp incorrect" etFixe:NO];
}

// ##################### Fin de la connexion #######################

-(void)supprimerVue {
    NSLog(@"Notification");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Ok" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Non" object:nil];
    [[control activite] stopAnimating];
    [self dismissViewControllerAnimated:YES completion:nil];
    [reseauTest getMessage];
    [reseauTest getTrombi];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

// ##################### Gère la déconnexion #######################

-(void)deconnexion:(id)sender {
    [reseauTest deconnexion];
    premiere = YES;
    [self viewDidAppear:YES];
}

// ##################### Délégué de la liste #######################

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!messages) {
        return 0;
    }
    else {
        return 0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!messages) {
        return 0;
    }
    else {
        return 1;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"a";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
