//
//  NodeProgressBar.h
//  NodeProgress
//
//  Created by cloud on 6/12/16.
//  Copyright © 2016 Yannick Loriot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NodeProgressBar : UIView
/**
 * factory method
 */
+(instancetype)nodeProgressBarWithFrame:(CGRect)frame
                              withNodes:(NSArray*)nodes
                       withCurrentIndex:(NSInteger)currentIndex;
+(instancetype)nodeProgressBarWithFrame:(CGRect)frame
                              withNodes:(NSArray*)nodes;
/**
 * instancetype method
 */
-(instancetype)initWithFrame:(CGRect)frame
                   withNodes:(NSArray*)nodes
            withCurrentIndex:(NSInteger)currentIndex;
-(instancetype)initWithFrame:(CGRect)frame
                   withNodes:(NSArray*)nodes;
/**
 * set progress value and button position
 */
-(void)setNodeAtIndex:(NSInteger)index
         withAnimated:(BOOL)animated;
@end
