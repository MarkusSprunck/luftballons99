//
//  ViewController.swift
//  track3d
//
//  Created by Markus Sprunck on 19.10.16.
//  Copyright © 2016-2017 Markus Sprunck. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {

    private var urlHome :URL!
    
    private var isRunning = false
    
    private var webKitView = WKWebView()
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var webViewPlaceholder: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var pauseButton: UIBarButtonItem!
    @IBOutlet var resetButton: UIBarButtonItem!
    
    @IBAction func playButton(_ sender: AnyObject) {
        webKitView.evaluateJavaScript("startGame()")
        isRunning = true
        playButton.isEnabled = false
        pauseButton.isEnabled = true
        resetButton.isEnabled = true
    }
    
    @IBAction func pauseButton(_ sender: AnyObject) {
        webKitView.evaluateJavaScript("stopGame()")
        isRunning = false
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = true
    }
    
    @IBAction func resetButton(_ sender: AnyObject) {
        let _ = webKitView.reload()
        webKitView.evaluateJavaScript("resetGame()")
        isRunning = false
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = false
    }
   
    
    override func loadView() {
        super.loadView()
         self.view.addSubview(webKitView)
        
        webViewPlaceholder.contentMode = .scaleAspectFit
        
        let contentController = WKUserContentController();
        
        contentController.addUserScript(WKUserScript(
            source: "startGame()",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
            )
        )
        contentController.addUserScript(WKUserScript(
            source: "stopGame()",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
            )
        )
        contentController.addUserScript(WKUserScript(
            source: "resetGame()",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
            )
        )
        
        contentController.add(
            self as WKScriptMessageHandler,
            name: "callbackHandler"
        )
        
        // Javascript that disables pinch-to-zoom by inserting the HTML viewport meta tag into <head>
        let source: NSString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=0.5, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);" as NSString;
        let script: WKUserScript = WKUserScript(source: source as String, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        // Create the user content controller and add the script to it
        contentController.addUserScript(script)
        
  
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        
        self.webKitView = WKWebView(
            frame: self.webViewPlaceholder.frame,
            configuration: config
        )
        
        self.view.addSubview(self.webKitView)
        
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.urlHome = Bundle.main.url(forResource: "home", withExtension:"html")
        print("url=\(self.urlHome)")
        
        let requestObj = NSURLRequest(url: urlHome);
        webKitView.load(requestObj as URLRequest);
        webKitView.evaluateJavaScript("resetGame()")
        
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = false
        
        //Register for the applicationWillResignActive anywhere in your app.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: UIApplication.shared)

    }

    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            statusLabel.text = "\(message.body)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        webKitView.frame = CGRect(x: 0, y: 45, width: self.view.frame.height, height: self.view.frame.width-90 )
    }
    
    func applicationWillResignActive(notification: NSNotification) {
        webKitView.evaluateJavaScript("stopGame()")
        isRunning = false
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = true
    }
   
}
