//
//  PDFViewerControllerViewController.swift
//  FileManager
//
//  Created by Vineeth Vijayan on 04/01/16.
//  Copyright © 2016 Vineeth Vijayan. All rights reserved.
//

import UIKit
import SwiftFilePath

class PDFViewerControllerViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    let mainDir = "fileMangerDir"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        //let pdf = NSURL(fileURLWithPath: Path.documentsDir[mainDir]["temp.pdf"].toString(), isDirectory: false)
        
        let pdf = NSURL(fileURLWithPath: TabletoPDFTableViewController.outPutPDF)
        
        let req = NSURLRequest(URL: pdf)
//        let webView = UIWebView(frame: CGRectMake(20,20,self.view.frame.size.width-40,self.view.frame.size.height-40))
//        webView.loadRequest(req)
//        self.view.addSubview(webView)

        webView.loadRequest(req)
    }

    @IBAction func btnShareTapped(sender: AnyObject) {
        
        let pdf = NSURL(fileURLWithPath: TabletoPDFTableViewController.outPutPDF)
        
        let objectsToShare = ["", pdf]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            activityVC.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        }
        self.presentViewController(activityVC, animated: true, completion: nil)
        
    }
    @IBAction func btnDismissedTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

}
