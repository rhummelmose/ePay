ePay
====

Easy to use Objective-C library for the payment gateway ePay.

Instructions
------------

1.  Add EPay.h/EPay.m to your project.
2.  Include them whereever your plan on processing payments.
3.  Implement its delegate protocol.
4.  Instantiate EPay and set its delegate.
5.  Process payments!

Code Snippets
-------------

### Example payment

    // We create an ePay object.
    EPay *ePay = [EPay ePayWithMerchantNumber:@"Your Merchant Number" md5Secret:@"Your MD5 Secret(Pass nil if you wish not to use MD5 hashing)" currency:CURRENY_DKK];
    
    // We set ourselves as the delegate and perform a payment.
    ePay.delegate = self;
    [ePay makePaymentWithOrderID:@"1" amount:@"10000" cardNumber:@"4444444444444000" expiryMonth:@"01" expiryYear:@"15" CVC:@"666" subscription:nil];

### Example delegate implementation

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

Contact
-------

If you have questions or anything on your mind, you can reach me at
*   Twitter: rasmus_th
*   Email: rasmus@hummelmose.dk