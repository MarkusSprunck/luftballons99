//
//  ViewController.swift
//  track3d
//
//  Created by Markus Sprunck on 19.10.16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {
  
    
    @IBOutlet weak var webViewPlaceholder: UIView!
  
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    @IBAction func playButton(_ sender: AnyObject) {
        webKitView?.evaluateJavaScript("startGame()")
        isRunning = true
        playButton.isEnabled = false
        pauseButton.isEnabled = true
        resetButton.isEnabled = true
    }

    @IBAction func pauseButton(_ sender: AnyObject) {
        webKitView?.evaluateJavaScript("stopGame()")
        isRunning = false
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = true
    }
    
    @IBAction func resetButton(_ sender: AnyObject) {
        let _ = webKitView?.reload()
        webKitView?.evaluateJavaScript("resetGame()")
        isRunning = false
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = false
    }
   
    private var urlHome :URL!
    
    private var isRunning = false
 
    private var webKitView: WKWebView?

    @IBOutlet var containerView: UIView!
    
    override func loadView() {
        super.loadView()
        
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
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webKitView = WKWebView(
            frame: self.webViewPlaceholder.frame,
            configuration: config
        )
       
        self.view.addSubview(self.webKitView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.urlHome = Bundle.main.url(forResource: "home", withExtension:"html")
        print("url=\(self.urlHome)")
        
        let requestObj = NSURLRequest(url: urlHome);
        webKitView!.load(requestObj as URLRequest);
        webKitView?.evaluateJavaScript("resetGame()")
        
        
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        resetButton.isEnabled = false
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
    


}

