//
//  MRGMazeStore.h
//  MRGMazeGame
//
//  Created by Morgan Tenney on 7/23/13.
//  Copyright (c) 2013 Matt Grossman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRGMazeStore : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *mazes;

+ (MRGMazeStore *) sharedStore;

- (void) addMaze: (NSArray *) maze;

- (NSString *) mazeArchivePath;
- (BOOL) saveMazes;

@end
