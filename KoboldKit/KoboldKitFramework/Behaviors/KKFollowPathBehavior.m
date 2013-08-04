//
//  KKFollowPathBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 04.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKFollowPathBehavior.h"
#import "KKTilemapObjectLayerNode.h"
#import "KKTilemapNode.h"
#import "KKTilemapObject.h"

typedef struct
{
	CGPoint lastPoint;
	CGFloat length;
} KKPathLengthData;

void calculatePathLength(void* info, const CGPathElement* element)
{
	KKPathLengthData* pathLengthData = (KKPathLengthData*)info;
	
	switch (element->type)
	{
		case kCGPathElementMoveToPoint:
			pathLengthData->lastPoint = element->points[0];
			pathLengthData->length = 0.0;
			break;
		case kCGPathElementAddCurveToPoint:
		case kCGPathElementAddLineToPoint:
		case kCGPathElementCloseSubpath:
			pathLengthData->length += ccpLength(ccpSub(pathLengthData->lastPoint, element->points[0]));
			break;
			
		default:
		case kCGPathElementAddQuadCurveToPoint:
			[NSException raise:NSInternalInconsistencyException format:@"can't calculate path length, unsupported element type %u (curve?)", element->type];
			break;
	}
}


@implementation KKFollowPathBehavior

-(void) didJoinController
{
	[self startFollowPath];
}

-(void) didLeaveController
{
	[self.node removeActionForKey:NSStringFromClass([self class])];
}

-(void) startFollowPath
{
	// assume the parent to be the object layer
	KKTilemapObjectLayerNode* objectLayerNode = (KKTilemapObjectLayerNode*)self.node.parent;
	NSAssert2([objectLayerNode isKindOfClass:[KKTilemapObjectLayerNode class]],
			  @"behavior node's parent isn't a KKTilemapObjectLayerNode but a %@ (%@)",
			  NSStringFromClass([objectLayerNode class]), objectLayerNode);
	
	KKTilemapNode* tilemapNode = objectLayerNode.tilemapNode;
	KKTilemapObject* object = [tilemapNode objectNamed:_pathName];
	NSAssert1(object, @"No path object named '%@' found.", _pathName);
	
	if (object)
	{
		BOOL isLine = object.objectType == KKTilemapObjectTypePolyLine;
		if (_relativeToObject == NO)
		{
			self.node.position = object.position;
		}
		
		CGPoint startPosition = self.node.position;
		
		KKPathLengthData pathLengthData;
		CGPathRef path = (__bridge CGPathRef)[object path];
		CGPathApply(path, &pathLengthData, calculatePathLength);
				
		CGFloat duration = pathLengthData.length / _moveSpeed;
		
		SKAction* followPath = [SKAction followPath:path asOffset:YES orientToPath:_orientToPath duration:duration];
		SKAction* runBlock = [SKAction runBlock:^{
			// reset node to start position, otherwise it'll "drift off"
			self.node.position = startPosition;
		}];
		
		NSMutableArray* sequenceActions = [NSMutableArray arrayWithCapacity:6];
		if (_initialWaitDuration > 0.0)
		{
			[sequenceActions addObject:[SKAction waitForDuration:_initialWaitDuration]];
		}
		
		if (isLine)
		{
			if (_repeatCount == 1)
			{
				[sequenceActions addObject:followPath];
			}
			else
			{
				[sequenceActions addObjectsFromArray:@[runBlock, followPath, [followPath reversedAction]]];
			}
		}
		else
		{
			[sequenceActions addObjectsFromArray:@[followPath, runBlock]];
		}
		
		SKAction* sequence = [SKAction sequence:sequenceActions];
		if (_repeatCount == 0)
		{
			sequence = [SKAction repeatActionForever:sequence];
		}
		else if (_repeatCount >= 2)
		{
			sequence = [SKAction repeatAction:sequence count:_repeatCount - 1];
		}
		
		[self.node runAction:sequence withKey:NSStringFromClass([self class])];
	}
}


#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

/*
 static NSString* const ArchiveKeyForOtherNode = @"otherNode";
 
 -(id) initWithCoder:(NSCoder*)decoder
 {
 self = [super init];
 if (self)
 {
 _target = [decoder decodeObjectForKey:ArchiveKeyForOtherNode];
 _positionOffset = [decoder decodeCGPointForKey:ArchiveKeyForPositionOffset];
 _positionMultiplier = [decoder decodeCGPointForKey:ArchiveKeyForPositionMultiplier];
 }
 return self;
 }
 
 -(void) encodeWithCoder:(NSCoder*)encoder
 {
 [encoder encodeObject:_target forKey:ArchiveKeyForOtherNode];
 [encoder encodeCGPoint:_positionOffset forKey:ArchiveKeyForPositionOffset];
 [encoder encodeCGPoint:_positionMultiplier forKey:ArchiveKeyForPositionMultiplier];
 }
 */
#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKFollowPathBehavior* copy = [[super copyWithZone:zone] init];
	copy->_pathName = [_pathName copy];
	copy->_moveSpeed = _moveSpeed;
	copy->_relativeToObject = _relativeToObject;
	copy->_orientToPath = _orientToPath;
	return copy;
}

/*
 #pragma mark Equality
 
 -(BOOL) isEqualToBehavior:(KKBehavior*)behavior
 {
 if ([self isMemberOfClass:[behavior class]] == NO)
 return NO;
 return NO;
 }
 */

@end
