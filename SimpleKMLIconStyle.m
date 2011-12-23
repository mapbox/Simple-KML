//
//  SimpleKMLIconStyle.m
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

#import "SimpleKMLIconStyle.h"
#import "SimpleKML_UIImage.h"

#define kSimpleKMLIconStyleDefaultScale    1.0f
#define kSimpleKMLIconStyleDefaultHeading  0.0f
#define kSimpleKMLIconStyleBaseIconSize   32.0f

@implementation SimpleKMLIconStyle

@synthesize icon;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self != nil)
    {
        icon = nil;
        
        UIImage *baseIcon   = nil;
        CGFloat baseScale   = kSimpleKMLIconStyleDefaultScale;
        CGFloat baseHeading = kSimpleKMLIconStyleDefaultHeading;
        
        for (CXMLNode *child in [node children])
        {
#pragma mark TODO: we should be case folding here
            if ([[child name] isEqualToString:@"Icon"])
            {
                // find the first element node child of the root
                //
                CXMLNode *href = nil;
                
                for (CXMLNode *grandchild in [child children])
                {
                    if ([grandchild kind] == CXMLElementKind)
                    {
                        href = grandchild;
                        break;
                    }
                }
                
                if ( ! href)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (no href specified for IconStyle Icon)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }

                NSData *data = nil;
                
                if ([self cacheObjectForKey:[href stringValue]])
                    data = [self cacheObjectForKey:[href stringValue]];
                
                else
                {
                    NSURL *imageURL = [NSURL URLWithString:[href stringValue]];
                    
                    if ( ! imageURL)
                    {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (invalid icon URL specified in IconStyle)" 
                                                                             forKey:NSLocalizedFailureReasonErrorKey];
                        
                        if (error)
                            *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                        
                        return nil;
                    }
                    
                    if ([imageURL scheme])
                        data = [NSData dataWithContentsOfURL:imageURL];
                    
                    else if ([[sourceURL relativePath] hasSuffix:@".kmz"])
                        data = [SimpleKML dataFromArchiveAtPath:[sourceURL relativePath] withFilePath:[imageURL relativePath]];
                    
                    if (data)
                        [self setCacheObject:data forKey:[href stringValue]];
                    
                    else
                    {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (invalid icon URL specified in IconStyle)" 
                                                                             forKey:NSLocalizedFailureReasonErrorKey];
                        
                        if (error)
                            *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                        
                        return nil;
                    }
                }
                
                baseIcon = [UIImage imageWithData:data];
                
                if ( ! baseIcon)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (unable to retrieve icon specified for IconStyle)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
            }
            else if ([[child name] isEqualToString:@"scale"])
            {
                baseScale = (CGFloat)[[child stringValue] floatValue];

                if (baseScale <= 0)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (invalid icon scale specified in IconStyle)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
            }
            else if ([[child name] isEqualToString:@"heading"])
            {
                baseHeading = (CGFloat)[[child stringValue] floatValue];

                if (baseHeading < 0 || baseHeading > 360)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (invalid icon heading specified in IconStyle)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
            }
        }
        
#pragma mark TODO: rotate image according to heading
#pragma mark TODO: read in parent ColorStyle color & auto-apply to icon

        CGFloat newWidth  = kSimpleKMLIconStyleBaseIconSize * baseScale;
        CGFloat newHeight = kSimpleKMLIconStyleBaseIconSize * baseScale;
        
        icon = [baseIcon imageWithWidth:newWidth height:newHeight];
    }
    
    return self;
}

@end