//
//  ZomCountryPickerViewController.m
//  Zom
//
//  Created by Bose on 03/03/17.
//
//

#import "ZomCountryPickerViewController.h"
#import <JSQMessagesViewController/UIImage+JSQMessages.h>
#import "VROChatAPIHandler.h"

@interface ZomCountryPickerViewController ()<UISearchBarDelegate>
{
    NSArray *countriesList;
    NSIndexPath *selectedIndexPath;
    NSMutableArray *arrayFiltered;
    BOOL isSearching;
}
@property (nonatomic, strong) VROChatAPIHandler *apiHandler;

@end

@implementation ZomCountryPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.apiHandler = [[VROChatAPIHandler alloc]init];
    arrayFiltered = [NSMutableArray new];
    [self loadCountryList];


    // Do any additional setup after loading the view.
}

-(void)loadView {
    [super loadView];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(backBarButtonAction)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

-(void)backBarButtonAction {
    if (selectedIndexPath) {
        NSDictionary *statusDict = [isSearching ? arrayFiltered : countriesList objectAtIndex:selectedIndexPath.row];
        [self.delegate countryCodeSelectionCompleted:statusDict];
        [self.view endEditing:YES];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UISearchBar Delegates
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSArray *resultArray = [countriesList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"country_name CONTAINS[c] %@",searchText]];
    isSearching = ![searchText isEqualToString:@""];
    selectedIndexPath = nil;
    [arrayFiltered removeAllObjects];
    if(resultArray.count > 0)
    {
        [arrayFiltered addObjectsFromArray:resultArray];
    }
    [self.tblView reloadData];
}


-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    isSearching = NO;
    [_tblView reloadData];
}

#pragma mark - UITableView Data Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return isSearching ? [arrayFiltered count] : [countriesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    
    cell.accessoryType = selectedIndexPath != nil && selectedIndexPath.row == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    id name = [isSearching ? arrayFiltered : countriesList objectAtIndex:indexPath.row][@"country_name"];
    id code = [isSearching ? arrayFiltered :countriesList objectAtIndex:indexPath.row][@"country_code"];
    
    cell.textLabel.text = [name isKindOfClass:[NSNull class]] ? @"" : name;
    cell.detailTextLabel.text = [name isKindOfClass:[NSNull class]] ? @"" : code;
    
    return cell;
    
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    selectedIndexPath = indexPath;
    [self.tblView reloadData];
    
}

- (void)loadCountryList
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *error;
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"countryList.json"];
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSData* plistData = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
    NSPropertyListFormat format;
    if (plistData) {
        NSDictionary* plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
        if(!plist) {
            [self fetchCountryList];
        } else {
            countriesList = (NSArray *)plist;
            [self.tblView reloadData];
            
        }
    } else {
        [self fetchCountryList];
    }
}

-(void)fetchCountryList {
    [_apiHandler listCountryCodes:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            //2) Create the full file path by appending the desired file name
            NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:@"countryList.json"];
            
            //Load the array
            
            NSMutableArray *yourArray = [[NSMutableArray alloc] initWithContentsOfFile:yourArrayFileName];
            
            if(yourArray == nil)
            {
                //Array file didn't exist... create a new one
                yourArray = [[NSMutableArray alloc]initWithArray:responseObject];
                //Fill with default value
            }
            
            [yourArray writeToFile:yourArrayFileName atomically:YES];
            [self loadCountryList];
        }
    } failure:^(NSError *error) {
        [self loadCountryList];
    }];
}

@end
