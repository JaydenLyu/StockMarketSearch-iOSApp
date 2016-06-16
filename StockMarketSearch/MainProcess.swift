//
//  MainProcess.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 4/30/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import Foundation

class MainProcess {
    
    static let server:String = "http://storied-coil-127205.appspot.com/"
    
    // sync get data and return
    class func httpRequest(requestType:String, requestSymbol:String) -> Array<AnyObject> {
        
        var requestSymbol = requestSymbol.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if requestSymbol == "" {
            return []
        }
        let charSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        requestSymbol = requestSymbol.stringByAddingPercentEncodingWithAllowedCharacters(charSet)!
        
        let urlPath:String = "\(self.server)?\(requestType)=\(requestSymbol)"
        let url = NSURL(string: urlPath)!
        var jsonArray:Array<AnyObject> = [[String:String]]()
        let semaphore = dispatch_semaphore_create(0)   // synchronized counting semaphore; 0: synchronized
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print(error)
                return
            }
            do {
                jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! [[String: String]]
                dispatch_semaphore_signal(semaphore)
            } catch {
                print(error)
            }
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//        print(jsonArray)
        return jsonArray
    }
    
    class func httpRequestDict(requestType:String, requestSymbol:String) -> NSDictionary {
        
        let urlPath:String = "\(self.server)?\(requestType)=\(requestSymbol)"
        let url = NSURL(string: urlPath)!
        var json:NSDictionary = NSDictionary()
        let semaphore = dispatch_semaphore_create(0)   // synchronized counting semaphore; 0: synchronized
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print(error)
                return
            }
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! NSDictionary
                dispatch_semaphore_signal(semaphore)
            } catch {
                print(error)
            }
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return json
    }
    
    // get data with completionHandler
    class func getData(requestType:String, requestSymbol:String, completionHandler: ((NSDictionary!, NSError!) -> Void)!) -> Void {
        let urlPath:String = "\(self.server)?\(requestType)=\(requestSymbol)"
        let url = NSURL(string: urlPath)!
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                return completionHandler(nil, error)
            }

            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            if (error != nil) {
                return completionHandler(nil, error)
            } else {
                return completionHandler(json, nil)
            }
        })
        task.resume()
    }
    
    
    // next 3 funcs: async get data and process
    
//    func createStockDetails(requestSymbol:String) {
//        
//    }
//    
//    func cerateHistoricalChart(requestSymbol:String) {
//        
//    }
//    
//    func createNewsFeed(requestSymbol:String) {
//        
//    }
    
}
