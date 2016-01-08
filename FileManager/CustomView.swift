//
//  CustomView.swift
//  FileManager
//
//  Created by Vineeth Vijayan on 22/12/15.
//  Copyright © 2015 Vineeth Vijayan. All rights reserved.
//

import UIKit

@IBDesignable class CustomView: UIView {
    
    @IBOutlet weak var myTextView: UITextView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    // Our custom view from the XIB file
    var view: UIView!
    
    @IBAction func micBtnTapped(sender: AnyObject) {
        print("micBtnTapped")
        let vc = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("CommentsDetailedViewController") as! CommentsDetailedViewController
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.parentViewController!.presentViewController(nav, animated: true, completion: nil)
        
    }
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        
        myTextView.clipsToBounds = true;
        myTextView.layer.cornerRadius = 10.0;

        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CustomView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    

}
