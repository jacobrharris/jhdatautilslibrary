//
//  AIDataUtils.m
//  ai-aggregator
//
//  Created by Jacob Harris on 9/15/14.
//  Copyright (c) 2014 Jacob Harris. All rights reserved.
//

#import "JHDataUtils.h"
#import "PendingOperations.h"
#import "AFNetworking.h"

@implementation JHDataUtils {
    PendingOperations *_pendingOperations;
}

#define apiKey @"abcd1234"

- (void)queueDownloadRequest:(NSURLRequest *)request delegate:(id)delegate
{
     AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        id<JHDataUtilsDelegate> delegate = self.delegate;
        JHDataObject *dataObject = [[JHDataObject alloc] initWithOperation:operation error:nil];
        
        if (![dataObject json]) {
            [delegate dataUtils:self didFinishWithDataObject:nil];
        } else {
            [delegate dataUtils:self didFinishWithDataObject:dataObject];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        JHDataObject *dataObject = [[JHDataObject alloc] initWithOperation:operation error:error];
        [delegate dataUtils:self didFinishWithDataObject:dataObject];
    }];
    
    [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
}

- (NSMutableURLRequest *)newPOSTRequest:(NSString *)post url:(NSURL *)url
{
    NSData *data = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    return request;
}

//- (void)imageDownloaderDidFinish:(ImageDownloaderOperation *)downloader
//{
//    NSIndexPath *tvIndexPath = downloader.indexPathInTableView;
//    NSIndexPath *cvIndexPath = downloader.indexPathInCollectionView;
//
//    id<AIDataUtilsDelegate> delegate = self.delegate;
//    
//    if (!cvIndexPath) {
//        [delegate dataUtils:self didFinishWithIndexPath:tvIndexPath];
//        [self.pendingOperations.downloadsInProgress removeObjectForKey:tvIndexPath];
//    } else {
//        [delegate dataUtils:self didFinishWithTableViewIndexPath:tvIndexPath collectionViewIndexPath:cvIndexPath];
//        [self.pendingOperations.downloadsInProgress removeObjectForKey:cvIndexPath];
//    }
//}

- (PendingOperations *)pendingOperations
{
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (NSArray *)allPendingOperations
{
    return [self.pendingOperations.downloadsInProgress allKeys];
}

- (id)pendingOperationAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
}

- (void)removePendingOperationAtIndexPath:(NSIndexPath *)indexPath
{
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}

- (void)suspendAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:YES];
}

- (void)resumeAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:NO];
}

- (void)cancelAllOperations
{
    [self.pendingOperations.downloadQueue cancelAllOperations];
}

@end
