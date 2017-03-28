//
//  ActivityCell.swift
//  SmartHome
//
//  Created by Artem Kirienko on 28.03.17.
//  Copyright © 2017 Desman. All rights reserved.
//

import Foundation
import UIKit

class ActivityCell: UITableViewCell
{
    var activityName: String?
    {
        get
        {
            return nameLabel?.text
        }
        set
        {
            nameLabel?.text = newValue
        }
    }
    
    var activityStarted: Bool
    {
        get
        {
            return isStartedSwitch.isOn
        }
        set
        {
            isStartedSwitch.isOn = newValue
        }
    }
    
    var onActivityStarted: (() -> Void)?
    var onActivityFinished: (() -> Void)?
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var isStartedSwitch: UISwitch!
    
    @IBAction func onSwitch(_ sender: UISwitch, forEvent event: UIEvent)
    {
        if sender.isOn
        {
            onActivityStarted?()
        }
        else
        {
            onActivityFinished?()
        }
    }
}
