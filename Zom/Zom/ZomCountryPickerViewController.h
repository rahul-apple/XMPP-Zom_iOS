//
//  ZomCountryPickerViewController.h
//  Zom
//
//  Created by Bose on 03/03/17.
//
//

#import <UIKit/UIKit.h>

@protocol ZomCountryCodeDelegate <NSObject>

- (void)countryCodeSelectionCompleted:(NSDictionary*)dict;

@end


@interface ZomCountryPickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarCountry;
@property (weak, nonatomic) IBOutlet UITableView *tblView;

@property (weak,nonatomic)id<ZomCountryCodeDelegate>delegate;

@end
