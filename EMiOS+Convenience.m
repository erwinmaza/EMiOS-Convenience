//  EMiOS+Convenience.m
//  Created by erwin on 12/3/12.

/*
 
 Copyright (c) 2012 eMaza Mobile. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */


#import "EMiOS+Convenience.h"

#pragma mark NSObject
@implementation NSObject (EMiOS_Convenience)

- (void*)performSelector:(SEL)selector withValue:(void*)value afterDelay:(NSTimeInterval*)delay {
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
	[invocation setSelector:selector];
	[invocation setTarget:self];
	[invocation setArgument:value atIndex:2];
	
	[invocation invoke];
	
	NSUInteger length = [[invocation methodSignature] methodReturnLength];
	
	// If method is non-void:
	if (length > 0) {
		void *buffer = (void*)malloc(length);
		[invocation getReturnValue:buffer];
		return buffer;
	}
	
	// If method is void:
	return NULL;
}

@end

#pragma mark NSNumber
@implementation NSNumber (EMiOS_Convenience)

- (NSNumber*)add:(int)value {
	return [NSNumber numberWithInt:[self intValue] + value];
}

@end

#pragma mark NSString
@implementation NSString (EMiOS_Convenience)

- (NSString*)fullyEncodedStringWithEncoding:(NSStringEncoding)encoding {
	return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, (CFStringRef)@";/?:@&=$+{}<>,[] #%'*!", CFStringConvertNSStringEncodingToEncoding(encoding));
}

- (NSString*)fullyEncodedString {
	return [self fullyEncodedStringWithEncoding:kCFStringEncodingUTF8];
}

- (UIColor*)toColor {
	// The string should be something like "UIDeviceRGBColorSpace 0.5 0 0.25 1
	UIColor *color = [UIColor blackColor];
	@try {
		NSArray *values = [NSArray arrayWithArray:[self componentsSeparatedByString:@" "]];
		CGFloat red = [[values objectAtIndex:1] floatValue];
		CGFloat green = [[values objectAtIndex:2] floatValue];
		CGFloat blue = [[values objectAtIndex:3] floatValue];
		CGFloat alpha = [[values objectAtIndex:4] floatValue];
		color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
		values = nil;
	}
	@catch (NSException * e) {
		NSLog(@"Failed to convert '%@' to a color", self);
	}
	return color;
}

- (NSDate*)toDate {
	NSDate *date = [NSDate date];
	
	@try {
		int interval = [self intValue];
		date = [NSDate dateWithTimeIntervalSince1970:interval];
	}
	@catch (NSException * e) {
		NSLog(@"Failed to convert '%@' to a date", self);
	}
	
	return date;
}

- (NSString*)stringBySanitizingUserContent {
	return [[self stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\\n"];
}

@end

#pragma mark DateFormatting
@implementation NSDate (EMiOS_Convenience)

- (NSString*)toUserFormat {
	NSString *formattedDate = @"";
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.doesRelativeDateFormatting = TRUE;
	[formatter setDateFormat:kUserDateFormat];
	
	formattedDate = [formatter stringFromDate:self];
	return formattedDate;
}

- (NSString*)toUserShortFormat {
	NSString *formattedDate = @"";
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:kUserDateShortFormat];
	
	formattedDate = [formatter stringFromDate:self];
	return formattedDate;
}

- (NSString*)toServerFormat {
	NSString *formattedDate = @"";
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];			// kISO8061DateFormat (aws sdk)
	
	formattedDate = [formatter stringFromDate:self];
	return formattedDate;
}

@end

#pragma mark NSDictionary
@implementation NSDictionary (EMiOS_Convenience)

- (NSString*)stringForKey:(NSString*)key {
	NSString *string = @"";
	
	@try {
		if ([[self valueForKey:key] isEqual:[NSNull null]]) {
			NSLog(@"ERROR: null value for key: %@", key);
			return string;
		}
		if ([self valueForKey:key]) {
			string = (NSString*)[self valueForKey:key];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"ERROR: could not get string for key: %@", key);
	}
	return string;
}

- (NSNumber*)numberForKey:(NSString*)key {
	NSNumber *number = NULL;
	@try {
		if ([self valueForKey:key]) {
			number = (NSNumber*)[self valueForKey:key];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"ERROR: could not get number for key: %@", key);
	}
	return number;
}

- (NSDate*)dateForDateKey:(NSString*)key {
	NSDate *date = [NSDate date];
	@try {
		NSString *string = @"";
		if ([self valueForKey:key]) {
			string = (NSString*)[self valueForKey:key];
			date = [string toDate];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"ERROR: could not get date for key: %@", key);
	}
	return date;
}

- (int)intForKey:(NSString*)key {
	int value = 0;
	@try {
		if ([self valueForKey:key]) {
			value = [[self valueForKey:key] intValue];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"ERROR: could not get integer for key: %@", key);
	}
	return value;
}

- (BOOL)boolForKey:(NSString*)key {
	BOOL value = FALSE;
	@try {
		if ([self valueForKey:key]) {
			value = [[self valueForKey:key] boolValue];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"ERROR: could not get BOOL for key: %@", key);
	}
	return value;
}

@end

#pragma mark NSSet
@implementation NSSet (EMiOS_Convenience)

- (NSMutableArray*)toMutableArray {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
	for (id thing in self) {
		[array addObject:thing];
	}
	return array;
}

- (NSArray*)toArray {
	return [NSArray arrayWithArray:[self toMutableArray]];
}

@end

#pragma mark NSOrderedSet
@implementation NSOrderedSet (EMiOS_Convenience)

- (NSUInteger)loopedIndexForProposedIndex:(NSUInteger)index {
	
	if (index < [self count]) return index;
	
	double intpart;
	modf((CGFloat)index / (CGFloat)[self count], &intpart);
	index -= [self count] * intpart;
	
	return index;
}

@end

#pragma mark Array
@implementation NSArray (EMiOS_Convenience)

- (id)loopedObjectAtProposedIndex:(NSUInteger)index {
	if (index < [self count]) return [self objectAtIndex:index];
	return [self objectAtIndex:[self loopedIndexForProposedIndex:index]];
}

- (NSUInteger)loopedIndexForProposedIndex:(NSUInteger)index {
	
	if (index < [self count]) return index;
	
	double intpart;
	modf((CGFloat)index / (CGFloat)[self count], &intpart);
	index -= [self count] * intpart;
	
	return index;
}

- (id)randomObject {
	NSUInteger count = [self count];
	if (count == 0) return nil;
	NSUInteger n = arc4random_uniform((uint)count);
	return [self objectAtIndex:n];
}

@end

#pragma mark Array Shuffling
@implementation NSMutableArray (EMiOS_Convenience)

- (void)shuffle {
	NSUInteger count = [self count];
	if (count == 0) return;
	for (NSUInteger i = count - 1; i > 0; i--) {
		NSUInteger n = arc4random_uniform((uint)i + 1);
		[self exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
}

@end

#pragma mark UIImage
@implementation UIImage (EMiOS_Convenience)

- (UIImage*)antiAliased {
	CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
	UIGraphicsBeginImageContextWithOptions(imageRect.size, TRUE, 0.0);
	[self drawInRect:CGRectMake(1, 1, self.size.width - 2, self.size.height - 2)];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}

@end

#pragma mark UIView
@implementation UIView (EMiOS_Convenience)

- (void)centerInContainer {
	CGRect selfFrame = self.frame;
	CGRect superFrame = self.superview.frame;
	
	selfFrame.origin.y = (CGFloat)floor((superFrame.size.height - selfFrame.size.height) / 2);
	selfFrame.origin.x = (CGFloat)floor((superFrame.size.width - selfFrame.size.width) / 2);
	self.frame = selfFrame;
}

- (void)centerVerticallyInContainer {
	CGRect selfFrame = self.frame;
	CGRect superFrame = self.superview.frame;
	
	selfFrame.origin.y = (CGFloat)floor((superFrame.size.height - selfFrame.size.height) / 2);
	self.frame = selfFrame;
}

- (void)centerHorizontallyInContainer {
	CGRect selfFrame = self.frame;
	CGRect superFrame = self.superview.frame;
	
	selfFrame.origin.x = (CGFloat)floor((superFrame.size.width - selfFrame.size.width) / 2);
	self.frame = selfFrame;
}

- (void)addShadow {
	self.clipsToBounds = FALSE;
	self.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
	self.layer.shadowOffset = CGSizeMake(3, 2);
	self.layer.shadowOpacity = 0.85f;
	self.layer.shadowRadius = 2;
}

- (void)roundCorners {
	self.clipsToBounds = TRUE;
	self.layer.cornerRadius = 5;
}

- (void)removeSubviews {
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
}

- (void)removeSubviewsOfClass:(Class)class {
	for (UIView *view in self.subviews) {
		if ([view isMemberOfClass:class]) [view removeFromSuperview];
	}
}

- (void)setFrameAttribute:(enumFrameAttribute)attribute value:(int)value {
	CGRect myFrame = self.frame;
	switch (attribute) {
		case frameAttributeX: {
			myFrame.origin.x = value;
			break;
		} case frameAttributeY: {
			myFrame.origin.y = value;
			break;
		} case frameAttributeWidth: {
			myFrame.size.width = value;
			break;
		} case frameAttributeHeight: {
			myFrame.size.height = value;
			break;
		}
	}
	self.frame = myFrame;
}

- (NSValue*)absoluteCoordsInTopLevelView:(UIView*)topView {
	CGPoint center = [topView convertPoint:self.center fromView:self.superview];
	return [NSValue valueWithCGPoint:center];
}

- (UIImage*)snapshot {
	//	LogMethod
	UIGraphicsBeginImageContextWithOptions(self.frame.size, FALSE, 0.0f);
	if (CATransform3DIsIdentity(self.layer.transform)) {
		[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	} else {
		[self.layer.superlayer renderInContext:UIGraphicsGetCurrentContext()];
	}
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (UIImage*)snapshotOfViewHierarchy {
	//	LogMethod
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, UIScreen.mainScreen.scale);
	[self drawViewHierarchyInRect:self.bounds afterScreenUpdates:TRUE];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

- (UIImage*)snapshotOfWindow {
	//	LogMethod

	UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, YES, UIScreen.mainScreen.scale);
	[self.window drawViewHierarchyInRect:self.window.bounds afterScreenUpdates:NO];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	UIInterfaceOrientation interfaceOrientation = self.window.rootViewController.interfaceOrientation;
	if (interfaceOrientation != UIInterfaceOrientationPortrait) {
	
		CGSize size = self.window.bounds.size;
		CGSize newSize = CGSizeMake(size.height, size.width);
	
		UIImageOrientation newOrientation = UIImageOrientationDown;
		if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) newOrientation = UIImageOrientationRight;
		if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) newOrientation = UIImageOrientationLeft;

		UIImage *image2 = [[UIImage alloc] initWithCGImage:image.CGImage scale:UIScreen.mainScreen.scale orientation:newOrientation];

		UIGraphicsBeginImageContextWithOptions(newSize, YES, UIScreen.mainScreen.scale);
		[image2 drawAtPoint:CGPointZero];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}

	return image;
}

@end

#pragma mark UIViewController
@implementation UIViewController (EMiOS_Convenience)

- (void)forcePopoverSize {
	
	if ([self respondsToSelector:NSSelectorFromString(@"setPreferredContentSize:")]) {
		CGSize currentSetSizeForPopover = [[self valueForKey:@"preferredContentSize"] CGSizeValue];
		CGSize tmpSize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
		[self setValue:[NSValue valueWithCGSize:tmpSize] forKey:@"preferredContentSize"];
		[self setValue:[NSValue valueWithCGSize:currentSetSizeForPopover] forKey:@"preferredContentSize"];
	} else {
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		CGSize currentSetSizeForPopover = self.contentSizeForViewInPopover;
		CGSize tmpSize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
		self.contentSizeForViewInPopover = tmpSize;
		self.contentSizeForViewInPopover = currentSetSizeForPopover;
#pragma clang diagnostic warning "-Wdeprecated-declarations"
	}
}

@end

#pragma mark UITextField
@implementation UITextField (EMiOS_Convenience)

- (NSString*)sanitized {
	NSString *sanitized = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	sanitized = [sanitized stringByReplacingOccurrencesOfString:@"'" withString:@""];
	return sanitized;
}

@end

#pragma mark UIColor
@implementation UIColor (EMiOS_Convenience)

- (NSString*)toString {
	return [NSString stringWithFormat:@"%@", self];
}

@end

#pragma mark More Device Info

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice (EMiOS_Convenience)

- (NSString*)platform {
	int mib[2];
	size_t len;
	char *machine;
	
	mib[0] = CTL_HW;
	mib[1] = HW_MACHINE;
	sysctl(mib, 2, NULL, &len, NULL, 0);
	machine = malloc(len);
	sysctl(mib, 2, machine, &len, NULL, 0);
	
	NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
	free(machine);
	return platform;
}

@end

#pragma mark UserDefaults
@implementation NSUserDefaults (EMiOS_Convenience)

- (NSString*)stringForKey:(NSString*)key default:(NSString*)defaultValue {
	NSString *value = [self stringForKey:key];
	return ([value length] > 0)? value : defaultValue;
}

- (NSInteger)enumForKey:(NSString*)key default:(NSInteger)defaultValue {
	NSInteger value = [self integerForKey:key];
	return (value > 0)? value : defaultValue;
}

@end


