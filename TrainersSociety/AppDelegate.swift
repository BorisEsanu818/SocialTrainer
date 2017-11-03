//
//  AppDelegate.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 12/25/16.
//  Copyright © 2016 Trainers Society. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import Crashlytics
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

    var window: UIWindow?
    var indicator = UIActivityIndicatorView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "cafa43ca-4fca-4cf9-a31b-e5ff5ddd524d")
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        addIndicator()
        showIndicator()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        /* check for user's token */
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            /* Code to go through to menu */
            GIDSignIn.sharedInstance().signInSilently()
        } else {
            /* code to show your login VC */
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        }
        
        //Check if User w/ Email Login is Logged In
        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            let email = userInformation["email"] as! String
            let password = userInformation["password"] as! String
            User.loginUser(withEmail: email, password: password, completion: { [weak weakSelf = self] (status) in
                DispatchQueue.main.async {
                    if status == true {
                        let vc = UIStoryboard(name: "Menu", bundle: nil).instantiateInitialViewController()
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = vc
                    }
                    weakSelf = nil
                }
            })
        }

        
        // FB Silent Login
        if let accessToken = FBSDKAccessToken.current() {
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    
                    return
                }
                
                DBProvider.Instance.usersRef.child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let snapshot = snapshot.value as? NSDictionary
                    
                    if(snapshot == nil)
                    {
                        DBProvider.Instance.saveUser(withID: user!.uid, name: user!.displayName!, email: user!.email!)
                        
                    }
                    // Present the main view
                    let vc = UIStoryboard(name: "Menu", bundle: nil).instantiateInitialViewController()
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = vc
                    
                })
            })
        }
        
        
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let fbHandled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        let googleHandled = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
       
        return googleHandled || fbHandled
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                return
            }
            
            DBProvider.Instance.usersRef.child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                if(snapshot == nil)
                {
                    DBProvider.Instance.saveUser(withID: user!.uid, name: user!.displayName!, email: user!.email!)

                }
                let vc = UIStoryboard(name: "Menu", bundle: nil).instantiateInitialViewController()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = vc
                
            })
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: UIActivity Indicator
    func addIndicator(){
        indicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.height)) as UIActivityIndicatorView
        //  indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.backgroundColor = UIColor.black
        indicator.alpha = 0.75
    }
    
    func showIndicator(){
        //show the Indicator
        indicator.startAnimating()
        window?.rootViewController?.view .addSubview(indicator)
        
    }
    
    func hideIndicator(){
        //Hide the Indicator
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }

}

