/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */


#import "KKNotifyOnItemCountBehavior.h"

@implementation KKNotifyOnItemCountBehavior

-(void) didPickUpItemWithName:(NSString*)itemName count:(unsigned int)count
{
	if (count == _count && [itemName isEqualToString:_itemName])
	{
		[self postNotificationName:_notification];
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
	 KKNotifyOnItemCountBehavior* copy = [[super copyWithZone:zone] init];
	 copy->_notification = [_notification copy];
	 copy->_itemName = [_itemName copy];
	 copy->_count = _count;
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
