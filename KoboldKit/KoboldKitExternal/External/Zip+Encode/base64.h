/*
 base64.* is in the public domain.
 
 The files were modified for and bundled with cocos2d-iphone.
 Therefore the cocos2d-iphone license is reproduced below.
 
 
 cocos2d for iPhone: http://www.cocos2d-iphone.org
 
 Copyright (c) 2008-2011 - Ricardo Quesada and contributors
 Copyright (c) 2011-2012 - Zynga Inc. and contributors
 (see each file to see the different copyright owners)
 
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#ifndef __CC_BASE64_DECODE_H
#define __CC_BASE64_DECODE_H

#ifdef __cplusplus
extern "C" {
#endif


/** @file
   base64 helper functions
 */

/**
 * Decodes a 64base encoded memory. The decoded memory is
 * expected to be freed by the caller.
 *
 * @returns the length of the out buffer
 *
   @since v0.8.1
 */
int base64Decode(unsigned char* in, unsigned int inLength, unsigned char** out);

#ifdef __cplusplus
}
#endif

#endif // __CC_BASE64_DECODE_H
