//
//  SimpleKMLContainer.m
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

#import "SimpleKMLContainer.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLPlacemark.h"
#import "CXMLNamespaceNode.h"

@implementation SimpleKMLContainer

@synthesize features;
@synthesize flattenedPlacemarks;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self != nil)
    {
        NSError *parseError;
        
        // find child features
        //
        NSMutableArray *featuresArray = [NSMutableArray array];

        NSMutableDictionary *alreadyParsedFeatures = [NSMutableDictionary dictionary];
        
        for (CXMLNode *child in [node children])
        {
            Class featureClass = NSClassFromString([NSString stringWithFormat:@"SimpleKML%@", [child name]]);
            
            if (featureClass)
            {
                parseError = nil;
                
                id feature = [[featureClass alloc] initWithXMLNode:child sourceURL:sourceURL error:&parseError];
                
                // only add the feature if it's one we know how to handle
                //
                if ( ! parseError && [feature isKindOfClass:[SimpleKMLFeature class]])
                {
                    if ([self isMemberOfClass:[SimpleKMLDocument class]])
                        ((SimpleKMLFeature *)feature).document = (SimpleKMLDocument *)self;
                    
                    [featuresArray addObject:feature];
                    
                    if ([feature isKindOfClass:[SimpleKMLPlacemark class]])
                        [alreadyParsedFeatures setObject:feature forKey:child];
                }
            }
        }
        
        features = [NSArray arrayWithArray:featuresArray];
        
        // find all Placemark features, regardless of hierarchy
        //
        NSMutableArray *flattenedPlacemarksArray = [NSMutableArray array];
        
        NSMutableDictionary *namespaceMappings = [NSMutableDictionary dictionary];
        
        /**
         * We need to look at document namespace(s) and ensure we have a default/"kml" one.
         * 
         * TouchXML can't do XPath without namespaces (@schwa says blame Apple for this).
         * 
         * Since we support namespace declaration in either <kml> and <Document> element,
         * we need to check both until we have something.
         *
         * This should probably eventually go someplace more generic. For example, if a 
         * given SimpleKMLObject subclass had a pointer to its SimpleKML object, it could 
         * query that for the namespaces.
         * 
         */
        NSArray *namespaces = [NSArray array];
        
        // check <kml> first
        //
        if ([[((CXMLElement *)[[node rootDocument] rootElement]) namespaces] count])
            namespaces = [((CXMLElement *)[[node rootDocument] rootElement]) namespaces];
        
        // else find <kml>'s child <Document> and check that
        //
        else
            for (CXMLNode *checkNode in [[[node rootDocument] rootElement] children])
                if ([checkNode kind] == CXMLElementKind)
                    namespaces = [((CXMLElement *)checkNode) namespaces];

        // do the mappings - this feels dirty
        //
        for (CXMLNamespaceNode *namespace in namespaces)
            [namespaceMappings setObject:[namespace valueForKeyPath:@"_uri"]
                                  forKey:[namespace valueForKeyPath:@"_prefix"]];
        
        // make sure we have a "kml" prefix
        //
        if ( ! [namespaceMappings objectForKey:@"kml"] && [namespaceMappings objectForKey:@""])
            [namespaceMappings setObject:[namespaceMappings objectForKey:@""] forKey:@"kml"];
        
        if ([namespaceMappings objectForKey:@"kml"])
        {
            for (CXMLNode *featureNode in [node nodesForXPath:@"//kml:Placemark" 
                                            namespaceMappings:namespaceMappings
                                                        error:NULL])
            {
                if ([alreadyParsedFeatures objectForKey:featureNode])
                    [flattenedPlacemarksArray addObject:[alreadyParsedFeatures objectForKey:featureNode]];

                else
                {
                    parseError = nil;
                    
                    SimpleKMLPlacemark *placemark = [[SimpleKMLPlacemark alloc] initWithXMLNode:featureNode 
                                                                                      sourceURL:sourceURL 
                                                                                          error:&parseError];
                    
                    if ( ! parseError)
                        [flattenedPlacemarksArray addObject:placemark];
                }
            }
        }
        
        flattenedPlacemarks = [NSArray arrayWithArray:flattenedPlacemarksArray];
    }
    
    return self;
}

@end