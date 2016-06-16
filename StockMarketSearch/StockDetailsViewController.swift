//
//  StockDetailsViewController.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 5/1/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import UIKit

class StockDetailsViewController: UIViewController {
    
    var stock:String = ""   // init by segue
    
    @IBOutlet weak var currentView: UIView!
    
    @IBOutlet weak var historicalView: UIView!
    
    @IBOutlet weak var newsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print ("*** stock details view controller loaded ***")
        self.navigationItem.title = stock
        currentView.hidden = false
        historicalView.hidden = true
        newsView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        let index:Int = sender.selectedSegmentIndex
        if index == 0 {
            currentView.hidden = false
            historicalView.hidden = true
            newsView.hidden = true
        } else if index == 1 {
            currentView.hidden = true
            historicalView.hidden = false
            newsView.hidden = true
        } else if index == 2 {
            currentView.hidden = true
            historicalView.hidden = true
            newsView.hidden = false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
