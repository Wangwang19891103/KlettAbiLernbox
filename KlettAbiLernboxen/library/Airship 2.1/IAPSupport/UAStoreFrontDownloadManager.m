/*
 Copyright 2009-2012 Urban Airship Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binaryform must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided withthe distribution.

 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UAStoreFrontDownloadManager.h"

#import "UAContentURLCache.h"
#import "UAStoreFront.h"
#import "UAStoreFrontDelegate.h"
#import "UAirship.h"
#import "UADownloadContent.h"
#import "UAUtils.h"
#import "UAProduct.h"
#import "UAInventory.h"
#import "UAStoreKitObserver.h"
#import "UAStoreFrontAlertProtocol.h"
#import "UA_SBJSON.h"

#import "old_defines.h"

@implementation UAStoreFrontDownloadManager

@synthesize downloadDirectory;
@synthesize createProductIDSubdir;
@synthesize contentURLCache;
@synthesize pendingProducts;
@synthesize decompressingProducts;
@synthesize currentlyDecompressingProducts;

#pragma mark -
#pragma mark Lifecycle methods

- (id)init {
    
    if ((self = [super init])) {
        downloadManager = [[UADownloadManager alloc] init];
        downloadManager.delegate = self;
        self.downloadDirectory = kUADownloadDirectory;
        self.createProductIDSubdir = YES;
        
        self.contentURLCache = [UAContentURLCache cacheWithExpirationInterval:kDefaultUrlCacheExpirationInterval //24 hours
                                                                     withPath:kIAPURLCacheFile];
        
        self.currentlyDecompressingProducts = [NSMutableArray array];
        
        [self loadPendingProducts];
        [self loadDecompressingProducts];
    }
    
    return self;
}

- (void)dealloc {
    RELEASE_SAFELY(pendingProducts);
    RELEASE_SAFELY(decompressingProducts);
    RELEASE_SAFELY(currentlyDecompressingProducts);
    RELEASE_SAFELY(downloadDirectory);
    RELEASE_SAFELY(downloadManager);
    RELEASE_SAFELY(contentURLCache);
    [super dealloc];
}

#pragma mark -
#pragma mark Download

- (void)downloadProduct:(UAProduct *)product withContentURL:(NSURL *)contentURL {
    UAZipDownloadContent *zipDownloadContent = [[[UAZipDownloadContent alloc] init] autorelease];
    zipDownloadContent.userInfo = product;
    zipDownloadContent.downloadFileName = product.productIdentifier;
    zipDownloadContent.downloadPath = [downloadDirectory stringByAppendingPathComponent:
                                       [NSString stringWithFormat: @"%@.zip", product.productIdentifier]];
    zipDownloadContent.progressDelegate = product;
    
    SKPaymentTransaction *transaction = product.transaction;
    // check if already downloading
    if ([downloadManager isDownloading:zipDownloadContent]) {
        product.status = UAProductStatusDownloading;
        [[UAStoreFront shared].sfObserver finishTransaction:transaction];
        product.transaction = nil;
        return;
    }
    
    // Check if product got updated before resume downloading
    if ([product hasUpdate] && [[NSFileManager defaultManager] fileExistsAtPath:[zipDownloadContent downloadTmpPath]]) {
        zipDownloadContent.clearBeforeDownload = YES;
    }
    
    // Save purchased receipt
    [[UAStoreFront shared] addReceipt:product];
    
    [[UAStoreFront shared].sfObserver finishTransaction:transaction];
    
    product.transaction = nil;
    // Refresh inventory and UI just before downloading start
    product.status = UAProductStatusDownloading;
    [[UAStoreFront shared].inventory groupInventory];
    
    zipDownloadContent.downloadRequestURL = contentURL;
    zipDownloadContent.requestMethod = kRequestMethodGET;
    [downloadManager download:zipDownloadContent];
}

- (void)verifyProduct:(UAProduct *)product {
    
    // Refresh cell, waiting for download
    product.status = UAProductStatusVerifyingReceipt;
    UALOG(@"Verify receipt for product: %@", product.productIdentifier);
    
    NSString *receipt = nil;
    if(product.isFree != YES) {
        receipt = product.receipt;
    }
    NSString *server = [[UAirship shared] server];
    NSString *urlString = [NSString stringWithFormat: @"%@/api/app/content/%@/download",
                           server, product.productIdentifier];
    NSURL *itemURL = [NSURL URLWithString: urlString];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [UAUtils deviceID], @"ua_device_id",
                                 [StoreFrontVersion get], @"version", nil];
    if (receipt != nil) {
        [data setObject:receipt forKey:@"transaction_receipt"];
    }
    
    NSURL *contentURL = [contentURLCache contentForProductURL:itemURL withVersion:[NSNumber numberWithInt:product.revision]];

    [self addPendingProduct:product];
    
    if (contentURL) {
        UALOG(@"downloading from cached contentURL: %@", contentURL);
        [self downloadProduct:product withContentURL:contentURL];
    } else {
        UADownloadContent *downloadContent = [[[UADownloadContent alloc] init] autorelease];
        downloadContent.userInfo = product;
        downloadContent.username = [[UAirship shared] appId];
        downloadContent.password = [[UAirship shared] appSecret];
        downloadContent.downloadRequestURL = itemURL;
        downloadContent.requestMethod = kRequestMethodPOST;
        downloadContent.postData = data;
        
        [downloadManager download:downloadContent];
    }
}

- (UAProduct *)getProductByTransaction:(SKPaymentTransaction*)transaction {
    NSString *productIdentifier;
    UAProduct *product;
    
    productIdentifier = [[transaction payment] productIdentifier];
    // If the product was purchased previously, but no longer exits on UA
    // We can not restore it.
    if ([[UAStoreFront shared].inventory hasProductWithIdentifier:productIdentifier] == NO) {
        UALOG(@"Product no longer exists in inventory: %@", productIdentifier);
        [[UAStoreFront shared].sfObserver finishUnknownTransaction:transaction];
        return nil;
    }

    product = [[UAStoreFront shared].sfObserver productFromTransaction:transaction];
    product.transaction = transaction;

    return product;
}

// called from sf observer's completeTransaction/restoreTransaction - verifies the receipt with UA
- (void)verifyTransactionReceipt:(SKPaymentTransaction *)transaction {
    
    UAProduct *product = [self getProductByTransaction:transaction];
    
    if (!product) {
        UALOG(@"ERROR: The transaction is invalid.");
        return;
    }
    
    [self verifyProduct:product];
}

//download a pending product - it's already been purchased, so we'll proceed to verifying the receipt
- (void)downloadPurchasedProduct:(UAProduct *)product {

    // Check if we are already downloading the product
    if (product.status == UAProductStatusDownloading ||
        product.status == UAProductStatusVerifyingReceipt ||
        product.status == UAProductStatusDecompressing) {
        
        UALOG(@"The same item is being downloaded, ignore this request");
        
        return;
    }
    
    [self verifyProduct:product];
}

- (NSMutableDictionary *)loadProductsFromFilePath:(NSString *)filePath {
    return [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
}

- (BOOL)saveProducts:(NSMutableDictionary *)productDictionary toFilePath:(NSString *)filePath {
   return [productDictionary writeToFile:filePath atomically:YES];
}

#pragma mark -
#pragma mark Pending Transactions Management

- (void)loadPendingProducts {
    self.pendingProducts = [self loadProductsFromFilePath:kPendingProductsFile];
    if (pendingProducts == nil) {
        self.pendingProducts = [NSMutableDictionary dictionary];
    }
}

- (void)savePendingProducts {
    if (![self saveProducts:pendingProducts toFilePath:kPendingProductsFile]) {
        UALOG(@"Failed to save pending products to file path: %@", kPendingProductsFile);
    }
}

- (BOOL)hasPendingProduct:(UAProduct *)product {
    return [pendingProducts valueForKey:product.productIdentifier] != nil;
}

- (void)addPendingProduct:(UAProduct *)product {
    if (product.receipt == nil)
        product.receipt = @"";

    [pendingProducts setObject:product.receipt forKey:product.productIdentifier];
    [self savePendingProducts];
}

- (void)removePendingProduct:(UAProduct *)product {
    [pendingProducts removeObjectForKey:product.productIdentifier];
    [self savePendingProducts];
}

- (void)resumePendingProducts {
    UALOG(@"Resume pending products in purchasing queue %@", pendingProducts);

    //if the inventory is currently loading the contents will be empty, so there is
    //no point in continuing. log a warning so that it's clear this is the case
    if ([UAStoreFront shared].inventory.status == UAInventoryStatusDownloading) {
        UALOG(@"Warning: inventory is currently downloading, cancelling resume");
        return;
    }

    for (NSString *identifier in [pendingProducts allKeys]) {
        UAProduct *pendingProduct = [[UAStoreFront shared].inventory productWithIdentifier:identifier];

        //if pendingProduct is nil, it's not currently in the inventory. This is either because the
        //inventory contents have been invalidated, or because it's contents have been changed remotely
        //since the product was initially downloaded
        if (pendingProduct) {
            pendingProduct.receipt = [pendingProducts objectForKey:identifier];
            [self downloadPurchasedProduct:pendingProduct];
        } else {
            UALOG(@"Warning: product not found for pending download with identifier %@", identifier);
        }
    }

    // Reconnect downloading request with newly created product
    for (UAZipDownloadContent *downloadContent in [downloadManager allDownloadingContents]) {

        UAProduct *oldProduct = [downloadContent userInfo];
        UAProduct *newProduct = [[UAStoreFront shared].inventory productWithIdentifier:oldProduct.productIdentifier];
        
        if (newProduct.status == UAProductStatusHasUpdate) {
            [downloadManager cancel:downloadContent];
        } else {
            newProduct.status = oldProduct.status;
            newProduct.progress = oldProduct.progress;
            downloadContent.userInfo = newProduct;
            downloadContent.progressDelegate = newProduct;
            [downloadManager updateProgressDelegate:downloadContent];
        }
    }
}

#pragma mark -
#pragma mark Decompressing Products Management

- (UAZipDownloadContent *)zipDownloadContentForProduct:(UAProduct *)product {
    UAZipDownloadContent *zipDownloadContent = [[[UAZipDownloadContent alloc] init] autorelease];
    zipDownloadContent.userInfo = product;
    zipDownloadContent.downloadFileName = product.productIdentifier;
    zipDownloadContent.downloadPath = [downloadDirectory stringByAppendingPathComponent:
                                       [NSString stringWithFormat: @"%@.zip", product.productIdentifier]];
    zipDownloadContent.progressDelegate = product;
    
    return zipDownloadContent;
}

- (void)decompressZipDownloadContent:(UAZipDownloadContent *)zipDownloadContent {
    UAProduct *product = zipDownloadContent.userInfo;
    product.status = UAProductStatusDecompressing;
    [currentlyDecompressingProducts addObject:product.productIdentifier];
    
    zipDownloadContent.decompressDelegate = self;
    
    if(self.createProductIDSubdir) {
        zipDownloadContent.decompressedContentPath = [NSString stringWithFormat:@"%@/",
                                                      [self.downloadDirectory stringByAppendingPathComponent:zipDownloadContent.downloadFileName]];
    } else {
        zipDownloadContent.decompressedContentPath = [NSString stringWithFormat:@"%@", self.downloadDirectory];
        
    }
    
    UALOG(@"DecompressedContentPath - '%@",zipDownloadContent.decompressedContentPath);
    
    [zipDownloadContent decompress];
}

- (void)loadDecompressingProducts {
    self.decompressingProducts = [self loadProductsFromFilePath:kDecompressingProductsFile];
    if (decompressingProducts == nil) {
        self.decompressingProducts = [NSMutableDictionary dictionary];
    }
}

- (void)saveDecompressingProducts {
    if (![self saveProducts:decompressingProducts toFilePath:kDecompressingProductsFile]) {
        UALOG(@"Failed to save decompresing products to file path: %@", kDecompressingProductsFile);
    }
}

- (BOOL)hasDecompressingProduct:(UAProduct *)product {
    return [decompressingProducts valueForKey:product.productIdentifier] != nil;
}

- (void)addDecompressingProduct:(UAProduct *)product {
    if (product.receipt == nil) {
        product.receipt = @"";
    }
    
    [decompressingProducts setObject:product.receipt forKey:product.productIdentifier];
    [self saveDecompressingProducts];
}

- (void)removeDecompressingProduct:(UAProduct *)product {
    [decompressingProducts removeObjectForKey:product.productIdentifier];
    [self saveDecompressingProducts];
}

- (void)resumeDecompressingProducts {
    UALOG(@"Resume decompressing products in queue %@", decompressingProducts);

    //if the inventory is currently loading the contents will be empty, so there is
    //no point in continuing. log a warning so that it's clear this is the case
    if ([UAStoreFront shared].inventory.status == UAInventoryStatusDownloading) {
        UALOG(@"Warning: inventory is currently downloading, cancelling resume");
        return;
    }
    for (NSString *identifier in [decompressingProducts allKeys]) {
        //only resume decompression for products that aren't currently doing so
        if (![currentlyDecompressingProducts containsObject:identifier]) {
            UAProduct *decompressingProduct = [[UAStoreFront shared].inventory productWithIdentifier:identifier];

            //if decompressingProduct is nil, it's not currently in the inventory. This is either because the
            //inventory contents have been invalidated, or because it's contents have been changed remotely
            //since the product was initially downloaded
            if (decompressingProduct) {
                decompressingProduct.receipt = [decompressingProducts objectForKey:identifier];

                UAZipDownloadContent *zipDownloadContent = [self zipDownloadContentForProduct:decompressingProduct];
                [self decompressZipDownloadContent:zipDownloadContent];
            } else {
                UALOG(@"Warning: product not found for pending decompression with identifier %@", identifier);
            }
        }
    }
}

#pragma mark -
#pragma mark Download Delegate

//Pull an item from the store and decompress it into the downloads directory
- (void)verifyDidSucceed:(UADownloadContent *)downloadContent {
    UAProduct *product = downloadContent.userInfo;
    
    UAZipDownloadContent *zipDownloadContent = [self zipDownloadContentForProduct:product];
        
    SKPaymentTransaction *transaction = product.transaction;
    // check if already downloading
    if ([downloadManager isDownloading:zipDownloadContent]) {
        product.status = UAProductStatusDownloading;
        [[UAStoreFront shared].sfObserver finishTransaction:transaction];
        product.transaction = nil;
        return;
    }
    
    // Check if product got updated before resume downloading
    if ([product hasUpdate] && [[NSFileManager defaultManager] fileExistsAtPath:[zipDownloadContent downloadTmpPath]]) {
        zipDownloadContent.clearBeforeDownload = YES;
    }
    
    // Save purchased receipt
    [[UAStoreFront shared] addReceipt:product];

    [[UAStoreFront shared].sfObserver finishTransaction:transaction];
    
    product.transaction = nil;
    // Refresh inventory and UI just before downloading start
    product.status = UAProductStatusDownloading;
    [[UAStoreFront shared].inventory groupInventory];
    
    NSDictionary *result = (NSDictionary *)[UAUtils parseJSON:downloadContent.responseString];
    NSString *contentURLString = [result objectForKey:@"content_url"];
    
    //cache the content url
    UALOG(@"caching content url: %@ for download url: %@", contentURLString, product.downloadURL);
    NSURL *contentURL = [NSURL URLWithString:contentURLString];
    [contentURLCache setContent:contentURL forProductURL:product.downloadURL withVersion:[NSNumber numberWithInt:product.revision]];
        
    [self downloadProduct:product withContentURL:contentURL];
}


- (void)downloadDidFail:(UADownloadContent *)downloadContent {
    UAProduct *product = downloadContent.userInfo;
    //SKPaymentTransaction *transaction = product.transaction;

    // alert detail error to user
    // ASIHTTPRequest will directly invoke this method when request timeout, so
    // if put the error alert codes in '...Finished' method, will miss these
    // alerts when timeout error raised
    id<UAStoreFrontAlertProtocol> alertHandler = [[[UAStoreFront shared] uiClass] getAlertHandler];
    if (product.status == UAProductStatusVerifyingReceipt) {
        if ([alertHandler respondsToSelector:@selector(showReceiptVerifyFailedAlert)]) {
            [alertHandler showReceiptVerifyFailedAlert];
        }
    } else if (product.status == UAProductStatusDownloading){
        if ([alertHandler respondsToSelector:@selector(showDownloadContentFailedAlert)]) {
            [alertHandler showDownloadContentFailedAlert];
        }
        
    } else if (product.status == UAProductStatusDecompressing) {
        if ([alertHandler respondsToSelector:@selector(showDecompressContentFailedAlert)]) {
            [alertHandler showDecompressContentFailedAlert];
        }
        
    }

    // NOTE: the following block is commented out to prevent a crash
    // when finishTransaction is called twice. finishTransaction should
    // already have been called in the verify process
    //
    // don't invoke failedTransaction, otherwise, will alert user twice
    // also, in failedTransaction will reset product status after a decision,
    // but here we already reset it.
    // [[UAStoreFront shared].sfObserver finishTransaction:transaction];

    [product resetStatus];
    [downloadManager endBackground];
}

#pragma mark Download Delegate

- (void)requestDidFail:(UADownloadContent *)downloadContent {
    [self downloadDidFail:downloadContent];
}

- (void)requestDidSucceed:(id)downloadContent {
    if ([downloadContent isKindOfClass:[UAZipDownloadContent class]]) {
        UAZipDownloadContent *zipDownloadContent = (UAZipDownloadContent *)downloadContent;
        
        UAProduct *product = zipDownloadContent.userInfo;
        
        [self removePendingProduct:product];
        [self addDecompressingProduct:product];
        
        [self decompressZipDownloadContent:zipDownloadContent];
        
    } else if ([downloadContent isKindOfClass:[UADownloadContent class]]) {
        [self verifyDidSucceed:(UADownloadContent *)downloadContent];
    }
}

- (void)downloadQueueProgress:(float)progress count:(int)count{
    if ([[UAStoreFront shared].delegate respondsToSelector:@selector(productsDownloadProgress:count:)]) {
        [[UAStoreFront shared].delegate productsDownloadProgress:progress count:count];
    }
}

#pragma mark Decompress Delegate

- (void)decompressDidSucceed:(UAZipDownloadContent *)downloadContent {
    UAProduct *product = downloadContent.userInfo;
    [currentlyDecompressingProducts removeObject:product.productIdentifier];
    [self removeDecompressingProduct:product];
    product.status = UAProductStatusInstalled;
    [[UAStoreFront shared].delegate productPurchased:product];
    // Check to see if we're done with background downloads, this may end the execution thread here.
    [downloadManager endBackground];
}

- (void)decompressDidFail:(UAZipDownloadContent *)downloadContent {
    UAProduct *product = downloadContent.userInfo;
    [currentlyDecompressingProducts removeObject:product.productIdentifier];
    [self removeDecompressingProduct:product];
    [self downloadDidFail:downloadContent];
}


#pragma mark -
#pragma mark Inventory observer methods

- (void)inventoryStatusChanged:(NSNumber *)status {
    if ([status intValue] == UAInventoryStatusLoaded) {
        [self resumePendingProducts];
        [self resumeDecompressingProducts];
    }
}

@end
