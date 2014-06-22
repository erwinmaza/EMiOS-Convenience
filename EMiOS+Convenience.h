//  EMiOS+Convenience.h
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


#define kUserDateLongFormat				@"EE MMM dd, YYYY h:mm a"
#define kUserDateFormat					@"MMM d, YYYY"
#define kUserDateShortFormat			@"MMM d"

#pragma mark Base Types ************
@interface NSObject (EMiOS_Convenience)

- (void*)performSelector:(SEL)selector withValue:(void*)value afterDelay:(NSTimeInterval*)delay;

@end


@interface NSNumber (EMiOS_Convenience)

- (NSNumber*)add:(int)value;

@end


@interface NSDate (EMiOS_Convenience)

- (NSString*)toUserFormat;
- (NSString*)toUserShortFormat;
- (NSString*)toServerFormat;

@end

@interface NSString (EMiOS_Convenience)

- (NSString*)fullyEncodedStringWithEncoding:(NSStringEncoding)encoding;
- (NSString*)fullyEncodedString;
- (UIColor*)toColor;
- (NSDate*)toDate;
- (NSString*)stringBySanitizingUserContent;

@end


@interface NSDictionary (EMiOS_Convenience)

- (NSString*)stringForKey:(NSString*)key;
- (NSNumber*)numberForKey:(NSString*)key;
- (NSDate*)dateForDateKey:(NSString*)key;
- (int)intForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;

@end

@interface NSSet (EMiOS_Convenience)

- (NSMutableArray*)toMutableArray;
- (NSArray*)toArray;

@end

@interface NSOrderedSet (EMiOS_Convenience)

- (NSUInteger)loopedIndexForProposedIndex:(NSUInteger)index;
	
@end
	
@interface NSArray (EMiOS_Convenience)

- (id)loopedObjectAtProposedIndex:(NSUInteger)index;
- (NSUInteger)loopedIndexForProposedIndex:(NSUInteger)index;
- (id)randomObject;

@end

@interface NSMutableArray (EMiOS_Convenience)

- (void)shuffle;

@end

#pragma mark UI Kit ************
@interface UIImage (EMiOS_Convenience)

	- (UIImage*)antiAliased;

@end

@interface UIView (EMiOS_Convenience)

	typedef NS_ENUM(NSInteger, enumFrameAttribute) {
		frameAttributeX			 = 1,
		frameAttributeY			 = 2,
		frameAttributeWidth		 = 3,
		frameAttributeHeight	 = 4
	};

	- (void)centerVerticallyInContainer;
	- (void)centerHorizontallyInContainer;
	- (void)addShadow;
	- (void)roundCorners;
	- (void)removeSubviews;
	- (void)removeSubviewsOfClass:(Class)aClass;
 	- (void)setFrameAttribute:(enumFrameAttribute)attribute value:(int)value;
	- (NSValue*)absoluteCoordsInTopLevelView:(UIView*)topView;
 	- (UIImage*)snapshot;
	- (UIImage*)snapshotOfViewHierarchy;
	- (UIImage*)snapshotOfWindow;

@end


@interface UIViewController (EMiOS_Convenience)

	- (void)forcePopoverSize;

@end


@interface UITextField (EMiOS_Convenience)

	- (NSString*)sanitized;

@end


@interface UIColor (EMiOS_Convenience)

	- (NSString*)toString;

@end


@interface UIDevice (EMiOS_Convenience)

	- (NSString*)platform;

@end

#pragma mark System Objects ************
@interface NSUserDefaults (EMiOS_Convenience)

- (NSString*)stringForKey:(NSString*)key default:(NSString*)defaultValue;
- (NSInteger)enumForKey:(NSString*)key default:(NSInteger)defaultValue;

@end



