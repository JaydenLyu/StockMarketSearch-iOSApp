//
//  NewsViewController.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 5/1/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var newsTableView: UITableView!
    
    var newsItems: Array<NSDictionary> = Array<NSDictionary>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print ("*** news feed view controller loaded ***")
        
        MainProcess.getData("newsQuery", requestSymbol: MyVariables.currentStock) {data, error -> Void in
            if (data != nil) {
//                print(data)
                self.newsItems = data["d"]!["results"] as! [NSDictionary]
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.newsTableView!.reloadData()
                }
            } else {
                print(error)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if newsItems.count == 0 {
            return UITableViewCell()
        }
        else {
            let newsCell = tableView.dequeueReusableCellWithIdentifier("newsFeedCell", forIndexPath: indexPath) as! NewsFeedCell
            newsCell.title.text = String(newsItems[indexPath.row]["Title"]!)
            newsCell.detail.text = String(newsItems[indexPath.row]["Description"]!)
            newsCell.source.text = String(newsItems[indexPath.row]["Source"]!)
//             String(newsItems[indexPath.row]["Date"]!)
            
            let formatter1 = NSDateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let orgDate = formatter1.dateFromString(String(newsItems[indexPath.row]["Date"]!))
            let formatter2 = NSDateFormatter()
            formatter2.dateFormat = "yyyy-MM-dd HH:mm"
            let outDateString = formatter2.stringFromDate(orgDate!)
            newsCell.date.text = outDateString
            
            newsCell.layoutMargins = UIEdgeInsetsZero
            return newsCell
        }
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let link:String = String(newsItems[indexPath.row]["Url"]!) {
            let url = NSURL(string:link)
            UIApplication.sharedApplication().openURL(url!)
        }
    }

}
