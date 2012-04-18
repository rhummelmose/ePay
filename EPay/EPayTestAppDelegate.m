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

#import "EPayTestAppDelegate.h"

@implementation EPayTestAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // We create an ePay object.
    EPay *ePay = [EPay ePayWithMerchantNumber:@"Your Merchant Number" md5Secret:@"Your MD5 Secret(Pass nil if you wish not to use MD5 hashing)" currency:CURRENY_DKK];
    
    // We set ourselves as the delegate and perform a payment.
    ePay.delegate = self;
    [ePay makePaymentWithOrderID:@"1" amount:@"10000" cardNumber:@"4444444444444000" expiryMonth:@"01" expiryYear:@"15" CVC:@"666" subscription:nil];
    
    return YES;
}


#pragma mark - EPay Delegate Methods

- (void)begunProcessingPayment:(NSDictionary*)paymentParameters
{
    NSLog(@"[EPAY PROCESS] Begun processing payment.");
    for (NSString *key in paymentParameters.keyEnumerator) {
        NSLog(@"[EPAY PROCESS] %@: %@", key, [paymentParameters objectForKey:key]);
    }
}

- (void)didProcessPayment:(NSDictionary*)successParameters
{
    NSLog(@"[EPAY SUCCESS] Processed payment successfully.");
    for (NSString *key in successParameters.keyEnumerator) {
        NSLog(@"[EPAY SUCCESS] %@: %@", key, [successParameters objectForKey:key]);
    }
}
- (void)paymentFailed:(NSError*)error
{
    NSLog(@"[EPAY ERROR] %@", error);
}

@end
