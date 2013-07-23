//
//  MRGMazeStore.m
//  MRGMazeGame
//
//  Created by Morgan Tenney on 7/23/13.
//  Copyright (c) 2013 Matt Grossman. All rights reserved.
//

#import "MRGMazeStore.h"

@interface MRGMazeStore()
{
    NSMutableArray *_mazes;
}

@end

@implementation MRGMazeStore

@synthesize mazes = _mazes;

- (id) init{
    self = [super init];
    if (self){
        NSString *path = [self mazeArchivePath];
        _mazes = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_mazes)
            _mazes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self){
        _mazes = [aDecoder decodeObjectForKey:@"mazes"];
    }
    return self;
}

- (void) addMaze:(NSArray *)maze{
    [_mazes addObject:maze];
    NSLog(@"Maze added (in theory)");
}

+ (MRGMazeStore *) sharedStore{
    static MRGMazeStore *sharedStore;
    if (!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    return sharedStore;
}

+ (id) allocWithZone:(struct _NSZone *)zone{
    return [self sharedStore];
}

- (void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_mazes forKey:@"mazes"];
}

- (NSString *) mazeArchivePath{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = documentDirectories[0];
    return [path stringByAppendingPathComponent:@"mazes.archive"];
}

- (BOOL) saveMazes{
    NSString *path = [self mazeArchivePath];
    return [NSKeyedArchiver archiveRootObject:_mazes toFile:path];
}

@end
