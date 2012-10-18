//
//  Réseau.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FluxTelechargement;

@interface Reseau : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    @private
    NSURLConnection *ident;
    NSURLConnection *testReseau;
    NSURLConnection *recupToken;
    NSURLConnection *recupTrombi;
    NSURLConnection *recupMessage;
    NSURLConnection *recupPhoto;
    BOOL reseau;
    BOOL connecte;
    BOOL change;
    NSMutableData *donneesRecues;
    NSArray *trombi;
    NSArray *message;
    NSString *identPhoto;
    NSString *identInfo;
    NSMutableDictionary *images;
    
    NSMutableArray *telechargements;
}

@property (nonatomic,strong) NSString *nomDomaine;
-(id)init;
-(void)connectionDispo;
-(BOOL)dejaConnecte;
-(void)getToken;
-(BOOL)identification:(NSString *)username andPassword:(NSString *)password;
-(BOOL)deconnexion;

-(NSArray *)getTrombi;
-(NSArray *)getMessage;
-(UIImage *)getImage:(NSString *)identifiant etTelechargement:(BOOL)telechargement;
-(NSDictionary *)getInfos:(NSString *)identifiant etTelechargement:(BOOL)telechargement;

-(void)renvoieImage:(UIImage *)image forUsername:(NSString *)personne;
-(void)renvoieInfos:(NSDictionary *)dico forUsername:(NSString *)personne;

@end
