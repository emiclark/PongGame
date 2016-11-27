//
//  ViewController.m
//  PongGame
//
//  Created by Emiko Clark on 11/21/16.
//  Copyright © 2016 Emiko Clark. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

#define  BALL_SIZE       65
#define  PADDLE_WIDTH    150
#define  PADDLE_HEIGHT   50
#define  GAME_OVER_LABEL 175


static CGRect screenSize;
static CGFloat screenWidth;
static CGFloat screenHeight;


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    // boolean to check if ball hit the paddle
    self.ballHitPaddle = NO;
    
    // add tap gesture to screen to begin new game
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(screenTapped:)];
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer: tapGesture];
    
    // calculate screen dimensions for centering uivew
    screenSize = [[UIScreen mainScreen] bounds];
    screenWidth = CGRectGetWidth(screenSize);
    screenHeight = CGRectGetHeight(screenSize);
    
    [self createGameOverLabel];
    [self createBeginGameButton];

}

#pragma mark - Gesture Recognizer Methods


- (IBAction) screenTapped: (UITapGestureRecognizer *)recognizer {
    
    // remove paddle and ball from screen
    [self.ball removeFromSuperview];
    [self.paddle removeFromSuperview];
    [self.bottomEdge removeFromSuperview];
    [self.beginGameButton removeFromSuperview];
    self.gameOverLabel.hidden = YES;

    // begin new game
    self.view.backgroundColor = [UIColor whiteColor];
    [self createBall];
    [self createPaddle];
    [self createBottomEdge];
    [self setupBehaviors];
    
}

- (void) panGestureResponder: (UIPanGestureRecognizer *) sender {
    
    // get next point where the paddle moved to, coordinates based on superview
    CGPoint paddleMovedTo = [sender translationInView: self.view.superview];
    
    // restrict paddle to horizontal movement
    self.paddle.center = CGPointMake(self.paddle.center.x + paddleMovedTo.x, self.paddle.center.y);
    
    // let animator redraw/update/refresh the game with new paddle movement
    [self.animator updateItemUsingCurrentState: self.paddle];
    
    // CGPointZero ensures the horizontal translation be reset at every point and not cumulative
    [sender setTranslation:CGPointZero inView:self.paddle.superview];

}

#pragma mark - Create ball, paddle, bottomEdge & Behaviors

- (void) createBall {
    
    // create ball with diameter BALL_SIZE
    CGFloat ballPosition = (screenWidth - BALL_SIZE) /2;
    self.ball = [[UIView alloc] initWithFrame:CGRectMake(ballPosition, BALL_SIZE, BALL_SIZE, BALL_SIZE)];
    self.ball.backgroundColor = [UIColor orangeColor];
    self.ball.layer.cornerRadius = self.ball.bounds.size.width/2;
    self.ball.clipsToBounds = YES;
    self.ball.layer.borderWidth = 1;
    self.ball.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:self.ball];
}


- (void) createPaddle {
    
    // calculate center of screen to draw paddle
    CGFloat paddleCenterPoint = (screenWidth - PADDLE_WIDTH) /2;
    
    // set screen's x-coordinate to position paddle
    self.paddle = [[UIView alloc] initWithFrame:CGRectMake(paddleCenterPoint, screenHeight - PADDLE_HEIGHT * 1.5,
                                                           PADDLE_WIDTH, PADDLE_HEIGHT)];
    self.paddle.backgroundColor = [UIColor greenColor];
    self.paddle.layer.cornerRadius = 10;
    self.paddle.layer.borderWidth = 2;
    self.paddle.layer.borderColor = [UIColor lightGrayColor].CGColor;

    // add pan gesture to paddle
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureResponder:)];
    panGesture.delegate = self;
    [self.paddle addGestureRecognizer:panGesture];
    [self.view addSubview:self.paddle];
    
}


- (void) createBottomEdge {
    // create a view that sits at the bottom of screen below the paddle.
    // if ball hits the view, then game over
    self.bottomEdge = [[UIView alloc] initWithFrame:CGRectMake(self.lhsPoint.x, screenHeight - PADDLE_HEIGHT, screenWidth, PADDLE_HEIGHT)];
    self.bottomEdge.backgroundColor = [UIColor colorWithRed:230/255. green:215/255. blue:230/255. alpha:1.0];
    [self.view addSubview:self.bottomEdge];
}


- (void) setupBehaviors {
    
    // create behaviors for the ball and paddle and add to animator
    self.animator  = [[UIDynamicAnimator alloc] initWithReferenceView: self.view];
    
    // set ball, paddle and screen edge boundaries for collisionBehavior
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems: @[self.ball, self.paddle, self.bottomEdge]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    collisionBehavior.collisionMode = UIDynamicItemCollisionBoundsTypeRectangle;
    collisionBehavior.collisionMode = UIRectEdgeBottom;
    collisionBehavior.collisionDelegate = self;
    
    // make a line to define the bottom edge where the y-axis of paddle will stay fixed
    // set 2 points to define the collision line
    self.lhsPoint = CGPointMake(0.0 , screenHeight - PADDLE_HEIGHT);
    self.rhsPoint = CGPointMake(screenWidth , screenHeight - PADDLE_HEIGHT);

    // create line using bezierPath, add the line to collision boundary, add line's collision boundary to the animator
    UIBezierPath *bottomLineCollisionEdge = [UIBezierPath bezierPath];
    [bottomLineCollisionEdge moveToPoint:self.lhsPoint];
    [bottomLineCollisionEdge addLineToPoint:self.rhsPoint];
    [bottomLineCollisionEdge closePath];
    [collisionBehavior addBoundaryWithIdentifier: @"bottomLineCollisionEdge" fromPoint: self.lhsPoint toPoint:self.rhsPoint];
    [self.animator addBehavior: collisionBehavior];
    
    // add gravity to ball
    UIGravityBehavior *ballGravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.ball]];
    ballGravityBehavior.magnitude = .9f;
    [self.animator addBehavior: ballGravityBehavior ];

    // add other behaviors to ball
    UIDynamicItemBehavior *ballBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ball]];
    ballBehavior.elasticity = .99f;
    ballBehavior.friction = 0;
    ballBehavior.density = 1;
    ballBehavior.resistance = 0;
    ballBehavior.angularResistance = 0;
    ballBehavior.allowsRotation = YES;
    [self.animator addBehavior: ballBehavior];

    // set up behaviors for the paddle
    UIDynamicItemBehavior *paddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddle]];
    paddleBehavior.density = 1000000;
    paddleBehavior.elasticity = 0;
    paddleBehavior.allowsRotation = NO;
    [self.animator addBehavior: paddleBehavior];
    
    // Start ball off with a push with pushBehavior
    UIPushBehavior *pushBallBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ball] mode: UIPushBehaviorModeInstantaneous];
    pushBallBehavior.active = YES;
    pushBallBehavior.magnitude = 3;
    pushBallBehavior.pushDirection = CGVectorMake(0.75, 1.0);
    [self.animator addBehavior: pushBallBehavior];
}

- (void) createGameOverLabel {
    
    // create game over label
    self.gameOverLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth-GAME_OVER_LABEL)/2, GAME_OVER_LABEL, GAME_OVER_LABEL, GAME_OVER_LABEL)];
    self.gameOverLabel.backgroundColor = [UIColor colorWithRed:200/255. green:228/255. blue:244/255. alpha:1.0];
    self.gameOverLabel.textColor = [UIColor purpleColor];
    self.gameOverLabel.numberOfLines = 0;
    self.gameOverLabel.textAlignment = NSTextAlignmentCenter;
    self.gameOverLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.gameOverLabel.text = @"GAME OVER!\n\n\n- Tap to continue -";
    self.gameOverLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.gameOverLabel.layer.borderWidth = 1;
    
    // create drop shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect: self.gameOverLabel.bounds];
    self.gameOverLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.gameOverLabel.layer.masksToBounds = NO;
    self.gameOverLabel.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.gameOverLabel.layer.shadowRadius = 5;
    self.gameOverLabel.layer.shadowOpacity = 0.5f;
    self.gameOverLabel.layer.shadowPath = shadowPath.CGPath;
    [self.view addSubview: self.gameOverLabel];
    self.gameOverLabel.hidden = YES;

}

- (void) createBeginGameButton {
    
    // create the initial 'begin game' button that appears when app is first played
    // the view has same size as the GAME_OVER_LABEL
    self.beginGameButton  = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth-GAME_OVER_LABEL)/2, GAME_OVER_LABEL, GAME_OVER_LABEL, GAME_OVER_LABEL)];
    [self.beginGameButton addTarget: self action:@selector(screenTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.beginGameButton setTitle:@"Tap to begin" forState:UIControlStateNormal];
    self.beginGameButton.backgroundColor = [UIColor colorWithRed:200/255. green:228/255. blue:244/255. alpha:1.0];
    self.beginGameButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.beginGameButton.tintColor = [UIColor purpleColor];
    [self.beginGameButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    self.beginGameButton.hidden = NO;
    [self.view addSubview: self.beginGameButton];
}


#pragma mark Colision delegate
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p {
    
    if (item1 == self.ball && item2 == self.bottomEdge ) {
        // game over, show game over label
        self.gameOverLabel.hidden = NO;
        [self.animator removeAllBehaviors];
    }
    
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 {
    
    if (item1 == self.ball && item2 == self.bottomEdge ) {
        // game over, show game over label
        self.gameOverLabel.hidden = NO;
        [self.animator removeAllBehaviors];
    }
    
}

#pragma mark Misc Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
