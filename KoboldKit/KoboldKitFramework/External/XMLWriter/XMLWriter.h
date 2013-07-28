/***************************************************************************
 *
 * XMLWriter: An XML stream writer for iOS.
 * This file is part of the XSWI library - http://code.google.com/p/xswi/
 *
 * Copyright (C) 2010 by Thomas Rørvik Skjølberg
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ****************************************************************************/

#import <Foundation/Foundation.h>

/** xml stream writer protocol, see: https://code.google.com/p/xswi/w/list */
@protocol XMLStreamWriter

/** .. */
-(void) writeStartDocument;
/** ..
 @param version The XML version string. */
-(void) writeStartDocumentWithVersion:(NSString*)version;
/** @param encoding The XML encoding as string.
 @param version The XML version string. */
-(void) writeStartDocumentWithEncoding:(NSString*)encoding version:(NSString*)version;

/** @param localName The name of the element. */
-(void) writeStartElement:(NSString*)localName;

/** .. */
-(void) writeEndElement;  // automatic end element (mirrors previous start element at the same level)
/** @param localName The name of the element. */
-(void) writeEndElement:(NSString*)localName;

/** @param localName The name of the element. */
-(void) writeEmptyElement:(NSString*)localName;

/** .. */
-(void) writeEndDocument; // write any remaining end elements

/** @param localName The name of the attribute.
 @param value The attribute value. */
-(void) writeAttribute:(NSString*)localName value:(NSString*)value;

/** @param text The text to write. */
-(void) writeCharacters:(NSString*)text;
/** @param comment The comment text to write. */
-(void) writeComment:(NSString*)comment;
/** @param target The target string.
 @param data The data string. */
-(void) writeProcessingInstruction:(NSString*)target data:(NSString*)data;
/** @param cdata The cdata string. */
-(void) writeCData:(NSString*)cdata;

/** @returns the written xml string buffer */
-(NSMutableString*) toString;
/** @returns the written xml as data, set to the encoding used in the writeStartDocumentWithEncodingAndVersion method (UTF-8 per default) */
-(NSData*) toData;

/** flush the buffers */
-(void) flush;
/** close the writer and buffers */
-(void) close;

@end

/** xml stream writer with namespace support */
@protocol NSXMLStreamWriter<XMLStreamWriter>

/** @param namespaceURI The namespace.
 @param localName The element name. */
-(void) writeStartElementWithNamespace:(NSString*)namespaceURI localName:(NSString*)localName;
/** @param namespaceURI The namespace.
 @param localName The element name. */
-(void) writeEndElementWithNamespace:(NSString*)namespaceURI localName:(NSString*)localName;
/** @param namespaceURI The namespace.
 @param localName The element name. */
-(void) writeEmptyElementWithNamespace:(NSString*)namespaceURI localName:(NSString*)localName;

/** @param namespaceURI The namespace.
 @param localName The attribute name.
 @param value The attribute value. */
-(void) writeAttributeWithNamespace:(NSString*)namespaceURI localName:(NSString*)localName value:(NSString*)value;

/** set a namespace and prefix
 @param prefix The namespace prefix.
 @param namespaceURI The namespace. */
-(void) setPrefix:(NSString*)prefix namespaceURI:(NSString*)namespaceURI;
/** write (and set) a namespace and prefix 
 @param prefix The namespace prefix.
 @param namespaceURI The namespace. */
-(void) writeNamespace:(NSString*)prefix namespaceURI:(NSString*)namespaceURI;

/** set the default namespace (empty prefix)
 @param namespaceURI The namespace. */
-(void) setDefaultNamespace:(NSString*)namespaceURI;
/** write (and set) the default namespace 
 @param namespaceURI The namespace. */
-(void) writeDefaultNamespace:(NSString*)namespaceURI;

/** @returns The namespace prefix.
 @param namespaceURI The namespace.  */
-(NSString*) getPrefix:(NSString*)namespaceURI;
/** @returns The namespace for the prefix.
 @param prefix The namespace prefix. */
-(NSString*) getNamespaceURI:(NSString*)prefix;

@end

/** XMLWriter writes XML files. Mainly used for iOS since there is no built-in XML writer API for iOS. See: https://code.google.com/p/xswi/w/list */
@interface XMLWriter : NSObject<NSXMLStreamWriter>
{
	// the current output buffer
	NSMutableString* writer;

	// the target encoding
	NSString* encoding;

	// the number current levels
	int level;
	// is the element open, i.e. the end bracket has not been written yet
	BOOL openElement;
	// does the element contain characters, cdata, comments
	BOOL emptyElement;

	// the element stack. one per element level
	NSMutableArray* elementLocalNames;
	NSMutableArray* elementNamespaceURIs;

	// the namespace array. zero or more namespace attributes can be defined per element level
	NSMutableArray* namespaceURIs;
	// the namespace count. one per element level
	NSMutableArray* namespaceCounts;
	// the namespaces which have been written to the stream
	NSMutableArray* namespaceWritten;

	// mapping of namespace URI to prefix and visa versa. Corresponds in size to the namespaceURIs array.
	NSMutableDictionary* namespaceURIPrefixMap;
	NSMutableDictionary* prefixNamespaceURIMap;

	// tag indentation
	NSString* indentation;
	// line break
	NSString* lineBreak;

	// if true, then write elements without children as <start /> instead of <start></start>
	BOOL automaticEmptyElements;
}

/** @returns XML indentation string */
@property (atomic, retain, readwrite) NSString* indentation;
/** @returns lineBreak string */
@property (atomic, retain, readwrite) NSString* lineBreak;
/** @returns automatic empty elements */
@property (atomic, assign, readwrite) BOOL automaticEmptyElements;
/** @returns indentation level */
@property (atomic, readonly) int level;

/** helpful for formatting, special needs
 write linebreak, if any */
-(void) writeLinebreak;
/** write indentation, if any */
-(void) writeIndentation;
/** write end of start element, so that the start tag is complete */
-(void) writeCloseStartElement;

/** write any outstanding namespace declaration attributes in a start element */
-(void) writeNamespaceAttributes;
/** write escaped text to the stream 
 @param value The escaped string. */
-(void) writeEscape:(NSString*)value;
/** wrote unescaped text to the stream
 @param value The unescaped string. */
-(void) write:(NSString*)value;

@end
