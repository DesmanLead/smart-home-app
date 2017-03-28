//
//  ActivitiesViewController.swift
//  SmartHome
//
//  Created by Artem Kirienko on 28.03.17.
//  Copyright © 2017 Desman. All rights reserved.
//

import Foundation
import UIKit


class ActivitiesViewController: UITableViewController
{
    private var activities: [Activity] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        self.activities = Database.sharedDatabase.getActivities()
        self.updateUI()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell") as! ActivityCell
        
        let index = indexPath.row
        let activity = activities[index]
        
        cell.activityName = activity.name
        cell.activityStarted = activity.isStarted
        
        cell.onActivityStarted = {
            var updatedActivity = activity
            updatedActivity.isStarted = true
            self.activities[index] = updatedActivity
            Database.sharedDatabase.logActivity(updatedActivity, time: Date.timeIntervalSinceReferenceDate)
            
            self.updateUI()
        }
        
        cell.onActivityFinished = {
            var updatedActivity = activity
            updatedActivity.isStarted = false
            self.activities[index] = updatedActivity
            Database.sharedDatabase.logActivity(updatedActivity, time: Date.timeIntervalSinceReferenceDate)
            
            self.updateUI()
        }
        
        return cell
    }
    
    private func updateUI()
    {
        activities.sort
        {
            lhs, rhs in
            
            if lhs.isStarted == rhs.isStarted
            {
                return lhs.name.compare(rhs.name) == .orderedAscending
            }
            
            return lhs.isStarted
        }
        
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}
