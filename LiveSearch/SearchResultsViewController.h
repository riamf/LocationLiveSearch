//
//  SearchResultsViewController.h
//  LiveSearch
//
//  Created by Pawel Kowalczuk on 17/03/16.
//  Copyright © 2016 appdev4everyone. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLPlacemark;
@protocol SearchResultsViewControllerDelegate <NSObject>
- (void)didSelectFoundPlacemark:(CLPlacemark*)placemark;
@end

@interface SearchResultsViewController : UIViewController<UISearchResultsUpdating>
@property (nonatomic, assign) id<SearchResultsViewControllerDelegate> delegate;
@end
