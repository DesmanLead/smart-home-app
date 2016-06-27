//
//  DeviceTableCell.swift
//  SmartHome
//
//  Created by Artem Kirienko on 27.06.16.
//  Copyright © 2016 Desman. All rights reserved.
//

import Foundation
import UIKit


class DeviceTableCell: UITableViewCell {
    
    var deviceName: String? {
        get {
            return nameLabel?.text
        }
        set {
            nameLabel?.text = newValue
        }
    }
    
    var deviceEnabled: Bool {
        get {
            return isEnabledSwitch.on
        }
        set {
            isEnabledSwitch.on = newValue
        }
    }
    
    var onDeviceEnabled: ((Bool) -> Void)?
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var isEnabledSwitch: UISwitch!
    
    @IBAction func onSwitch(sender: UISwitch, forEvent event: UIEvent) {
        onDeviceEnabled?(sender.on)
    }
}