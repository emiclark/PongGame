//
//  ViewController.h
//  PongGame
//
//  Created by Emiko Clark on 11/21/16.
//  Copyright © 2016 Emiko Clark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UICollisionBehaviorDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *ball;
@property (nonatomic, strong) UIView *paddle;
@property (nonatomic, strong) UIView *bottomEdge;
@property (nonatomic, strong) UILabel *gameOverLabel;
@property (nonatomic, strong) IBOutlet UIButton *beginGameButton;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic) CGPoint lhsPoint;
@property (nonatomic) CGPoint rhsPoint;
@property (nonatomic) BOOL    ballHitPaddle;



- (void) panGestureResponder:(UIPanGestureRecognizer *) sender;
- (IBAction) screenTapped:   (UITapGestureRecognizer *) recognizer;
- (void) createBall;
- (void) createPaddle;
- (void) createBottomEdge;
- (void) createGameOverLabel;
- (void) createBeginGameButton;
- (void) setupBehaviors;

@end

