//
//  SearchResultsViewController.m
//  LiveSearch
//
//  Created by Pawel Kowalczuk on 17/03/16.
//  Copyright © 2016 appdev4everyone. All rights reserved.
//

#import "SearchResultsViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchResultsViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_table;
    NSArray *_searchResults;
    NSDictionary *_searchResultsDictionary;
    CLGeocoder *_geocoder;
}

@end
@implementation SearchResultsViewController

- (instancetype)init{
    if(self = [super init]){
        _geocoder = [[CLGeocoder alloc] init]; //NOTE: one geocoder
    }
    return self;
}

- (void)loadView{
    UIView *view = [[UIView alloc] init];
    [self setView:view];
    
    _table = [[UITableView alloc] init];
    [_table setDelegate:self];
    [_table setDataSource:self];
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [_table setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:_table];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_table]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_table)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_table]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_table)]];
}

#pragma mark table view delegate and data source stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchResults.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    [[cell textLabel] setText:_searchResults[[indexPath row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectFoundPlacemark:)]) {
        NSString *key = _searchResults[indexPath.row];
        CLPlacemark *placemark = _searchResultsDictionary[key];
        [self.delegate didSelectFoundPlacemark:placemark];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark Search stuff with clgeocoder

- (void)updateSearchResultsWithArray:(NSArray*)searchResults AndDictionary:(NSDictionary*)searchResultsDictionary{
    _searchResults = [NSArray arrayWithArray:searchResults];
    _searchResultsDictionary = [NSDictionary dictionaryWithDictionary:searchResultsDictionary];
    [_table reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchText = [[searchController searchBar] text];
    if ([searchText length] < 2) return;//NOTE: I don't want to do search for to small text, result will most likely be not what user is looking for
    if ([_geocoder isGeocoding] == false) { //NOTE: only when geocoder is not durring last request
        __weak typeof(self) weakSelf = self;
        [_geocoder geocodeAddressString:searchText completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            /*
             If ur application have access to user location or you know with some accuracy where to look for location that user want to find then I would recommend to use:
             [_geocoder geocodeAddressString:searchText inRegion:searchRegion completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {}]
             it will search for results in region passed as a parameter
             */
            if (error == nil) {
                NSMutableArray *mutableArray = [NSMutableArray array];
                NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
                for (CLPlacemark *pl in placemarks) {
                    NSArray *formattedAddressLines = [pl addressDictionary][@"FormattedAddressLines"];
                    NSString *joinedLines = [formattedAddressLines componentsJoinedByString:@", "];
                    if(joinedLines != nil && joinedLines.length > 0){
                        [mutableArray addObject:joinedLines];
                        [mutableDictionary setObject:pl forKey:joinedLines];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf updateSearchResultsWithArray:mutableArray AndDictionary:mutableDictionary];
                });
            }
        }];
    }
}

@end
