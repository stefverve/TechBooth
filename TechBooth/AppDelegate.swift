//
//  AppDelegate.swift
//  TechBooth
//
//  Created by Stefan Verveniotis & Dylan McCrindle on 2016-12-14.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

	private var count = 0
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// Initialize sign-in
		var configureError: NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(configureError)")
		
		GIDSignIn.sharedInstance().delegate = self
		if FileManager.default.fileExists(atPath: "/Project") == false {
			let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
			let documentsDirectory = paths[0]
			let projectFolderPath = documentsDirectory.appendingPathComponent("Project")
			do{
				try FileManager.default.createDirectory(atPath: projectFolderPath.path, withIntermediateDirectories: false, attributes: nil)
			} catch {
				print(error)
			}
		}
		

		
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
        // Saves changes in the application's managed object context before the application terminates.
        DataManager.share.saveContext()
    }

	//MARK: - Import PDF from Another App
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

		if(url.scheme! == "com.googleusercontent.apps.879595095226-t50jdtevu3ipgk3ug5sld25vo1s4uh9k"){
			return GIDSignIn.sharedInstance().handle(url, sourceApplication:
				options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation:
				options[UIApplicationOpenURLOptionsKey.annotation])
		}else{
			let pathName = url.lastPathComponent
			let newProject = Project(context: DataManager.share.context())
			newProject.pdf = pathName
			
			newProject.name = "NewProject-\(self.count)"
			self.count += 1
			DataManager.share.saveContext()
			DataManager.share.loadPDF(project: newProject)
			
			let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
			let projectVC : UIViewController = storyboard.instantiateViewController(withIdentifier: "ProjectVC") as UIViewController
			self.window = UIWindow(frame: UIScreen.main.bounds)
			self.window?.rootViewController = projectVC
			self.window?.makeKeyAndVisible()
			
			return true
		}
	}
	
	//MARK: - Google Sign In
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if (error == nil) {
			// Perform any operations on signed in user here.
			let userId = user.userID                  // For client-side use only!
			let idToken = user.authentication.idToken // Safe to send to the server
			let fullName = user.profile.name
			let givenName = user.profile.givenName
			let familyName = user.profile.familyName
			let email = user.profile.email
			
			print(userId!, idToken!, fullName!, givenName!, familyName!, email!)
			
		} else {
			print("\(error.localizedDescription)")
		}
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
	            withError error: Error!) {
		// Perform any operations when the user disconnects from app here.
		// ...
	}
}


















