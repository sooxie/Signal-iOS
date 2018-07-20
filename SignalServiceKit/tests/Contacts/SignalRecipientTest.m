//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "SignalRecipient.h"
#import "OWSPrimaryStorage.h"
#import "TSAccountManager.h"

//#import "TSStorageManager+keyingMaterial.h"
#import <XCTest/XCTest.h>

@interface TSAccountManager (Testing)

- (void)storeLocalNumber:(NSString *)localNumber;

@end

@interface SignalRecipientTest : XCTestCase

@property (nonatomic) NSString *localNumber;

@end

@implementation SignalRecipientTest

- (void)setUp
{
    [super setUp];
    self.localNumber = @"+13231231234";
    [[TSAccountManager sharedInstance] storeLocalNumber:self.localNumber];
}

- (void)testSelfRecipientWithExistingRecord
{
    // Sanity Check
    XCTAssertNotNil(self.localNumber);

    [OWSPrimaryStorage.sharedManager.dbReadWriteConnection
        readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [SignalRecipient markRecipientAsRegisteredAndGet:self.localNumber transaction:transaction];

            XCTAssertTrue([SignalRecipient isRegisteredRecipient:self.localNumber transaction:transaction]);

            SignalRecipient *me = [SignalRecipient selfRecipientWithTransaction:transaction];
            XCTAssertNotNil(me);
            XCTAssertEqualObjects(self.localNumber, me.uniqueId);
        }];
}

- (void)testSelfRecipientWithoutExistingRecord
{
    XCTAssertNotNil(self.localNumber);

    [OWSPrimaryStorage.sharedManager.dbReadWriteConnection
        readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [[SignalRecipient fetchObjectWithUniqueID:self.localNumber] removeWithTransaction:transaction];

            XCTAssertFalse([SignalRecipient isRegisteredRecipient:self.localNumber transaction:transaction]);

            SignalRecipient *me = [SignalRecipient selfRecipientWithTransaction:transaction];
            XCTAssertNil(me);
            XCTAssertEqualObjects(self.localNumber, me.uniqueId);
        }];
}

@end
