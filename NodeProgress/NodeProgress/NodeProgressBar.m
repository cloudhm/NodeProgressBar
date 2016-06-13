//
//  NodeProgressBar.m
//  NodeProgress
//
//  Created by cloud on 6/12/16.
//  Copyright © 2016 Yannick Loriot. All rights reserved.
//

#import "NodeProgressBar.h"
#define LEFT_OFFSET                         25
#define RIGHT_OFFSET                        25
#define LABEL_HEIGHT                        20
#define SLIDER_HEIGHT                       2
#define NODE_RADIUS                         4
#define NODE_OUTER_RADIUS                   6
#define NODE_PROGRESS_FPS                   (1./30)
#define NODE_ANIMATION_TIME                 0.25f
/**
 * this enum value, set label text color
 */
typedef NS_ENUM(NSInteger, NodeStatus)
{
    PastNode,
    CurrentNode,
    ShouldNode
};
@interface NodeLabel : UILabel
@property (assign, nonatomic) NodeStatus nodeStatus;
@end
@implementation NodeLabel

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont fontWithName:@"Optima" size:14];
    }
    return self;
}
-(void)setNodeStatus:(NodeStatus)nodeStatus
{
    _nodeStatus = nodeStatus;
    switch (_nodeStatus)
    {
        case PastNode:
            self.textColor = [UIColor orangeColor];
            break;
        case CurrentNode:
            self.textColor = [UIColor redColor];
            break;
        case ShouldNode:
            self.textColor = [UIColor lightGrayColor];
            break;
        default:
            break;
    }
}
@end
@interface PlusButton : UIButton
@end
@implementation PlusButton
-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBackground:context//draw red round
                withRect:rect];
    [self drawCross:context//draw center cross
           withRect:rect];
    
}
-(void)drawBackground:(CGContextRef)context
             withRect:(CGRect)rect
{
    CGContextSaveGState(context);
    {
        CGPoint center = CGPointMake(rect.size.width/2., rect.size.height/2.);
        CGFloat radius = rect.size.height/2.;
        UIBezierPath* bezierPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                  radius:radius
                                                              startAngle:0
                                                                endAngle:M_PI*2
                                                               clockwise:YES];
        [[UIColor redColor]setFill];
        [bezierPath fill];
    }
    CGContextRestoreGState(context);
}
-(void)drawCross:(CGContextRef)context
        withRect:(CGRect)rect
{
    CGContextSaveGState(context);
    {
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        UIBezierPath* vPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.size.width/2-.5,0, 1, rect.size.height)];
        [bezierPath appendPath:vPath];
        UIBezierPath* hPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.size.height/2-.5, rect.size.width,1)];
        [bezierPath appendPath:hPath];
        CGPoint center = CGPointMake(rect.size.width/2., rect.size.height/2.);
        CGFloat radius = rect.size.height/2.;
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                radius:radius
                                                            startAngle:0
                                                              endAngle:M_PI*2
                                                             clockwise:YES];
        CGContextAddPath(context, [clipPath CGPath]);
        CGContextClip(context);
        CGContextSaveGState(context);
        {
            CGContextAddPath(context, [bezierPath CGPath]);
            CGContextClip(context);
            CGContextSetFillColorWithColor(context, [[UIColor yellowColor] CGColor]);
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
}
@end
@interface NodeProgressBar()
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSArray* nodes;
@property (strong, nonatomic) NSArray* labels;
@property (assign, nonatomic) CGFloat oneSide;
@property (strong, nonatomic) NSTimer* progressTimer;
@property (assign, nonatomic) CGFloat currentProgress;
@property (assign, nonatomic) CGFloat progressTargetValue;
@property (strong, nonatomic) PlusButton* plusButton;
@end
@implementation NodeProgressBar
+(instancetype)nodeProgressBarWithFrame:(CGRect)frame
                              withNodes:(NSArray *)nodes
                       withCurrentIndex:(NSInteger)currentIndex
{
    return [[[self class]alloc]initWithFrame:frame
                                   withNodes:nodes
                            withCurrentIndex:currentIndex];
}
+(instancetype)nodeProgressBarWithFrame:(CGRect)frame
                              withNodes:(NSArray *)nodes
{
    return [self nodeProgressBarWithFrame:frame
                                withNodes:nodes
                         withCurrentIndex:0];
}
-(instancetype)initWithFrame:(CGRect)frame
                   withNodes:(NSArray *)nodes
{
    return [self initWithFrame:frame
                     withNodes:nodes
              withCurrentIndex:0];
}
-(instancetype)initWithFrame:(CGRect)frame
                   withNodes:(NSArray *)nodes
            withCurrentIndex:(NSInteger)currentIndex
{
    NSParameterAssert([nodes isKindOfClass:[NSArray class]]);
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.currentIndex = currentIndex;
        self.currentProgress = (CGFloat)currentIndex;
        self.progressTargetValue = self.currentProgress;
        self.nodes = nodes;
        [self updateOneSide];
        [self initLabels];
        [self initButton];
    }
    return self;
}
-(void)initLabels
{
    NSMutableArray* labels = @[].mutableCopy;
    NSInteger index = 0;
    for (NSString* nodeName in self.nodes)
    {
        NodeLabel* label = [[NodeLabel alloc]initWithFrame:CGRectMake(0, 0, self.oneSide, LABEL_HEIGHT)];
        label.text = nodeName;
        label.center = [self centerPointForIndex:index];
        label.nodeStatus = [self compareResultWithIndex:index];
        [labels addObject:label];
        [self addSubview:label];
        index++;
    }
    self.labels = labels;
}
-(void)initButton
{
    PlusButton* plusButton = [[PlusButton alloc]initWithFrame:CGRectMake(0, 0, NODE_RADIUS*2, NODE_RADIUS*2)];
    [self addSubview:plusButton];
    self.plusButton = plusButton;
    [self updatePlusButtonCenterWithAnimated:NO];
}
-(NodeStatus)compareResultWithIndex:(NSInteger)index
{
    if (index == self.currentIndex)
    {
        return CurrentNode;
    }
    else if (index < self.currentIndex)
    {
        return PastNode;
    }
    return ShouldNode;
}
-(void)updateOneSide
{
    self.oneSide = 1.f * (CGRectGetWidth(self.frame) - LEFT_OFFSET-RIGHT_OFFSET-1)/(self.nodes.count);
}
-(void)updatePlusButtonCenterWithAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:NODE_ANIMATION_TIME animations:^{
            self.plusButton.center = CGPointMake(LEFT_OFFSET+(self.progressTargetValue+.5)*self.oneSide, (CGRectGetHeight(self.frame)-LABEL_HEIGHT)/2.);
        }];
    }
    else
    {
        self.plusButton.center = CGPointMake(LEFT_OFFSET+(self.currentIndex+.5)*self.oneSide, (CGRectGetHeight(self.frame)-LABEL_HEIGHT)/2.);
    }
}
- (CGPoint)centerPointForIndex:(NSInteger)i
{
    return CGPointMake(LEFT_OFFSET + self.oneSide * (i + .5), CGRectGetHeight(self.frame)-LABEL_HEIGHT/2);
}
-(void)setNodeAtIndex:(NSInteger)index
         withAnimated:(BOOL)animated
{
    @synchronized (self)
    {
        if (self.progressTimer && [self.progressTimer isValid])
        {
            [self.progressTimer invalidate];
        }
        
        NSInteger shouldIndex = index;
        if (shouldIndex > (self.nodes.count-1))
        {
            shouldIndex = self.nodes.count-1;
        } else if (shouldIndex < 0)
        {
            shouldIndex = 0;
        }
        
        if (animated)
        {
            self.progressTargetValue = (CGFloat)shouldIndex;
            CGFloat incrementValue   = ((self.progressTargetValue - self.currentIndex) * NODE_PROGRESS_FPS) / NODE_ANIMATION_TIME;
            self.progressTimer = [NSTimer timerWithTimeInterval:NODE_PROGRESS_FPS
                                                         target:self
                                                       selector:@selector(updateProgressWithTimer:)
                                                       userInfo:[NSNumber numberWithFloat:incrementValue]
                                                        repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.progressTimer
                                         forMode:NSRunLoopCommonModes];
            [self updatePlusButtonCenterWithAnimated:animated];
        }
        else
        {
            self.currentIndex = shouldIndex;
            [self setNeedsDisplay];
        }
    }
}
- (void)updateProgressWithTimer:(NSTimer *)timer
{
    CGFloat dt_progress = [timer.userInfo floatValue];
    
    self.currentProgress += dt_progress;
   
    if ((dt_progress < 0 && self.currentProgress <= self.progressTargetValue)
        || (dt_progress > 0 && self.currentProgress >= self.progressTargetValue))
    {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        self.currentProgress = self.progressTargetValue;
        self.currentIndex = (NSInteger)self.progressTargetValue;
        NSInteger index = 0;
        for (NodeLabel* nodeLabel in self.labels)
        {
            nodeLabel.nodeStatus = [self compareResultWithIndex:index];
            index++;
        }
    }
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect innerRect = rect;
    innerRect.size.height -= LABEL_HEIGHT;
    if (innerRect.size.height<=0)
    {
        return;
    }
    [self drawBackground:context withDrawRect:innerRect];
    [self drawProgressBar:context withDrawRect:innerRect];
    [self drawNodes:context withDrawRect:innerRect];
    [self drawNodeOuter:context withDrawRect:innerRect];
    
}
-(void)drawBackground:(CGContextRef)context
         withDrawRect:(CGRect)rect
{
    CGContextSaveGState(context);
    {// draw slider
        CGRect sliderRect = CGRectMake(LEFT_OFFSET+self.oneSide/2, rect.size.height/2-SLIDER_HEIGHT/2, rect.size.width-LEFT_OFFSET-RIGHT_OFFSET-self.oneSide, SLIDER_HEIGHT);
        UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:sliderRect];
        [[UIColor lightGrayColor]setFill];
        [bezierPath fill];
    }
    CGContextRestoreGState(context);
    for (NSInteger index = 0; index<self.nodes.count; index++)
    {
        CGPoint center = CGPointMake(LEFT_OFFSET+self.oneSide*(index+.5), rect.size.height/2);
        CGContextSaveGState(context);
        {// draw nodes
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath addArcWithCenter:center
                                  radius:NODE_RADIUS
                              startAngle:0
                                endAngle:M_PI*2
                               clockwise:YES];
            [[UIColor lightGrayColor]setFill];
            [bezierPath fill];
        }
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        {// draw node outer circle
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath addArcWithCenter:center
                                  radius:NODE_OUTER_RADIUS
                              startAngle:0
                                endAngle:M_PI*2
                               clockwise:YES];
            [[UIColor lightGrayColor]setStroke];
            bezierPath.lineWidth = 1.f;
            [bezierPath stroke];
        }
        CGContextRestoreGState(context);
    }
}
-(void)drawProgressBar:(CGContextRef)context
          withDrawRect:(CGRect)rect
{
    CGContextSaveGState(context);
    {// draw slider
        CGRect sliderRect = CGRectMake(LEFT_OFFSET+self.oneSide/2, rect.size.height/2-SLIDER_HEIGHT/2, rect.size.width-LEFT_OFFSET-RIGHT_OFFSET-self.oneSide, SLIDER_HEIGHT);
        UIBezierPath* sliderPath = [UIBezierPath bezierPathWithRect:sliderRect];
        CGRect clipRect = rect;
        clipRect.size.width = self.oneSide*self.currentProgress + .5* self.oneSide + LEFT_OFFSET;
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:clipRect];
        CGContextAddPath(context, [clipPath CGPath]);
        CGContextClip(context);
        CGContextSaveGState(context);
        {
            CGContextAddPath(context, [sliderPath CGPath]);
            CGContextClip(context);
            
            CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
}
-(void)drawNodes:(CGContextRef)context
    withDrawRect:(CGRect)rect
{
    CGContextSaveGState(context);
    {// draw slider
        CGRect clipRect = rect;
        clipRect.size.width = self.oneSide*self.currentProgress + .5* self.oneSide + LEFT_OFFSET + NODE_RADIUS;
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:clipRect];
        UIBezierPath* nodePath = [UIBezierPath bezierPath];
        for (NSInteger index = 0; index<self.nodes.count; index++)
        {
            CGPoint center = CGPointMake(LEFT_OFFSET+self.oneSide*(index+.5), rect.size.height/2);
            {// draw nodes
                UIBezierPath* bezierPath = [UIBezierPath bezierPath];
                [bezierPath addArcWithCenter:center
                                      radius:NODE_RADIUS
                                  startAngle:0
                                    endAngle:M_PI*2
                                   clockwise:YES];
                [nodePath appendPath:bezierPath];
            }
        }
        CGContextAddPath(context, [clipPath CGPath]);
        CGContextClip(context);
        CGContextSaveGState(context);
        {
            CGContextAddPath(context, [nodePath CGPath]);
            CGContextClip(context);
            CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
}
-(void)drawNodeOuter:(CGContextRef)context
        withDrawRect:(CGRect)rect
{
    CGContextSaveGState(context);
    {// draw slider
        CGRect clipRect = rect;
        clipRect.size.width = self.oneSide*self.currentProgress + .5* self.oneSide + LEFT_OFFSET + NODE_OUTER_RADIUS;
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:clipRect];
        UIBezierPath* nodePath = [UIBezierPath bezierPath];
        for (NSInteger index = 0; index<self.nodes.count; index++)
        {
            CGPoint center = CGPointMake(LEFT_OFFSET+self.oneSide*(index+.5), rect.size.height/2);
            {// draw node outer circle
                UIBezierPath* bezierPath = [UIBezierPath bezierPath];
                [bezierPath addArcWithCenter:center
                                      radius:NODE_OUTER_RADIUS
                                  startAngle:0
                                    endAngle:M_PI*2
                                   clockwise:YES];
                [nodePath appendPath:bezierPath];
            }
        }
        CGContextAddPath(context, [clipPath CGPath]);
        CGContextClip(context);
        CGContextSaveGState(context);
        {
            CGContextAddPath(context, [nodePath CGPath]);
            CGContextClip(context);
            [[UIColor redColor]setStroke];
            nodePath.lineWidth = 1.f;
            [nodePath stroke];
        }
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
}
@end
