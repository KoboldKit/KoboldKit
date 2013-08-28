/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import <Foundation/Foundation.h>

/** NSFileManager category methods for Kobold Kit */
@interface NSBundle (KoboldKit)

/** @name Locating Files and Paths */

/** @returns The absolute path to the file or nil if the file could not be found.
 @param file A filename.
 @returns The path to the file or nil if the file couldn't be found in the bundle. */
+(NSString*) pathForBundleFile:(NSString*)file;

/** @returns The absolute path to the file.
 @param file A filename.
 @returns The path to the file or nil if the file couldn't be found in the user's documents directory. */
+(NSString*) pathForDocumentsFile:(NSString*)file;

/** @returns The absolute path to the file.
 @param file A filename.
 @returns The path to the file or nil if the file couldn't be found in the app support directory. */
//+(NSString*) pathForAppSupportFile:(NSString*)file;

/** @returns The absolute path to the file.
 @param file A filename.
 @returns The path to the file or nil if the file couldn't be found in the user's library directory. */
//+(NSString*) pathForLibraryFile:(NSString*)file;

/** Searches for the file in the given NSSearchPathDirectory and returns the absolute path to the file if it was found.
 @returns The absolute path to the file, or nil if the file could not be found.
 @param file A filename.
 @param directory The NSSearchPathDirectory constant where to look for the file.
 @returns The path to the file or nil if the file couldn't be found in the directory. */
+(NSString*) pathForFile:(NSString*)file inDirectory:(NSSearchPathDirectory)directory;

/** Searches for the file in the documents directory first, before trying the bundle and returns the absolute path
 to the file where it was first found.
 @param file A filename.
 @returns The absolute path to the file, or nil if the file could not be found in any of the searched directories. */
+(NSString*) pathForFile:(NSString*)file;

/** @returns The full path to the documents directory. */
+(NSString*) pathToDocumentsDirectory;

@end
