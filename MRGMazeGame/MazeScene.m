//
//  MazeScene.m
//  MRGMazeGame
//
//  Created by Matt Grossman on 7/22/13.
//  Copyright (c) 2013 Matt Grossman. All rights reserved.
//

#import "MazeScene.h"
#import "MRGMazeMyScene.h"
#import "MRGMazeStore.h"

@interface MazeScene (){
    SKSpriteNode *_person;
    SKSpriteNode *_wall;
    BOOL movementMode;
    int blockLength;
    
    NSMutableArray *_thisMaze;
}
- (void)changeModes;
@property BOOL contentCreated;
@property UIButton *toggleButton;
@property UIButton *sizeButton;
@property UIButton *saveButton; //YELLOW BUTTON
@property UIButton *loadButton; //BLUE BUTTON

@end

@implementation MazeScene

- (void)didMoveToView:(SKView *)view{
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
        self.physicsWorld.contactDelegate = self;
    }
}

- (void)createSceneContents{
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    movementMode = NO;
    blockLength = 16;
    _thisMaze = [[NSMutableArray alloc] init];
    
    
    
    _person = [self newPerson];
    _person.position = CGPointMake(blockLength,blockLength);
    [self createWalls];
    [self createToggleButton];
    [self createDrawButton];
    [self createSaveButton];
    [self createLoadButton];
    [self addGoalBlock];
    [self addChild:_person];
    
}




-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (movementMode) {
            CGPoint vector = CGPointMake(location.x-_person.position.x, location.y-_person.position.y);
            [_person.physicsBody applyForce:vector];
            
            //optional speed limiting
//            if (_person.physicsBody.velocity.x > 15 || _person.physicsBody.velocity.y > 15) {
//                [_person.physicsBody setVelocity:CGPointMake(15, 15)];
//            }
        } else {
            CGFloat xCenter = (CGFloat)((blockLength/2) + ((int)location.x / blockLength) * blockLength);
            CGFloat yCenter = (CGFloat)((blockLength/2) + ((int)location.y / blockLength) * blockLength);
            
            //break out if you clicked a block that already exists. Must account for fact that we are in a giant SKSprite already
            if ([[self nodesAtPoint:CGPointMake(xCenter, yCenter)] count] > 1) {
                break;
            }
            
            SKSpriteNode *block = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(blockLength, blockLength)];
            block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
            block.physicsBody.dynamic = NO;
            block.physicsBody.affectedByGravity = NO;
            block.physicsBody.usesPreciseCollisionDetection = YES;
            
            block.position = CGPointMake(xCenter, yCenter);
            
            [self addChild:block];
            
            [_thisMaze addObject:block];
        }

    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesMoved:touches withEvent:event];
}


- (SKSpriteNode *) newPerson{
    SKSpriteNode *pers = [[SKSpriteNode alloc] initWithColor:[SKColor greenColor] size:CGSizeMake(8, 8)];
    pers.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pers.size];
    pers.physicsBody.dynamic = YES;
    pers.physicsBody.affectedByGravity = NO;
    pers.physicsBody.usesPreciseCollisionDetection = YES;
    pers.physicsBody.mass *= 9;
    pers.physicsBody.contactTestBitMask = (1<<2);
    return pers;
}

- (SKSpriteNode *) newBlock{
    SKSpriteNode *w = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(32, 32)];
    w.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:w.size];
    w.physicsBody.dynamic = NO;
    w.physicsBody.affectedByGravity = NO;
    w.physicsBody.usesPreciseCollisionDetection = YES;
    return w;
}

- (void) createWalls{
    
    CGRect drawRectangle = CGRectMake(0,0, self.frame.size.width, self.frame.size.height);
    CGRect physicsRectangle = CGRectMake(0-CGRectGetMidX(drawRectangle), 0-CGRectGetMidY(drawRectangle), drawRectangle.size.width, drawRectangle.size.height);
    SKSpriteNode *borders = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:CGSizeMake(drawRectangle.size.width, drawRectangle.size.height)];
    borders.position = CGPointMake(CGRectGetMidX(drawRectangle), CGRectGetMidY(drawRectangle));
    borders.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:physicsRectangle];
    borders.physicsBody.usesPreciseCollisionDetection = YES;
    borders.physicsBody.contactTestBitMask = (1 << 3);
    [self addChild:borders];
    
}

- (void)createToggleButton{
    _toggleButton = [[UIButton alloc] initWithFrame:CGRectMake(256,16, 16, 16)];
    _toggleButton.backgroundColor = [SKColor brownColor];
    [_toggleButton addTarget:self action:@selector(changeModes) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_toggleButton];
    
}

- (void) createDrawButton{
    _sizeButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 16, 16, 16)];
    _sizeButton.backgroundColor = [SKColor grayColor];
    [_sizeButton addTarget:self action:@selector(cycleSize) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_sizeButton];
}

- (void) createSaveButton{
    CGRect saveRect = CGRectMake(184, 16, 16, 16);
    _saveButton = [[UIButton alloc] initWithFrame: saveRect];
    _saveButton.backgroundColor = [SKColor yellowColor];
    
    [_saveButton addTarget:self action:@selector(saveMaze) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_saveButton];
}

- (void) createLoadButton{
    _loadButton = [[UIButton alloc] initWithFrame:CGRectMake(148, 16, 16, 16)];
    _loadButton.backgroundColor = [SKColor blueColor];
    [_loadButton addTarget:self action:@selector(loadMaze) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_loadButton];
}

- (void)changeModes{
    movementMode = !movementMode;
    _toggleButton.backgroundColor = movementMode ? [SKColor greenColor] : [SKColor brownColor];
    
}

- (void) addGoalBlock{
    SKSpriteNode *goalBlock = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(16, 16)];
    goalBlock.position = CGPointMake(CGRectGetMaxX(self.frame)-10, 10);
    goalBlock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:goalBlock.size];
    goalBlock.physicsBody.contactTestBitMask = (1 << 2);
    
    [self addChild:goalBlock];
}

- (void)didBeginContact:(SKPhysicsContact *)contact{

    if (contact.bodyA.contactTestBitMask == contact.bodyB.contactTestBitMask) {
        SKScene* titleScene = [[MRGMazeMyScene alloc] initWithSize:self.size];
        SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:.5];
        [_toggleButton removeFromSuperview];
        [_sizeButton removeFromSuperview];
        [_saveButton removeFromSuperview];
        [_loadButton removeFromSuperview];
        [self.view presentScene:titleScene transition:doors];
    }

}

- (void)cycleSize{
    blockLength *= 2;
    if (blockLength / 2 > 16) {
        blockLength = 8;
    }
    [_sizeButton setFrame:CGRectMake(220, 16, blockLength, blockLength)];
    
}

- (void) saveMaze{
    if ([_thisMaze count] != 0)
        [[MRGMazeStore sharedStore] addMaze:[_thisMaze copy]];
    NSLog(@"Save pressed.");
}

- (void) loadMaze{
    NSLog(@"Load pressed.");
    for (SKSpriteNode *block in _thisMaze){
        [block removeFromParent];
    }
    [_thisMaze removeAllObjects];
    int totalNumMazes = [[[MRGMazeStore sharedStore] mazes] count];
    if (totalNumMazes == 0) return;
    int randomMazeIndex = rand()%totalNumMazes;
    _thisMaze = [[[[MRGMazeStore sharedStore] mazes] objectAtIndex:randomMazeIndex] mutableCopy];
    
    for (SKSpriteNode *block in _thisMaze){
        [self addChild:block];
    }
}

@end
