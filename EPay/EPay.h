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


#import <Foundation/Foundation.h>


typedef enum {
    CURRENY_DKK = 208,
    CURRENCY_USD = 840
} Currency;


@class EPay;


@protocol EPayDelegate<NSObject>

@required

- (void)begunProcessingPayment:(NSDictionary*)paymentParameters;
- (void)didProcessPayment:(NSDictionary*)successParameters;
- (void)paymentFailed:(NSError*)error;

@end


@interface EPay : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) Currency currency;
@property (strong, nonatomic) NSString *merchantNumber;
@property (strong, nonatomic) NSString *md5Secret;
@property (strong, nonatomic) id<EPayDelegate> delegate;
@property (strong, readonly, nonatomic) NSString *subscription;
@property (strong, readonly, nonatomic) NSString *amount;
@property (strong, readonly, nonatomic) NSString* orderID;

+ (EPay*)ePayWithMerchantNumber:(NSString*)merchantNumber md5Secret:(NSString*)md5Secret currency:(Currency)currency;

- (void)makePaymentWithOrderID:(NSString*)orderID
                        amount:(NSString*)amount
                    cardNumber:(NSString*)cardNumber
                   expiryMonth:(NSString*)expiryMonth
                    expiryYear:(NSString*)expiryYear
                           CVC:(NSString*)CVC
                  subscription:(NSString*)subscription;

@end