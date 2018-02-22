//
//  ViewController.swift
//
//  Created by Markus Sprunck on 19.10.2016
//  Copyright © 2016-2018 Markus Sprunck. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {
    
    private var isRunning               = false
    
    private var webKitView              = WKWebView()
    
    @IBOutlet var containerView         : UIView!
    
    @IBOutlet var webViewPlaceholder    : UIView!
    
    @IBOutlet var statusLabel           : UILabel!
    
    @IBOutlet var playButton            : UIBarButtonItem!
    
    @IBOutlet var pauseButton           : UIBarButtonItem!
    
    @IBOutlet var resetButton           : UIBarButtonItem!
    
    /**
     Event handler - Play Button pressed
     */
    @IBAction func playButton(_ sender: AnyObject) {
        webKitView.evaluateJavaScript("startGame()")
        isRunning = true
        playButton.isEnabled = false
        pauseButton.isEnabled = true
        resetButton.isEnabled = true
    }
    
    /**
     Event handler - Pause Button pressed
     */
    @IBAction func pauseButton(_ sender: AnyObject) {
        webKitView.evaluateJavaScript("stopGame()")
        isRunning = false
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = true
    }
    
    /**
     Event handler - Reset Button pressed
     */
    @IBAction func resetButton(_ sender: AnyObject) {
        let _ = webKitView.reload()
        webKitView.evaluateJavaScript("resetGame()")
        isRunning = false
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = false
    }
    
    /**
     Called after the view controller’s view has been loaded into memory.
     Here the WKWebView (html content view) is initialized and the call-
     back methods are registered.
     */
    override func loadView() {
        super.loadView()
        self.view.addSubview(webKitView)
        
        webViewPlaceholder.contentMode = .scaleAspectFit
        
        // Provides a way for JavaScript to post messages
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
            name: "callbackHandlerStatusLabel"
        )
        contentController.add(
            self as WKScriptMessageHandler,
            name: "callbackHandlerLogging"
        )
        
        // Inserting code into the HTML viewport meta tag <head>
        let source: NSString = """
                                var meta        = document.createElement('meta');
                                meta.name       = 'viewport';
                                meta.content    = 'width=device-width, initial-scale=0.5, maximum-scale=1.0, user-scalable=no';
                                var head        = document.getElementsByTagName('head')[0];
                                head.appendChild(meta);
                                """ as NSString;
        let script: WKUserScript = WKUserScript(source           : source as String,
                                                injectionTime    : .atDocumentEnd,
                                                forMainFrameOnly : true)
        contentController.addUserScript(script)
        
        // Create contiguration for web view
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // Create web view
        self.webKitView = WKWebView(
            frame: self.webViewPlaceholder.frame,
            configuration: config
        )
        
        // Show web view
        self.view.addSubview(self.webKitView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load HTML page and reset
        let urlHome : URL = Bundle.main.url(forResource: "main", withExtension:"html")!
        let requestObj = NSURLRequest(url: urlHome);
        webKitView.load(requestObj as URLRequest);
        webKitView.evaluateJavaScript("resetGame()")
        
        // Set UI state to start game
        playButton.isEnabled  = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = false
        
        // Register for the applicationWillResignActive anywhere in your app.
        NotificationCenter.default.addObserver(self,
            selector: #selector(ViewController.applicationWillResignActive(notification:)),
            name    : NSNotification.Name.UIApplicationWillResignActive,
            object  : UIApplication.shared)
    }
    
    /**
     Called when the app is about to become inactive
     */
    @objc func applicationWillResignActive(notification: NSNotification) {
        webKitView.evaluateJavaScript("stopGame()")
        isRunning = false
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = true
    }
    
    /**
     Called from JavaScript code in main.html
     */
    func userContentController(_ userContentController  : WKUserContentController,
                                 didReceive message     : WKScriptMessage) {
        
        if message.name == "callbackHandlerStatusLabel" {
            statusLabel.text = "\(message.body)"
        }
        
        if message.name == "callbackHandlerLogging" {
            print("callbackHandlerLogging -> \(message.body)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Hide the status line with battery, time, etc.
     */
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /**
     Notifies the container that the size of its view is about to change.
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        webKitView.frame = CGRect(x: 0, y: 45, width: self.view.frame.height, height: self.view.frame.width-90 )
    }
    
    
    /**
     Force portrait modus
     */
    override  open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }
}
