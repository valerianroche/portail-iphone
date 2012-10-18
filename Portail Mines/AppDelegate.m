//
//  AppDelegate.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AppDelegate.h"

#import "FirstViewController.h"

#import "Trombi.h"

#import "Reseau.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    Reseau *reseau = [[Reseau alloc] init];
    // Override point for customization after application launch.
    UIViewController *viewController1 = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil andNetwork:reseau];
    UIViewController *viewController2 = [[Trombi alloc] initWithNibName:@"Trombi" bundle:nil andNetwork:reseau];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UIViewController *viewController3 = [[Trombi alloc] initWithNibName:@"Trombi" bundle:nil];
    UIViewController *viewController4 = [[Trombi alloc] initWithNibName:@"Trombi" bundle:nil];
    
    
    // On cherche le fichier de pref. Si on ne l'a pas, on le crée
    NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fichierDonnees]) {
        NSDictionary *parametres = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"dejaConnecte", nil]];
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *chemin = [path objectAtIndex:0];
        NSString *writablePath = [chemin stringByAppendingString:@"/parametres.plist"];
        [parametres writeToFile:writablePath atomically:YES];
    }
    
    // On cherche le fichier contenant les prefs
    // S'il n'existe pas, on le crée
    NSArray *dico; //Pour l'ordre des onglets
    NSString *fichierPref = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/infoApp.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fichierPref]) {
        dico = [NSArray arrayWithObjects:@"Messages",@"Trombi",@"Petits Cours",@"Médias", nil];
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *chemin = [path objectAtIndex:0];
        NSString *writablePath = [chemin stringByAppendingString:@"/infoApp.plist"];
        [dico writeToFile:writablePath atomically:YES];
    }
    else {
        dico = [NSArray arrayWithContentsOfFile:fichierPref];
    }
    
    // On crée le tableau des onglets dans l'ordre
    NSDictionary *dicoOnglets = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:viewController1,controller,viewController3,viewController4, nil] forKeys:[NSArray arrayWithObjects:@"Messages",@"Trombi",@"Petits Cours",@"Médias",nil]];
    
    NSMutableArray *onglets = [[NSMutableArray alloc] initWithCapacity:[dicoOnglets count]];
    for (id s in dico) {
        [onglets addObject:[dicoOnglets objectForKey:s]];
    }
    
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = onglets;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
