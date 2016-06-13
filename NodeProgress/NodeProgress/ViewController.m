//
//  ViewController.m
//  NodeProgress
//
//  Created by cloud on 6/13/16.
//  Copyright © 2016 yedaoinc. All rights reserved.
//

#import "ViewController.h"
#import "NodeProgressBar.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

@property (strong, nonatomic) NSArray* nodes;
@property (strong, nonatomic) NodeProgressBar* progressBar;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nodes = @[@"1",@"2",@"3",@"4"];
    CGRect frame = CGRectMake(20, 80, [UIScreen mainScreen].bounds.size.width-40, 60);
    NSInteger index = arc4random()%self.nodes.count;
    [self updateIndexLabelWithIndex:index];
    self.progressBar = [NodeProgressBar nodeProgressBarWithFrame:frame
                                                       withNodes:self.nodes
                                                withCurrentIndex:index];
    [self.view addSubview:self.progressBar];
}
-(void)updateIndexLabelWithIndex:(NSInteger)index
{
    
    self.indexLabel.text = self.nodes[index];
}
- (IBAction)modify:(id)sender {
    NSInteger index = arc4random()%self.nodes.count;
    [self updateIndexLabelWithIndex:index];
    [self.progressBar setNodeAtIndex:index withAnimated:YES];
}

@end
