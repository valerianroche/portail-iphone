//
//  Trombi.m
//  Portail Mines
//
//  Created by Valérian Roche on 14/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "Trombi.h"
#import "Reseau.h"

@interface Trombi ()

@end

@implementation Trombi

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Trombi", @"Trombi");
        self.tabBarItem.image = [UIImage imageNamed:@"second.png"];
        reseauTest = reseau;
        searching = NO;
        peutSelect = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _barre.topItem.title = @"Trombi";
    _liste.delegate = self;
    _liste.dataSource = self;
    _liste.scrollsToTop = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    trombi = [reseauTest getTrombi];
    if (!trombi) {
        [_activite startAnimating];
        trombi = [[NSArray alloc] initWithObjects:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargeTrombi) name:@"tTelecharge" object:nil];
    _liste.tableHeaderView = searchBar;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    copy = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([trombi count] != 0) {
        [_liste scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

-(void)chargeTrombi {
    trombi = [reseauTest getTrombi];
    if (!trombi) {
        trombi = [[NSArray alloc] initWithObjects:nil];
        [_activite stopAnimating];
        UIAlertView *alerte = [[UIAlertView alloc] initWithTitle:@"Raté!!" message:@"Impossible de télécharger le trombi" delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil];
        [alerte show];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tTelecharge" object:nil];
        if ([_activite isAnimating]) {
            [_liste reloadData];
            [_liste scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [_activite stopAnimating];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (searching) {
        return 1;
    }
    
    return 27;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (searching) {
        return @"";
    }
    tab = [NSArray arrayWithObjects:@"",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L",@"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X",@"Y", @"Z", nil];
    return [tab objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching) {
        return [copy count];
    }
    if (section == 0) {
        return 0;
    }
    return [[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"last_name BEGINSWITH[cd] %@", [tab objectAtIndex:section]]] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (searching) {
        cell.textLabel.text = [[copy objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:@"last_name"];
        cell.detailTextLabel.text = [[copy objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:@"first_name"];
        cell.imageView.image = [UIImage imageNamed:@"first.png"];
    }
    else {
        NSDictionary *tableau = [[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"last_name BEGINSWITH[cd] %@", [tab objectAtIndex:[indexPath indexAtPosition:0]]]] objectAtIndex:[indexPath indexAtPosition:1]];
        cell.textLabel.text = [tableau objectForKey:@"last_name"];
        cell.detailTextLabel.text = [tableau objectForKey:@"first_name"];
        cell.imageView.image = [UIImage imageNamed:@"first.png"];
    }
    return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (searching) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:tab];
    [array replaceObjectAtIndex:0 withObject:UITableViewIndexSearch];
    return array;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (searching) {
        return -1;
    }
    else if (index == 0) {
        [_liste setContentOffset:CGPointZero animated:YES];
        return NSNotFound;
    }
    else {
        return index;
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searching = YES;
    peutSelect = NO;
    _liste.scrollEnabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finRecherche:)];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [copy removeAllObjects];
    
    if ([searchText length] != 0) {
        searching = YES;
        peutSelect = YES;
        _liste.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        searching = NO;
        peutSelect = NO;
        _liste.scrollEnabled = NO;
    }
    [_liste reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchTableView];
}

-(void)searchTableView {
    NSString *searchText = searchBar.text;
    
    [copy addObjectsFromArray:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(last_name CONTAINS[cd] %@) OR (first_name CONTAINS[cd] %@)", searchText, searchText]]];
}

-(void)finRecherche:(id)sender {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    peutSelect = YES;
    searching = NO;
    self.navigationItem.rightBarButtonItem = nil;
    _liste.scrollEnabled = YES;
    
    [_liste reloadData];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (peutSelect)
        return indexPath;
    else
        return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
