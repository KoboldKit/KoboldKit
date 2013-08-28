/*
 ZipUtils.* is from the zlib project.
 
 The files were modified for and bundled with cocos2d-iphone.
 Therefore both zlib and cocos2d-iphone licenses are reproduced below.
 
 
 zlib.h -- interface of the 'zlib' general purpose compression library
 version 1.2.8, April 28th, 2013
 
 Copyright (C) 1995-2013 Jean-loup Gailly and Mark Adler
 
 This software is provided 'as-is', without any express or implied
 warranty.  In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not
 claim that you wrote the original software. If you use this software
 in a product, an acknowledgment in the product documentation would be
 appreciated but is not required.
 2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original software.
 3. This notice may not be removed or altered from any source distribution.
 
 Jean-loup Gailly        Mark Adler
 jloup@gzip.org          madler@alumni.caltech.edu
 
 
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

#ifndef __CC_ZIP_UTILS_H
#define __CC_ZIP_UTILS_H

#import <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     * Set the TexturePacker encryption key
     *
     * If your key used to encrypt the pvr.ccz file is
     * aaaaaaaabbbbbbbbccccccccdddddddd 
     * you have to call this function 4 times:
     * caw_setkey_part(0, 0xaaaaaaaa);
     * caw_setkey_part(1, 0xbbbbbbbb);
     * caw_setkey_part(2, 0xcccccccc);
     * caw_setkey_part(3, 0xdddddddd);
     *
     * Distribute the call accross some files but make sure
     * to call all of the parts *before* loading the first
     * spritesheet.
     *
     * @param index part of the key [0..3]
     * @param value value of the key part
     */
    void caw_setkey_part(int index, uint32_t value);

	/* XXX: pragma pack ??? */
	/** @struct CCZHeader
	 */
	struct CCZHeader {
		uint8_t			sig[4];				// signature. Should be 'CCZ!' 4 bytes
		uint16_t		compression_type;	// should 0
		uint16_t		version;			// should be 2 (although version type==1 is also supported)
		uint32_t		reserved;			// Reserverd for users.
		uint32_t		len;				// size of the uncompressed file
	};

	enum {
		CCZ_COMPRESSION_ZLIB,				// zlib format.
		CCZ_COMPRESSION_BZIP2,				// bzip2 format (not supported yet)
		CCZ_COMPRESSION_GZIP,				// gzip format (not supported yet)
		CCZ_COMPRESSION_NONE,				// plain (not supported yet)
	};

/** @file
 * Zip helper functions
 */

/**
 * Inflates either zlib or gzip deflated memory. The inflated memory is
 * expected to be freed by the caller.
 *
 * It will allocate 256k for the destination buffer. If it is not enought it will multiply the previous buffer size per 2, until there is enough memory.
 * @returns the length of the deflated buffer
 *
 @since v0.8.1
 */
int ccInflateMemory(unsigned char *in, unsigned int inLength, unsigned char **out);

/**
 * Inflates either zlib or gzip deflated memory. The inflated memory is
 * expected to be freed by the caller.
 *
 * outLenghtHint is assumed to be the needed room to allocate the inflated buffer.
 *
 * @returns the length of the deflated buffer
 *
 @since v1.0.0
 */
int ccInflateMemoryWithHint(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int outLenghtHint );


/** inflates a GZip file into memory
 *
 * @returns the length of the deflated buffer
 *
 * @since v0.99.5
 */
int ccInflateGZipFile(const char *filename, unsigned char **out);

/** inflates a CCZ file into memory
 *
 * @returns the length of the deflated buffer
 *
 * @since v0.99.5
 */
int ccInflateCCZFile(const char *filename, unsigned char **out);

/** loads a file into memory. The caller is responsible for releasing the out buffer.
	 
 @returns the size of the allocated buffer */
NSInteger ccLoadFileIntoMemory(const char* filename, unsigned char** out);
	

#ifdef __cplusplus
}
#endif

#endif // __CC_ZIP_UTILS_H
