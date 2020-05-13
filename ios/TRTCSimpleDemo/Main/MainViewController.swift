//
//  MainViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import React
@objc(MainViewController)
class MainViewController: UIViewController {

    override func loadView() {
        let jsCodeLocation = URL(string: "http://169.254.87.133:8081/index.bundle?platform=ios")
        let rootView = RCTRootView(
            bundleURL: jsCodeLocation!,
            moduleName: "MainView",
            initialProperties: nil,
            launchOptions: nil
        )
        super.viewDidLoad()
        self.view = rootView
    }

    @IBAction func onRTCClicked(_ sender: UIButton) {
        presentStoryboard("RTC")
    }
    
    @IBAction func onLiveClicked(_ sender: UIButton) {
        presentStoryboard("Live")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         navigationController?.setNavigationBarHidden(true, animated: true)
     }
    
    @objc(presentStoryboard:)
    func presentStoryboard(_ name: String) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard.init(name: name, bundle: nil)
            let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
            guard let vc = storyboard.instantiateInitialViewController() else { return }
            appDelegate.nav?.pushViewController(vc, animated: true)
        }
    }
    
    @objc static func requiresMainQueueSetup()->Bool{
      return true
    }
    
}
