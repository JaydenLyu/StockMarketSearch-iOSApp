//
//  ViewController.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 4/19/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import UIKit
import CCAutocomplete
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var managedContext: NSManagedObjectContext!
    
    var stocks = [NSManagedObject]()  // update in viewWillAppear
    
    var autoRefreshTimer = NSTimer()
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var favoriteListTableView: UITableView!

    @IBOutlet weak var stockSearchTextField: UITextField!
    
    @IBAction func getQuote(sender: AnyObject) {
        stockSearchTextField.resignFirstResponder()
        
        let valid:String = inputValidation(self.stockSearchTextField.text!)
        if valid == "3" {
            // regular process of get quote
            // segue transferred           
            MyVariables.currentStock = self.stockSearchTextField.text!
        }
        // invalid input (alert)
        else {
            var msg = ""
            if valid == "1" {
                msg = "Please Enter a Stock Name or Symbol"
            }
            else if valid == "2" {
                msg = "Invalid Symbol"
            }
            else if valid == "4" {
                msg = "No Stock Details Available"
            }
            let alert:UIAlertController =  UIAlertController(title: msg, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (a: UIAlertAction) in
            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true) {}
        }
   
    }
    
    
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBAction func refresh(sender: AnyObject) {
        updateStocksUsingCoreData()
    }
    
    @IBOutlet weak var autoRefreshSwitch: UISwitch!
    
    @IBAction func autoRefreshSwitchChange(sender: AnyObject) {
        if autoRefreshSwitch.on {
            autoRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(ViewController.updateStocksUsingCoreData), userInfo: nil, repeats: true)
        }
        else {
            autoRefreshTimer.invalidate()
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // create managedContext
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            managedContext = appDelegate.managedObjectContext
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {  // after the viewDidLoad
        self.navigationController?.navigationBarHidden = true
        updateStocksUsingCoreData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    
    func updateStocksUsingCoreData() {
        
//        self.refreshButton.enabled = false
//        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(ViewController.enableButton), userInfo: nil, repeats: false)
        activityIndicator.startAnimating()
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), { () -> Void in
       
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
        
            let fetchRequest = NSFetchRequest()
            let entityDescription = NSEntityDescription.entityForName("FavoriteStocks", inManagedObjectContext: self.managedContext)
            fetchRequest.entity = entityDescription
            
            var result = [NSManagedObject]()
            do {
                result = try self.managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
                
            } catch {
                print("fetchError")
            }
            self.stocks = result
            
            // reload the table each time the page will appear
            self.favoriteListTableView.reloadData()
            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.performSelector(#selector(self.stopAnimation), withObject: nil, afterDelay: 1.0)
        
//            })
//        })
//        self.refreshButton.enabled = true
//        activityIndicator.stopAnimating()
        activityIndicator.performSelector(#selector(stopAnimation), withObject: nil, afterDelay: 1.0)
        
    }
    
    func enableButton() {
        self.refreshButton.enabled = true
    }
    
    func stopAnimation() {
        activityIndicator.stopAnimating()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "favoriteSegue" {
            let index = favoriteListTableView.indexPathForSelectedRow?.row
            let selectedSymbol = String(stocks[index!].valueForKey("symbol")!)
            MyVariables.currentStock = selectedSymbol
            let detail:StockDetailsViewController = segue.destinationViewController as! StockDetailsViewController
            detail.stock = selectedSymbol
        }
        else {
            let valid:String = inputValidation(self.stockSearchTextField.text!)
            if valid == "3" {
                let detail:StockDetailsViewController = segue.destinationViewController as! StockDetailsViewController
                detail.stock = self.stockSearchTextField.text!
                print("*** segue transferred ***")
            }
        }
        
    }
    
    func inputValidation(symbol: String) -> String {
        
        if symbol == "" {
            return "1"  // "1" represents no input
        }
        else {
            let data = MainProcess.httpRequest("query", requestSymbol: self.stockSearchTextField.text!)
            for item in data {
                if item["Symbol"] as? String == self.stockSearchTextField.text {
                    let sym = MainProcess.httpRequestDict("symbol", requestSymbol: self.stockSearchTextField.text!)
                    if String(sym["Status"]!) != "SUCCESS" {
                        return "4"  // no stock details
                    }
                    return "3"  // correct
                }
            }
        }
        return "2"  // "2" represents invalid symbol
    }
    
    
    // table created after the viewWillAppear
    // create favorite list table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if stocks.count == 0 {
            let cell = UITableViewCell()
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteListCell", forIndexPath: indexPath) as! FavoriteListCell
        let symbol = String(stocks[indexPath.row].valueForKey("symbol")!)
        cell.symbol.text = symbol
        
        let symbolDetails = MainProcess.httpRequestDict("symbol", requestSymbol: symbol)
        
        cell.price.text = "$ " + String(format: "%.2f", Double(String(symbolDetails["LastPrice"]!))!)
        
        let change = String(format: "%.2f", Double(String(symbolDetails["Change"]!))!)
        let changePercent = String(format: "%.2f", Double(String(symbolDetails["ChangePercent"]!))!)
        if (Double(change) > 0) {
            cell.change.text = "+" + change + "(" + changePercent + "%)"
            cell.change.textColor = UIColor.whiteColor()
            let greenColor = UIColor(red: 50/255, green: 173/255, blue: 100/255, alpha: 1)
            cell.change.backgroundColor = greenColor
        } else if (Double(change) == 0) {
            cell.change.text = change + "(" + changePercent + "%)"
        } else {
            cell.change.text = change + "(" + changePercent + "%)"
            cell.change.textColor = UIColor.whiteColor()
            let redColor = UIColor(red: 215/255, green: 70/255, blue: 65/255, alpha: 1)
            cell.change.backgroundColor = redColor
        }
        
        cell.name.text = String(symbolDetails["Name"]!)
        
        let cap = Double(String(symbolDetails["MarketCap"]!))
        if cap > 1000000000 {
            let capString = String(format: "%.2f", (cap! / 1000000000))
            cell.cap.text = "Market Cap: " + capString + " Billion"
        }
        else if cap > 1000000 {
            let capString = String(format: "%.2f", (cap! / 1000000))
            cell.cap.text = "Market Cap: " + capString + " Million"
        }
        else {
            cell.cap.text = "Market Cap: " + String(cap)
        }

        cell.layoutMargins = UIEdgeInsetsZero
        return cell

    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("favoriteSegue", sender: nil)
    }
    
    
    // swipe to delete selected item in core data
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            managedContext.deleteObject(stocks[indexPath.row] as NSManagedObject)
            stocks.removeAtIndex(indexPath.row)
            do {
                try managedContext.save()
            } catch {
                print("error to delete")
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }


}


// Autocomplete
extension ViewController: AutocompleteDelegate {
    func autoCompleteTextField() -> UITextField {
        return self.stockSearchTextField
    }
    
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 2
    }
    
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        
        var term = term.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if term == "" {
            return []
        }
        let charSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        term = term.stringByAddingPercentEncodingWithAllowedCharacters(charSet)!
        
        let urlPath:String = "http://storied-coil-127205.appspot.com/?query=" + term
        let url = NSURL(string: urlPath)!
        var jsonArray = [[String:String]]()
        let semaphore = dispatch_semaphore_create(0)   // synchronized counting semaphore; 0: synchronized
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in

            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print(error)
                return
            }
            do {
//                _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
                jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! [[String: String]]
                dispatch_semaphore_signal(semaphore)
            } catch {
                print(error)
            }
        }
        task.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//        print (jsonArray)
        
        var cells = [String]()
        for item in jsonArray {
            let tempStr: String = item["Symbol"]! + " - " + item["Name"]! + " - " + item["Exchange"]!
            cells += [tempStr];
        }

        let lookedUpStocks: [AutocompletableOption] = cells.map { filteredStocks -> AutocompleteCellData in
            return AutocompleteCellData(text: filteredStocks, image: nil)
            }.map( { $0 as AutocompletableOption })
        
        return lookedUpStocks
    }
    
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame) / 2.8
    }
    
    func didSelectItem(item: AutocompletableOption) {
        var symbol = ""
        for c in item.text.characters {
            if c != " " {
                symbol.append(c)
            }
            else {
                break
            }
        }
        self.stockSearchTextField.text = symbol
    }
    
    func heightForCells() -> CGFloat {
        return 34
    }
}
