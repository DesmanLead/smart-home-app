//
//  Beacon.swift
//  SmartHome
//
//  Created by Artem Kirienko on 30.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import Foundation

class Beacon {
    let name: String
    let uuid: String
    
    init(name: String, uuid: String) {
        self.name = name
        self.uuid = uuid
    }
}