//
//  CurrentViewController.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 5/1/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class CurrentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FBSDKSharingDelegate {
    
    var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var yahooChart: UIImageView!
    
    @IBOutlet var star: UIButton!
    
    @IBAction func starClicked(sender: AnyObject) {
        
        let isFavorite = isInFavoriteList()
        if !isFavorite {
            addCurrentStock()
            star.setImage(UIImage(named: "Star-Filled-50"), forState: UIControlState.Normal)
        } else {
            deleteCurrentStock()
            star.setImage(UIImage(named: "Star-50"), forState: UIControlState.Normal)
        }
        
    }
    
//    var stocks = [NSManagedObject]()  // object instance for core data

    var items: NSDictionary = NSDictionary()
//    self.stockDetailsCell.cellLayoutMarginsFollowReadableWidth = NO

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print ("*** current view controller loaded ***")
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            managedContext = appDelegate.managedObjectContext
        }
        if isInFavoriteList() {
            star.setImage(UIImage(named: "Star-Filled-50"), forState: UIControlState.Normal)
        }
        
        MainProcess.getData("symbol", requestSymbol: MyVariables.currentStock) {data, error -> Void in
            if (data != nil) {
//                print(data)
                self.items = data
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.tableView!.reloadData()
                    self.loadYahooChart()
                }
//                let change:String = String(data["Change"]!)
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
    
    func addCurrentStock() {
        
        let entityDescription = NSEntityDescription.entityForName("FavoriteStocks", inManagedObjectContext: managedContext)
        let stock = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: managedContext)
        stock.setValue(MyVariables.currentStock, forKey: "symbol")
        do {
            try managedContext.save()
        } catch {
            print("error")
        }
    }
    
    func deleteCurrentStock() {
        
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("FavoriteStocks", inManagedObjectContext: managedContext)
        fetchRequest.entity = entityDescription
        
        var result = [NSManagedObject]()
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch {
            print("fetchError")
        }
        // if current stock is in favorite list and then delete
        if result.count > 0 {
            for (i, item) in result.enumerate() {
                let itemSymbol = item.valueForKey("symbol") as! String
                if itemSymbol == MyVariables.currentStock {
                    managedContext.deleteObject(result[i] as NSManagedObject)
                    do {
                        try managedContext.save()
                    } catch {
                        print("error")
                    }
                }
            }
        }

    }
    
    // check whether the current stock is in favorite list
    func isInFavoriteList() -> Bool {

        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("FavoriteStocks", inManagedObjectContext: managedContext)
        fetchRequest.entity = entityDescription
        
        var result = [NSManagedObject]()
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch {
            print("fetchError")
        }
        // if current stock is in favorite list and then delete
        if result.count > 0 {
            for item in result {
                let itemSymbol = item.valueForKey("symbol") as! String
                if itemSymbol == MyVariables.currentStock {
                    return true
                }
            }
        }
        return false

    }
    
    // implement facebook share function
    @IBAction func FBShareClicked(sender: AnyObject) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentTitle = "Current Stock Price of " + String(items["Name"]!) + " is $" + String(format: "%.2f", Double(String(items["LastPrice"]!))!)
        content.contentDescription = "Stock Information of " + String(items["Name"]!) + " (" + String(items["Symbol"]!) + ")"
        content.imageURL = NSURL(string: "http://chart.finance.yahoo.com/t?s=" + String(items["Symbol"]!)+"&lang=en-US&width=300&height=300")
        content.contentURL = NSURL(string: "http://finance.yahoo.com/q?s=" + String(items["Symbol"]!))
        
//        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
        let shareDialog = FBSDKShareDialog()
        shareDialog.fromViewController = self
        shareDialog.shareContent = content
        shareDialog.delegate = self
        shareDialog.mode = FBSDKShareDialogMode.FeedBrowser
        shareDialog.show()
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]) {
        if results.count == 0 {
            presentAlertWithTitle("Not Posted")
        } else {
            presentAlertWithTitle("Posted Successfully")
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        presentAlertWithTitle("Posted Error")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        presentAlertWithTitle("Not Posted")
    }
    
    
    func presentAlertWithTitle(msg:String) {
        let alert:UIAlertController =  UIAlertController(title: msg, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (a: UIAlertAction) in
        })
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if items.allKeys.count == 0 {
            return UITableViewCell()
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("stockDetailsCell", forIndexPath: indexPath) as! StockDetailsCell
            
            switch indexPath.row {
            case 0:
                cell.label1.text = "Name"
                cell.label2.text = String(items["Name"]!)
            case 1:
                cell.label1.text = "Symbol"
                cell.label2.text = String(items["Symbol"]!)
            case 2:
                cell.label1.text = "Last Price"
                cell.label2.text = "$ " + String(format: "%.2f", Double(String(items["LastPrice"]!))!)
            case 3:
                cell.label1.text = "Change"
                let change = String(format: "%.2f", Double(String(items["Change"]!))!)
                let changePercent = String(format: "%.2f", Double(String(items["ChangePercent"]!))!)
                if (Double(change) > 0) {
                    cell.label2.text = "+" + change + "(" + changePercent + "%)"
                    cell.img.image = UIImage(named: "Up-52.png")
                } else if (Double(change) == 0) {
                    cell.label2.text = change + "(" + changePercent + "%)"
                } else {
                    cell.label2.text = change + "(" + changePercent + "%)"
                    cell.img.image = UIImage(named: "Down-52.png")
                }
            case 4:
                let formatter1 = NSDateFormatter()
                formatter1.dateFormat = "EEE MMM d HH:mm:ss zzz yyyy"
                let orgDate = formatter1.dateFromString(String(items["Timestamp"]!))
                let formatter2 = NSDateFormatter()
                formatter2.dateFormat = "MMM d yyyy HH:mm"
                let outDateString = formatter2.stringFromDate(orgDate!)
                cell.label1.text = "Time and Date"
                cell.label2.text = outDateString
            case 5:
                cell.label1.text = "Market Cap"
                let cap = Double(String(items["MarketCap"]!))
                if cap > 1000000000 {
                    let capString = String(format: "%.2f", (cap! / 1000000000))
                    cell.label2.text = capString + " Billion"
                }
                else if cap > 1000000 {
                    let capString = String(format: "%.2f", (cap! / 1000000))
                    cell.label2.text = capString + " Million"
                }
                else {
                    cell.label2.text = String(cap)
                }
            case 6:
                cell.label1.text = "Volume"
                cell.label2.text = String(items["Volume"]!)
            case 7:
                cell.label1.text = "Change YTD"
                let changeYTD = String(format: "%.2f", Double(String(items["ChangeYTD"]!))!)
                let changePercentYTD = String(format: "%.2f", Double(String(items["ChangePercentYTD"]!))!)
                if (Double(changeYTD) > 0) {
                    cell.label2.text = "+" + changeYTD + "(" + changePercentYTD + "%)"
                    cell.img.image = UIImage(named: "Up-52.png")
                } else if (Double(changeYTD) == 0){
                    cell.label2.text = changeYTD + "(" + changePercentYTD + "%)"
                } else {
                    cell.label2.text = changeYTD + "(" + changePercentYTD + "%)"
                    cell.img.image = UIImage(named: "Down-52.png")
                }
                
            case 8:
                cell.label1.text = "High Price"
                cell.label2.text = "$ " + String(format: "%.2f", Double(String(items["High"]!))!)            case 9:
                cell.label1.text = "Low Price"
                cell.label2.text = "$ " + String(format: "%.2f", Double(String(items["Low"]!))!)
            case 10:
                cell.label1.text = "Opening Price"
                cell.label2.text = "$ " + String(format: "%.2f", Double(String(items["Open"]!))!)
                
            default:
                cell.label1.text = "Key"
                cell.label2.text = "Value"
            }
            cell.layoutMargins = UIEdgeInsetsZero  // set the table margin to 0
            return cell
        }
    }
    
    func loadYahooChart() {
        if (items.allKeys.count != 0) {
            let imgUrlPath:String = "http://chart.finance.yahoo.com/t?s=" + String(items["Symbol"]!)+"&lang=en-US&width=480&height=360"
            let imgUrl = NSURL(string: imgUrlPath)!
            let data = NSData(contentsOfURL: imgUrl)
            yahooChart.image = UIImage(data: data!)
        }
    }
}

