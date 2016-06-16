//
//  HistoricalViewController.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 5/1/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import UIKit

class HistoricalViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var historicalWebView: UIWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print ("*** historical view controller loaded ***")
        
        let localfilePath = NSBundle.mainBundle().URLForResource("historical_chart", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        historicalWebView.delegate = self
        historicalWebView.loadRequest(myRequest);
        
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
    
    func webViewDidFinishLoad(webView: UIWebView) {

        historicalWebView.stringByEvaluatingJavaScriptFromString("$(function(){getHistoricalChart(\"\(MyVariables.currentStock)\")});")

    }

}
