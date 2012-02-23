// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
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

#import <Foundation/Foundation.h>
@class GRMustacheSection;
@class GRMustacheContext;

@protocol GRMustacheHelper<NSObject>
@required
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context;
@end

@interface GRMustacheSelectorHelper: NSObject<GRMustacheHelper> {
    SEL _renderingSelector;
    id _object;
}
+ (id)helperWithObject:(id)object selector:(SEL)renderingSelector;
@end

#if GRMUSTACHE_BLOCKS_AVAILABLE
@interface GRMustacheBlockHelper: NSObject<GRMustacheHelper> {
@private
    NSString *(^_block)(GRMustacheSection* section, id context);
}
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section, id context))block;
@end

typedef NSString *(^GRMustacheRenderingBlock)(GRMustacheSection*, GRMustacheContext*);
id GRMustacheLambdaBlockMake(GRMustacheRenderingBlock block) UNAVAILABLE_ATTRIBUTE; // privately unavailable deprecated public method

typedef NSString *(^GRMustacheRenderer)(id object);
typedef id GRMustacheLambda;
GRMustacheLambda GRMustacheLambdaMake(NSString *(^block)(NSString *(^)(id object), id, NSString *)) UNAVAILABLE_ATTRIBUTE; // privately unavailable deprecated public method
#endif