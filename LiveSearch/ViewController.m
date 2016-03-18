//
//  ViewController.m
//  LiveSearch
//
//  Created by Pawel Kowalczuk on 17/03/16.
//  Copyright © 2016 appdev4everyone. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "SearchResultsViewController.h"

@interface ViewController ()<UISearchControllerDelegate,UISearchBarDelegate,SearchResultsViewControllerDelegate>{
    MKMapView *_map;
    UISearchController *_searchcontroller;
}

@end

@implementation ViewController

- (void)loadView{
    UIView *view = [[UIView alloc] init];
    [self setView:view];
    
    _map = [[MKMapView alloc] init];
    [_map setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:_map];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_map]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_map)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_map]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_map)]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    SearchResultsViewController *resultsUpdater = [[SearchResultsViewController alloc] init];
    [resultsUpdater setDelegate:self];
    _searchcontroller = [[UISearchController alloc] initWithSearchResultsController:resultsUpdater];
    [_searchcontroller setDelegate:self];
    [_searchcontroller setSearchResultsUpdater:resultsUpdater];
    [[_searchcontroller searchBar] sizeToFit];
    [_searchcontroller setDimsBackgroundDuringPresentation:NO];
    [_searchcontroller setHidesNavigationBarDuringPresentation:NO];
    [_searchcontroller setDefinesPresentationContext:YES];
    [[_searchcontroller searchBar] setDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark search result controller delegate

- (void)didSelectFoundPlacemark:(CLPlacemark *)placemark{
    MKCoordinateRegion region = MKCoordinateRegionMake(placemark.location.coordinate,
                                                       MKCoordinateSpanMake(0.01, 0.01));//NOTE: this region has completly default(hardcoded) span and in some cases will be to small and in other to large but it is just for presentation purposes
    [_map setRegion:region];
    
    
}

#pragma mark search presenting stuff

- (void)search:(id)sender{
#pragma unused (sender)
    if (self.presentedViewController != _searchcontroller) {
        [_searchcontroller.searchBar setText:@""];
        [self presentViewController:_searchcontroller animated:YES completion:NULL];
    }
}

@end
