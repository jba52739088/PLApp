//
//  AppDelegate.swift
//  pianoLearningApp
//


import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var TabBar: TabBarVC!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NSSetUncaughtExceptionHandler { exception in
            print("Error Handling: ", exception)
            print("Error Handling callStackSymbols: ", exception.callStackSymbols)
            
            UserDefaults.standard.set(exception.callStackSymbols, forKey: "ExceptionHandler")
            UserDefaults.standard.synchronize()
        }
        if SQLiteManager.shared.createDatebase() {
            print("createDatebase")
            let freeSheets = ["score1", "score2", "score3"]
            for sheet in freeSheets {
                let aSheet = Sheet(name: sheet, level: "1", book: "0", isDownloaded: true, completion: 0, recorded: 0)
                if !SQLiteManager.shared.insertSheetInfo(aSheet) {
                    print("insert sheet '\(sheet)' to db error")
                }
            }
        }else {
            print("createDatebase error")
        }
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last);
        
        // 關閉Layout log
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        return true
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


}

