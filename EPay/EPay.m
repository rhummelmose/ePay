//
//    EPay
//
//    This code is distributed under the terms and conditions of the MIT license.
//
//    Copyright (c) 2012 Rasmus Taulborg Hummelmose.
//    rasmus@further.dk
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of this 
//    software and associated documentation files (the "Software"), to deal in the Software 
//    without restriction, including without limitation the rights to use, copy, modify, merge, 
//    publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
//    persons to whom the Software is furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all copies or 
//    substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
//    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
//    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//    DEALINGS IN THE SOFTWARE.
//


#import "EPay.h"
#import <CommonCrypto/CommonDigest.h>


@interface EPay()

@property (strong, nonatomic) NSMutableURLRequest *request;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSURLResponse *response;
@property (strong, nonatomic) NSString *responseBody;

@property (readwrite, strong, nonatomic) NSString *subscription;
@property (readwrite, strong, nonatomic) NSString *amount;
@property (readwrite, strong, nonatomic) NSString* orderID;

@property (strong, nonatomic) NSString *cardNumber;
@property (strong, nonatomic) NSString *expiryMonth;
@property (strong, nonatomic) NSString *expiryYear;
@property (strong, nonatomic) NSString *CVC;

@end


@implementation EPay

@synthesize request = _request;
@synthesize connection = _connection;
@synthesize queue = _queue;
@synthesize response = _response;
@synthesize responseBody = _responseBody;

@synthesize cardNumber = _cardNumber;
@synthesize expiryMonth = _expiryMonth;
@synthesize expiryYear = _expiryYear;
@synthesize CVC = _CVC;

@synthesize merchantNumber = _merchantNumber;
@synthesize md5Secret = _md5Secret;
@synthesize currency = _currency;
@synthesize delegate = _delegate;
@synthesize amount = _amount;
@synthesize orderID = _orderID;
@synthesize subscription = _subscription;

+ (EPay*)ePayWithMerchantNumber:(NSString*)merchantNumber md5Secret:(NSString*)md5Secret currency:(Currency)currency
{
    EPay *thisEPay = [[EPay alloc] init];
    thisEPay.merchantNumber = merchantNumber;
    thisEPay.md5Secret = md5Secret;
    thisEPay.currency = currency;
    return thisEPay;
}

- (NSOperationQueue*)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (void)makePaymentWithOrderID:(NSString*)orderID
                        amount:(NSString*)amount
                    cardNumber:(NSString*)cardNumber
                   expiryMonth:(NSString*)expiryMonth
                    expiryYear:(NSString*)expiryYear
                           CVC:(NSString*)CVC
                  subscription:(NSString*)subscription
{
    
    if (!self.delegate) {
        NSLog(@"[EPAY ERROR] You'll have to define a delegate. Otherwise you cannot react to processed or failed payments.");
        [self clean];
        return;
    }
    
    self.orderID = orderID;
    self.amount = amount;
    self.cardNumber = cardNumber;
    self.expiryMonth = expiryMonth;
    self.expiryYear = expiryYear;
    self.CVC = CVC;
    self.subscription = subscription;
    
    NSData *postData = [self buildPostData];
    
    if (!postData) {
        return;
    }
    
    NSString *postLength = [NSString stringWithFormat:@"%d", postData.length];
    
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ssl.ditonlinebetalingssystem.dk/auth/default.aspx"]];
    [self.request setHTTPMethod:@"POST"];
    [self.request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [self.request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [self.request setHTTPBody:postData];
    
    NSDictionary *paymentParameters = [self extractParametersFromPostString:[[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding]];
    [self.delegate begunProcessingPayment:paymentParameters];
    
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection setDelegateQueue:self.queue];
    [self.connection start];
    
}

- (NSData*)buildPostData
{
    if (![self hasSufficientProperties]) {
        return nil;
    }
    
    NSMutableString* postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"merchantnumber=%@&currency=%d", self.merchantNumber, self.currency];
    [postString appendFormat:@"&orderid=%@&amount=%@&cardno=%@&expmonth=%@&expyear=%@&cvc=%@", self.orderID, self.amount, self.cardNumber, self.expiryMonth, self.expiryYear, self.CVC];
    [postString appendString:@"&accepturl=https://ssl.ditonlinebetalingssystem.dk/ok&declineurl=https://ssl.ditonlinebetalingssystem.dk/declined"];
    
    if (self.md5Secret) {
        NSString *md5Key = [self md5OfString:[NSString stringWithFormat:@"%d%@%@%@", self.currency, self.amount, self.orderID, self.md5Secret]];
        [postString appendFormat:@"&MD5Key=%@", md5Key];
    }
    
    if (self.subscription) {
        [postString appendFormat:@"&subscription=%@", self.subscription];
    }
    
    NSData *returnData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return returnData;
}

- (BOOL)hasSufficientProperties
{
    NSMutableString *errorString = [[NSMutableString alloc] init];
    [errorString appendString:@"The following properties may not be nil: "];
    BOOL error = NO;
    NSUInteger errorCount = 0;
    
    if (!self.merchantNumber) {
        error = YES;
        if (errorCount > 0) [errorString appendString:@", "];
        [errorString appendString:@"merchantNumber"];
        errorCount++;
    }
    if (!self.currency) {
        error = YES;
        if (errorCount > 0) [errorString appendString:@", "];
        [errorString appendString:@"currency"];
        errorCount++;
    }
    if (!self.orderID) {
        error = YES;
        if (errorCount > 0) [errorString appendString:@", "];
        [errorString appendString:@"orderID"];
        errorCount++;
    }
    if (!self.amount) {
        error = YES;
        if (errorCount > 0) [errorString appendString:@", "];
        [errorString appendString:@"amount"];
        errorCount++;
    }
    if (!self.cardNumber) {
        error = YES;
        if (errorCount > 0) [errorString appendString:@", "];
        [errorString appendString:@"cardNumber"];
        errorCount++;
    }
    if (!self.expiryMonth) {
        error = YES;
        if (errorCount > 0) [errorString appendString:@", "];
        [errorString appendString:@"expiryMonth"];
        errorCount++;
    }
    if (!self.expiryYear) {
        error = YES;
        if (errorCount > 0) [errorString appendString:@", "];
        [errorString appendString:@"expiryYear"];
        errorCount++;
    }
    if (!self.CVC) {
        error = YES;
        if (errorCount > 0) [errorString appendString:@", "];
        [errorString appendString:@"CVC"];
        errorCount++;
    }
    
    if (error) {
        NSError *errorObject = [NSError errorWithDomain:@"ePay" code:0 userInfo:[NSDictionary dictionaryWithObject:errorString forKey:@"Error Text"]];
        [self.delegate paymentFailed:errorObject];
        [self clean];
        return NO;
    }
    
    return YES;
}

- (NSString *)md5OfString:(NSString*)string
{
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *responseParameters = [self extractParametersFromURL:self.response.URL];
    
    if (!responseParameters) {
        NSError *error = [NSError errorWithDomain:@"ePay" code:0 userInfo:[NSDictionary dictionaryWithObject:self.responseBody forKey:@"Error Text"]];
        [self.delegate paymentFailed:error];
        [self clean];
        return;
    }
    
    if ([responseParameters objectForKey:@"error"]) {
        NSString *errorText = [responseParameters objectForKey:@"errortext"];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[errorText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"Error Text"];
        NSError *error = [NSError errorWithDomain:@"ePay" code:[[responseParameters objectForKey:@"error"] intValue] userInfo:userInfo];
        [self.delegate paymentFailed:error];
        [self clean];
        return;
    }
    
    [self.delegate didProcessPayment:responseParameters];
    [self clean];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate paymentFailed:error];
    [self clean];
}

- (NSDictionary*)extractParametersFromPostString:(NSString*)string
{
    NSMutableDictionary *parameters = nil;
    
    if ([string rangeOfString:@"="].location != NSNotFound) {
        
        parameters = [[NSMutableDictionary alloc] init];
        NSArray *parametersArray = [string componentsSeparatedByString:@"&"];
        
        for (NSString *parameterString in parametersArray) {
            NSArray *parameterArray = [parameterString componentsSeparatedByString:@"="];
            [parameters setObject:[parameterArray lastObject] forKey:[parameterArray objectAtIndex:0]];
        }
    }
    
    return parameters;
}

- (NSDictionary*)extractParametersFromURL:(NSURL*)URL
{
    NSMutableDictionary *parameters = nil;
    NSString *URLString = [NSString stringWithFormat:@"%@", URL];
    
    if ([URLString rangeOfString:@"?"].location != NSNotFound) {
        
        parameters = [[NSMutableDictionary alloc] init];
        NSString *parametersString = [URLString substringFromIndex:[URLString rangeOfString:@"?"].location+1];
        NSArray *parametersArray = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *parameterString in parametersArray) {
            NSArray *parameterArray = [parameterString componentsSeparatedByString:@"="];
            [parameters setObject:[parameterArray lastObject] forKey:[parameterArray objectAtIndex:0]];
        }
    }
    
    return parameters;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{  
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)clean
{
    self.subscription = nil;
    self.amount = nil;
    self.orderID = nil;
    self.response = nil;
    self.request = nil;
    self.connection = nil;
    self.responseBody = nil;
    self.cardNumber = nil;
    self.expiryMonth = nil;
    self.expiryYear = nil;
    self.CVC = nil;
}

@end