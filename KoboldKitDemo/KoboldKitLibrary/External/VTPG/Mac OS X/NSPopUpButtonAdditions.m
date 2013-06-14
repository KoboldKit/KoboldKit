#import "NSPopUpButtonAdditions.h"


@implementation NSPopUpButton (VTPGAdditions)

-(void) selectItemWithRepresentedObject:(id)representedObject;
{
	NSInteger itemIndex = [self indexOfItemWithRepresentedObject:representedObject];
	if (itemIndex >= 0)
	{
		[self selectItemAtIndex:itemIndex];
	}
}

@end
