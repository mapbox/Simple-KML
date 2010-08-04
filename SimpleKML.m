//
//  SimpleKML.m
//
//  Created by Justin R. Miller on 6/29/10.
//  Copyright 2010, Code Sorcery Workshop, LLC and Development Seed, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//  
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//      * Neither the names of Code Sorcery Workshop, LLC or Development Seed,
//        Inc., nor the names of its contributors may be used to endorse or
//        promote products derived from this software without specific prior
//        written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SimpleKML.h"
#import "SimpleKMLFeature.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"

NSString *const SimpleKMLErrorDomain = @"SimpleKMLErrorDomain";

@interface SimpleKML (SimpleKMLPrivate)

- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error;

@end

#pragma mark -

@implementation SimpleKML

@synthesize feature;
@synthesize source;

+ (SimpleKML *)KMLWithContentsofURL:(NSURL *)URL error:(NSError **)error
{
    return [[[self alloc] initWithContentsOfURL:URL error:error] autorelease];
}

+ (SimpleKML *)KMLWithContentsOfFile:(NSString *)path error:(NSError **)error
{
    return [[[self alloc] initWithContentsOfFile:path error:error] autorelease];
}

- (id)initWithContentsOfURL:(NSURL *)URL error:(NSError **)error
{
    self = [super init];
    
    if (self != nil)
    {
        sourceURL = [URL retain];
        feature   = nil;
        
        if ([[[URL relativePath] pathExtension] isEqualToString:@"kml"])
        {
            source = [[NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL] retain];
        }
        else if ([[[URL relativePath] pathExtension] isEqualToString:@"kmz"])
        {
            NSData *sourceData = [SimpleKML dataFromArchiveAtPath:[URL relativePath] withFilePath:@"doc.kml"]; // TODO: find first KML, not just doc.kml
            
            if (sourceData)
                source = [[NSString alloc] initWithData:sourceData encoding:NSUTF8StringEncoding];
            
            else
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to locate top-level KML file in KMZ archive" 
                                                                     forKey:NSLocalizedFailureReasonErrorKey];
                
                if (error)
                    *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                
                return nil;
            }
        }
        else 
        {
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLUnknownFileType userInfo:nil];
            
            return nil;
        }
        
        NSError *parseError = nil;
        
        CXMLDocument *document = [[[CXMLDocument alloc] initWithXMLString:source
                                                                  options:0
                                                                    error:&parseError] autorelease];
        
        // return nil if we can't properly parse this file
        //
        if (parseError)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unable to parse XML: %@", parseError]
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
        
        CXMLElement *rootElement = [document rootElement];
        
        // the root <kml> element should only have 0 or 1 children, plus the <kml> open & close
        //
        if ([rootElement childCount] < 2 || [rootElement childCount] > 3)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (root element has invalid child object count)" 
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
        
        // build up our Feature if we have one
        //
        if ([rootElement childCount] == 3)
        {
            CXMLNode *featureNode = [rootElement childAtIndex:1];
            
            Class featureClass = NSClassFromString([NSString stringWithFormat:@"SimpleKML%@", [featureNode name]]);
            
            parseError = nil;
            
            feature = [[featureClass alloc] initWithXMLNode:featureNode sourceURL:sourceURL error:&parseError];
            
            if (parseError)
            {
                if (error)
                    *error = parseError;
                
                return nil;
            }
            
            // we can only handle Feature for now
            //
            if ( ! featureClass || ! [feature isKindOfClass:[SimpleKMLFeature class]])
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Root element contains a child object unknown to this library" 
                                                                     forKey:NSLocalizedFailureReasonErrorKey];
                
                if (error)
                    *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLUnknownObject userInfo:userInfo];
                
                return nil;
            }
        }
    }
    
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error
{
    return [self initWithContentsOfURL:[NSURL fileURLWithPath:path] error:error];
}

- (void)dealloc
{
    [sourceURL release];
    [feature release];
    [source release];
    
    [super dealloc];
}

#pragma mark -

+ (UIColor *)colorForString:(NSString *)colorString;
{
    // color string should be eight or nine characters (RGBA in hex, with or without '#' prefix)
    //
    if ([colorString length] < 8 || [colorString length] > 9)
        return nil;
    
    colorString = [colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSMutableArray *parts = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < 8; i = i + 2)
    {
        NSString *part = [colorString substringWithRange:NSMakeRange(i, 2)];
        
        unsigned wholeValue;
        
        [[NSScanner scannerWithString:part] scanHexInt:&wholeValue];
        
        if (wholeValue < 0 || wholeValue > 255)
            return nil;
        
        [parts addObject:[NSNumber numberWithFloat:((CGFloat)wholeValue / (CGFloat)255)]];
    }
    
    UIColor *color = [UIColor colorWithRed:[[parts objectAtIndex:3] floatValue]
                                     green:[[parts objectAtIndex:2] floatValue]
                                      blue:[[parts objectAtIndex:1] floatValue]
                                     alpha:[[parts objectAtIndex:0] floatValue]];
    
    return color;
}

+ (NSData *)dataFromArchiveAtPath:(NSString *)archivePath withFilePath:(NSString *)filePath
{
    ZipFile *archive = [[[ZipFile alloc] initWithFileName:archivePath mode:ZipFileModeUnzip] autorelease];
    
    NSString *archiveName = [archivePath lastPathComponent];
    
    archiveName = [archiveName substringWithRange:NSMakeRange(0, [archiveName length] - 4)];
    
    if ( ! [archive locateFileInZip:[NSString stringWithFormat:@"%@/%@", archiveName, filePath]])
    {
        [archive close];
        
        return nil;
    }
    
    FileInZipInfo *info = [archive getCurrentFileInZipInfo];
    
    ZipReadStream *stream = [archive readCurrentFileInZip];
    
    NSMutableData *data = [NSMutableData dataWithLength:info.length];
    
    [stream readDataWithBuffer:data];
    
    [stream finishedReading];
    
    [archive close];
    
    return data;
}

@end