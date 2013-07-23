//
//  MazeScene.m
//  MRGMazeGame
//
//  Created by Matt Grossman on 7/22/13.
//  Copyright (c) 2013 Matt Grossman. All rights reserved.
//

#import "MazeScene.h"

@interface MazeScene (){
    SKSpriteNode *_person;
    SKSpriteNode *_wall;
    BOOL movementMode;
    int blockLength;
}
- (void)changeModes;
@property BOOL contentCreated;
@property UIButton *toggleButton;
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
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    movementMode = NO;
    blockLength = 16;
    
    
    
    
    _person = [self newPerson];
    _person.position = CGPointMake(blockLength,blockLength);
    [self createWalls];
    [self createToggleButton];
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
            if (_person.physicsBody.velocity.x > 10 || _person.physicsBody.velocity.y > 10) {
                _person.physicsBody.velocity.x = 10;
                _person.physicsBody.velocity.y = 10;
            }
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
    [self addChild:borders];
    
}

- (void)createToggleButton{
    _toggleButton = [[UIButton alloc] initWithFrame:CGRectMake(256,16, 16, 16)];
    _toggleButton.backgroundColor = [SKColor brownColor];
    [_toggleButton addTarget:self action:@selector(changeModes) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_toggleButton];
    
}

- (void)changeModes{
    movementMode = !movementMode;
    _toggleButton.backgroundColor = movementMode ? [SKColor greenColor] : [SKColor brownColor];
    
}

- (void) addGoalBlock{
    SKSpriteNode *goalBlock = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(16, 16)];
    goalBlock.position = CGPointMake(CGRectGetMaxX(self.frame)-10, 10);
    goalBlock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:goalBlock.size];
    goalBlock.physicsBody.contactTestBitMask = (1 << 0);
    
    [self addChild:goalBlock];
}

- (void)didBeginContact:(SKPhysicsContact *)contact{

}


@end
