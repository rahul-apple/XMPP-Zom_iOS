//
//  ZomChatCallViewController.m
//  Zom
//
//  Created by Bose on 09/03/17.
//
//

#import "ZomChatCallViewController.h"
#import <SMSegmentView/SMSegmentView-Swift.h>

@interface ZomChatCallViewController () {
    SMSegmentView *segmentView;
}

@end

@implementation ZomChatCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    segmentView = [[SMSegmentView alloc] initWithFrame:_viewSegment.frame separatorColour:[UIColor greenColor] separatorWidth:2.0 segmentProperties:nil];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
