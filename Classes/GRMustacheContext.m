// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheProperty_private.h"
#import "GRMustacheNSUndefinedKeyExceptionGuard_private.h"
#import "GRMustacheTemplate_private.h"

static BOOL preventingNSUndefinedKeyExceptionAttack = NO;


@interface GRMustacheContext()
@property (nonatomic, retain) id object;
@property (nonatomic, retain) GRMustacheContext *parent;
@property (nonatomic) GRMustacheTemplateOptions options;
- (id)initWithObject:(id)theObject parent:(GRMustacheContext *)theParent options:(GRMustacheTemplateOptions)theOptions;
- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef;
@end


@implementation GRMustacheContext
@synthesize object;
@synthesize parent;
@synthesize options;

+ (void)preventNSUndefinedKeyExceptionAttack {
    preventingNSUndefinedKeyExceptionAttack = YES;
}

+ (id)contextWithObject:(id)object options:(GRMustacheTemplateOptions)options {
	if ([object isKindOfClass:[GRMustacheContext class]]) {
        NSAssert(((GRMustacheContext *)object).options == options, @"");
		return object;
	}
	return [[[self alloc] initWithObject:object parent:nil options:options] autorelease];
}

+ (id)contextWithObject:(id)object {
	if ([object isKindOfClass:[GRMustacheContext class]]) {
		return object;
	}
	return [[[self alloc] initWithObject:object parent:nil options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)contextWithObjects:(id)object, ... {
    va_list objectList;
    va_start(objectList, object);
    GRMustacheContext *result = [self contextWithObject:object options:GRMustacheDefaultTemplateOptions andObjectList:objectList];
    va_end(objectList);
    return result;
}

+ (id)contextWithObject:(id)object options:(GRMustacheTemplateOptions)options andObjectList:(va_list)objectList {
    GRMustacheContext *context = nil;
    if (object) {
        context = [GRMustacheContext contextWithObject:object options:options];
        id eachObject;
        va_list objectListCopy;
        va_copy(objectListCopy, objectList);
        while ((eachObject = va_arg(objectListCopy, id))) {
            context = [context contextByAddingObject:eachObject];
        }
        va_end(objectListCopy);
    } else {
        context = [self contextWithObject:nil options:options];
    }
    return context;
}

- (id)initWithObject:(id)theObject parent:(GRMustacheContext *)theParent options:(GRMustacheTemplateOptions)theOptions {
	if ((self = [self init])) {
		object = [theObject retain];
		parent = [theParent retain];
        options = theOptions;
	}
	return self;
}

- (GRMustacheContext *)contextByAddingObject:(id)theObject {
	return [[[GRMustacheContext alloc] initWithObject:theObject parent:self options:options] autorelease];
}

- (id)valueForKey:(NSString *)key
{
    NSString *implicitIteratorKey = @".";
    NSString *upContextKey = nil;
    NSString *keyComponentsSeparator = nil;

    if (options & GRMustacheTemplateOptionMustacheSpecCompatibility) {
        keyComponentsSeparator = @".";
        upContextKey = nil;
    } else {
        keyComponentsSeparator = @"/";
        upContextKey = @"..";
    }

	// fast path for implicitIteratorKey
    if ([implicitIteratorKey isEqualToString:key]) { // implicitIteratorKey may be nil
        return self.object;
    }
    
	// fast path for upContextKey
    if ([upContextKey isEqualToString:key]) {   // upContextKey may be nil
        if (self.parent == nil) {
            // went too far
            return nil;
        }
        return self.parent.object;
    }
    
    NSArray *components = nil;
    if (keyComponentsSeparator != nil) {
        components = [key componentsSeparatedByString:keyComponentsSeparator];
    }
	
	// fast path for single component
	if (components == nil || components.count == 1) {
		return [self valueForKeyComponent:key];
	}
	
    GRMustacheContext *context = self;
    
	// slow path for multiple components
	for (NSString *component in components) {
		if (component.length == 0) {
			continue;
		}
		if ([implicitIteratorKey isEqualToString:component]) { // implicitIteratorKey may be nil
			continue;
		}
		if ([upContextKey isEqualToString:component]) {   // upContextKey may be nil
			context = context.parent;
			if (context == nil) {
				// went too far
				return nil;
			}
			continue;
		}
		id value = [context valueForKeyComponent:component];
		if (value == nil) {
			return nil;
		}
		// further contexts are not in the context stack
		context = [GRMustacheContext contextWithObject:value options:options];
	}
	
	return context.object;
}

- (void)dealloc {
	[object release];
	[parent release];
	[super dealloc];
}

- (id)valueForKeyComponent:(NSString *)key {
	// value by selector
	
    SEL renderingSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Section:withContext:", key]);
    if ([object respondsToSelector:renderingSelector]) {
        // Avoid the "render" key to be triggered by GRMustacheHelper instances,
        // who implement the renderSection:withContext: selector.
        if (![object conformsToProtocol:@protocol(GRMustacheHelper)] || ![@"render" isEqualToString:key]) {
            return [GRMustacheSelectorHelper helperWithObject:object selector:renderingSelector];
        }
    }
	
	// value by KVC
	
	id value = nil;
	
    if (object) {
        @try {
            if (preventingNSUndefinedKeyExceptionAttack) {
                value = [GRMustacheNSUndefinedKeyExceptionGuard valueForKey:key inObject:object];
            } else {
                value = [object valueForKey:key];
            }
        }
        @catch (NSException *exception) {
            if (![[exception name] isEqualToString:NSUndefinedKeyException] ||
                [[exception userInfo] objectForKey:@"NSTargetObjectUserInfoKey"] != object ||
                ![[[exception userInfo] objectForKey:@"NSUnknownUserInfoKey"] isEqualToString:key])
            {
                // that's some exception we are not related to
                [exception raise];
            }
        }
    }
	
	// value interpretation
	
	if (value != nil) {
		CFBooleanRef booleanRef;
		if ([self shouldConsiderObjectValue:value forKey:key asBoolean:&booleanRef]) {
			return (id)booleanRef;
		}
		return value;
	}
	
	// parent value
	
	if (parent == nil) { return nil; }
	return [parent valueForKeyComponent:key];
}

- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef {
	if ((CFBooleanRef)value == kCFBooleanTrue ||
		(CFBooleanRef)value == kCFBooleanFalse)
	{
		if (outBooleanRef) {
			*outBooleanRef = (CFBooleanRef)value;
		}
		return YES;
	}
	
	if ([value isKindOfClass:[NSNumber class]] &&
		![GRMustache strictBooleanMode] &&
		[GRMustacheProperty class:[object class] hasBOOLPropertyNamed:key])
	{
		if (outBooleanRef) {
			*outBooleanRef = [(NSNumber *)value boolValue] ? kCFBooleanTrue : kCFBooleanFalse;
		}
		return YES;
	}
	
	return NO;
}

@end

