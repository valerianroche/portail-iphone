//
//  FluxTelechargement.h
//  Portail Mines
//
//  Created by Valérian Roche on 15/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Reseau;

@interface FluxTelechargement : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSURLConnection *connection;
    NSMutableData* data;
    UIImage *image;
    Reseau *reseau;
    BOOL type;
    NSString *nomDomaine;
    NSString *personne;
    
    NSMutableURLRequest *getRequete;
}

-(void)startDownload;
-(id)initWithDomaine:(NSString *)domaine etUsername:(NSString *)username withParent:(Reseau *)parent etPhoto:(BOOL)photoOuDoc;

@end
