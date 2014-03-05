// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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

// Inspired by https://github.com/fotonauts/handlebars-objc/blob/master/src/handlebars-objc/astVisitors/HBAstEvaluationVisitor.m

typedef struct {
    BOOL usingCappedString;
    NSUInteger cappedLength;
    CFMutableStringRef string;
} GRMustacheBuffer;

static inline GRMustacheBuffer GRMustacheBufferCreate(NSUInteger capacity)
{
    return (GRMustacheBuffer){
        .usingCappedString = YES,
        .cappedLength = capacity,
        .string = CFStringCreateMutable(0, capacity),
    };
}

static inline void GRMustacheBufferAppendString(GRMustacheBuffer *buffer, CFStringRef string)
{
    if (buffer->usingCappedString && (CFStringGetLength(buffer->string) + CFStringGetLength(string) > buffer->cappedLength)) {
        CFMutableStringRef newBuffer = CFStringCreateMutableCopy(NULL, 0, buffer->string);
        CFRelease(buffer->string);
        buffer->string = newBuffer;
        buffer->usingCappedString = NO;
    }
    CFStringAppend(buffer->string, string);
}

static inline void GRMustacheBufferAppendCharacters(GRMustacheBuffer *buffer, const UniChar *chars, NSUInteger numChars)
{
    if (buffer->usingCappedString && (CFStringGetLength(buffer->string) + numChars > buffer->cappedLength)) {
        CFMutableStringRef newBuffer = CFStringCreateMutableCopy(NULL, 0, buffer->string);
        CFRelease(buffer->string);
        buffer->string = newBuffer;
        buffer->usingCappedString = NO;
    }
    CFStringAppendCharacters(buffer->string, chars, numChars);
}

static inline CFStringRef GRMustacheBufferGetString(GRMustacheBuffer *buffer)
{
    CFRetain(buffer->string);
    CFAutorelease(buffer->string);
    return buffer->string;
}

static inline void GRMustacheBufferRelease(GRMustacheBuffer *buffer)
{
    CFRelease(buffer->string);
}

static inline CFStringRef GRMustacheBufferGetStringAndRelease(GRMustacheBuffer *buffer)
{
    CFAutorelease(buffer->string);
    return buffer->string;
}
