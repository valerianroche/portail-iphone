//
//  Réseau.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "Reseau.h"
#import "FirstViewController.h"
#import "FluxTelechargement.h"

@implementation Reseau

-(id)init {
    
    if (self) {
        _nomDomaine = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Nom Domaine"];
    }
    
    return self;
}

-(void)connectionDispo {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    /*NSData *data = [NSURLConnection sendSynchronousRequest:getRequete returningResponse:nil error:nil];
    return (data != nil ) ? YES : NO;*/
    testReseau = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(BOOL)dejaConnecte {
    NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    if ([(NSNumber *)[[NSDictionary dictionaryWithContentsOfFile:fichierDonnees] objectForKey:@"dejaConnecte"] boolValue]) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)getToken {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_nomDomaine] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:4];
    [getRequete setHTTPMethod:@"GET"];
    recupToken = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(BOOL)identification:(NSString *)username andPassword:(NSString *)password {
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    if ([existants count] == 0) {
        return NO;
    }
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/accounts/login/"]]];
    [getRequete setHTTPMethod:@"POST"];
    NSMutableString *chaine = [[NSMutableString alloc] init];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:0] value]];
    [chaine appendString:@"&username="];
    [chaine appendString:username];
    [chaine appendString:@"&password="];
    [chaine appendString:password];
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    ident = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
    
    //[self performSelectorInBackground:@selector(connection:) withObject:getRequete];
    return YES;
}

-(BOOL)deconnexion {
    
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    if ([existants count] == 2) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:1]];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:0]];
    }
    if ([existants count] == 1) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:0]];
    }
    connecte = NO;

    NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithContentsOfFile:fichierDonnees];
    [temp setObject:[NSNumber numberWithBool:NO] forKey:@"dejaConnecte"];
    [temp writeToFile:fichierDonnees atomically:NO];
    
    return YES;
}

//################## Trombi ##################//
// Renvoie le trombi (ou nil s'il n'existe pas. Il faut donc penser à faire le teste. En cas d'attente (première connexion), il faut attendre la notification @"trombi" avant de charger à nouveau.
-(NSArray *)getTrombi {
    if (!trombi) {
        NSString *fichierTrombi = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi.data"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fichierTrombi]) {
            trombi = [[NSArray alloc] initWithContentsOfFile:fichierTrombi];
        }
        if (!change && reseau) {
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/people/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
            recupTrombi = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
            change = YES;
        }
    }
    return trombi;
}

-(NSArray *)getMessage {
    if (!message) {
        if (reseau) {
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/messages/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
            recupMessage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
        }
        else {
            NSString *fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/message.data"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fichierMessage]) {
                message = [[NSArray alloc] initWithContentsOfFile:fichierMessage];
            }
        }
    }
    return message;
}

-(UIImage *)getImage:(NSString *)identifiant etTelechargement:(BOOL)telechargement {
    if (!telechargement) {
        NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",identifiant]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fichierImage]) {
            if (reseau) {
                [self getImage:identifiant etTelechargement:YES];
            }
            return nil;
        }
        else {
            UIImage *image = [UIImage imageWithContentsOfFile:fichierImage];
            return image;
        }
    }
    else {
        if (!reseau) {
            [self getImage:identifiant etTelechargement:NO];
            return nil;
        }
        else {
            FluxTelechargement *objet = [[FluxTelechargement alloc] initWithDomaine:_nomDomaine etUsername:identifiant withParent:self etPhoto:YES];
            [telechargements addObject:objet];
            return nil;
        }
    }
}

-(NSDictionary *)getInfos:(NSString *)identifiant etTelechargement:(BOOL)telechargement {
    if (!telechargement) {
        NSString *fichierDico = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/trombi/%@.dat",identifiant]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fichierDico]) {
            if (reseau) {
                [self getInfos:identifiant etTelechargement:YES];
            }
            return nil;
        }
        else {
            NSDictionary *dico = [NSDictionary dictionaryWithContentsOfFile:fichierDico];
            return dico;
        }
    }
    else {
        if (!reseau) {
            [self getInfos:identifiant etTelechargement:NO];
            return nil;
        }
        else {
            FluxTelechargement *objet = [[FluxTelechargement alloc] initWithDomaine:_nomDomaine etUsername:identifiant withParent:self etPhoto:NO];
            [telechargements addObject:objet];
            return nil;
        }
    }

}

-(void)renvoieImage:(UIImage *)image forUsername:(NSString *)personne {
    if ([telechargements count]) {
        [[telechargements objectAtIndex:0] startDownload];
        [telechargements removeObjectAtIndex:0];
    }
    NSLog(@"a");
    if (image) {
        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
        NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",personne]];
        if ([data writeToFile:fichierImage atomically:NO]) {
            [images setObject:image forKey:personne];
        }
    }
    
}

-(void)renvoieInfos:(NSDictionary *)dico forUsername:(NSString *)personne {
    if ([telechargements count]) {
        [[telechargements objectAtIndex:0] startDownload];
        [telechargements removeObjectAtIndex:0];
    }
    NSLog(@"b");
    if (dico) {
        NSString *fichierDico = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/trombi/%@.plist",personne]];
        if ([dico writeToFile:fichierDico atomically:NO]) {
            
        }
    }
}

-(void)recupTout {
    NSString *dosImages = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/photos/"];
    NSString *donnees = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi/"];
    images = [NSMutableDictionary dictionaryWithCapacity:[trombi count]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dosImages]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dosImages withIntermediateDirectories:YES attributes:nil error: NULL];
    }
    else {
        
        NSString *fichierPhoto;
        for (NSDictionary *dico in trombi) {
            fichierPhoto = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",[dico objectForKey:@"username"]]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fichierPhoto]) {
                [images setObject:[UIImage imageWithContentsOfFile:fichierPhoto] forKey:[dico objectForKey:@"username"]];
            }
        }
        
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:donnees]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:donnees withIntermediateDirectories:YES attributes:nil error: NULL];
    }
    
    telechargements = [NSMutableArray arrayWithCapacity:2*[trombi count]];
    
    for (NSDictionary *dico in trombi) {
        [self getImage:[dico objectForKey:@"username"] etTelechargement:YES];
        [self getInfos:[dico objectForKey:@"username"] etTelechargement:YES];
    }
    
    for (int i=0;i<40;i++) {
        if ([telechargements count]) {
            [[telechargements objectAtIndex:0] startDownload];
            [telechargements removeObjectAtIndex:0];
        }
    }
}

//################## Délégué #################//

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == testReseau) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pas de reseau" object:nil];
        reseau = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDispo" object:nil];
        NSLog(@"Erreur réseau");
    }
    else if (connection == recupToken) {
        if (reseau) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoCookie" object:nil];
            NSLog(@"Echec site");
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == testReseau) {
        reseau = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDispo" object:nil];
        [connection cancel];
    }
    if (connection == recupTrombi || connection == recupMessage) {
        [donneesRecues appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == recupToken) {
        NSDictionary *cookies = [(NSHTTPURLResponse *)response allHeaderFields];
    
        if ([[NSHTTPCookie cookiesWithResponseHeaderFields:cookies forURL:[NSURL URLWithString:_nomDomaine]] count] != 0) {
            NSHTTPCookie *cookie = [[NSHTTPCookie cookiesWithResponseHeaderFields:cookies forURL:[NSURL URLWithString:_nomDomaine]] objectAtIndex:0];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Cookie" object:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoCookie" object:nil];
        }
    }
    if (connection == ident) {
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Non" object:nil]];
            NSLog(@"Echec identification");
        }
    }
    
    if (connection == recupTrombi || connection == recupMessage) {
        donneesRecues = [[NSMutableData alloc] initWithLength:0];
    }
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (connection == ident) {
        if ([(NSHTTPURLResponse *)response statusCode] == 302) {
            NSLog(@"Succès");
            [connection cancel];
            connecte = YES;
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Ok" object:nil]];
            
            NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
            NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithContentsOfFile:fichierDonnees];
            [temp setObject:[NSNumber numberWithBool:YES] forKey:@"dejaConnecte"];
            [temp writeToFile:fichierDonnees atomically:NO];
            
            return nil;
        }
        else if ([(NSHTTPURLResponse *)response statusCode] == 0) {
            return request;
        }
        else {
            NSLog(@"Echec");
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Non" object:nil]];
            return request;
        }
    }
    return request;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == recupTrombi) {
        NSMutableArray *trombiTemp = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingMutableContainers error:NULL];
        NSLog(@"Trombi téléchargé");
        [trombiTemp sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES], nil]];
        NSString *fichierTrombi = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi.data"];
        trombi = [trombiTemp copy];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tTelecharge" object:nil];
        
        [self recupTout];
        
        [trombi writeToFile:fichierTrombi atomically:NO];
    }
    
    else if (connection == recupMessage) {
        NSError *error;
        message = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Erreur lors du parsage");
        }
        if (message) {
            NSString *fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/message.data"];
            [message writeToFile:fichierMessage atomically:NO];
            NSLog(@"Messages téléchargés");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mTelecharge" object:nil];
        }
    }
}
@end
