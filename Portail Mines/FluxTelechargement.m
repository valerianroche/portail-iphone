//
//  FluxTelechargement.m
//  Portail Mines
//
//  Created by Valérian Roche on 15/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "FluxTelechargement.h"
#import "Reseau.h"

@implementation FluxTelechargement

-(id)initWithDomaine:(NSString *)domaine etUsername:(NSString *)username withParent:(Reseau *)parent etPhoto:(BOOL)photoOuDoc {
    self = [super init];
    if (self) {
        nomDomaine = domaine;
        reseau = parent;
        type = photoOuDoc;
        personne = username;
        if (photoOuDoc) {
            getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/static/%@.jpg",username]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2];
        }
        else {
            getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/people/%@/json",username]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2];
        }

    }
    return self;
}

-(void)startDownload {
    connection = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) data = [[NSMutableData alloc] init];
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    if (type) {
        image = [UIImage imageWithData:data];
        [reseau renvoieImage:image forUsername:personne];
    }
    else {
        NSError *error;
        NSDictionary *dico = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog([error description]);
        }
        [reseau renvoieInfos:dico forUsername:personne];
    }
    data=nil;
}

@end
