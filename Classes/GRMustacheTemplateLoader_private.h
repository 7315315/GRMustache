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

#import "GRMustacheEnvironment.h"
#import <Foundation/Foundation.h>

@class GRMustacheTemplate;

@interface GRMustacheTemplateLoader: NSObject {
@private
	NSString *extension;
	NSStringEncoding encoding;
	NSMutableDictionary *templatesById;
}
@property (nonatomic, readonly, copy) NSString *extension;
@property (nonatomic, readonly) NSStringEncoding encoding;

+ (id)templateLoaderWithCurrentWorkingDirectory;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)templateLoaderWithBaseURL:(NSURL *)url;
#endif

+ (id)templateLoaderWithBasePath:(NSString *)path __attribute__((deprecated));

+ (id)templateLoaderWithDirectory:(NSString *)path;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext;
#endif

+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext __attribute__((deprecated));

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext encoding:(NSStringEncoding)encoding;
#endif

+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding __attribute__((deprecated));

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;

+ (id)templateLoaderWithBundle:(NSBundle *)bundle;

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext;

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding;

- (id)initWithExtension:(NSString *)ext encoding:(NSStringEncoding)encoding;

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError;

- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError;

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name relativeToTemplateId:(id)templateId error:(NSError **)outError;

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId;

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError;

- (void)setTemplate:(GRMustacheTemplate *)template forTemplateId:(id)templateId;
@end
