//
//  Bill
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import Foundation
import CoreData

class Bill: NSManagedObject {

    @NSManaged var amount: NSNumber
    @NSManaged var timeStamp: NSDate
    @NSManaged var title: String?
    @NSManaged var identifier: NSNumber
    @NSManaged var friend: OgoriLog.Friend

}
