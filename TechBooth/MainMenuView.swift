//
//  MainMenuView.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class MainMenuView: UIViewController, GIDSignInUIDelegate {

	@IBOutlet weak var googleUsernameLabel: UILabel!
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//MARK: - Google Sign In
	// Stop the UIActivityIndicatorView animation that was started when the user
	// pressed the Sign In button
	@IBAction func signinGoogle(_ sender: UIButton) {
		GIDSignIn.sharedInstance().signIn()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		GIDSignIn.sharedInstance().uiDelegate = self
	  //Uncomment to automatically sign in the user.
		GIDSignIn.sharedInstance().signInSilently()
		//googleUsernameLabel.text = GIDSignIn.sharedInstance().currentUser
	}

	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
  		//myActivityIndicator.stopAnimating()
	}
	
	// Present a view that prompts the user to sign in with Google
	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
  		self.present(viewController, animated: true, completion: nil)
	}
	
	// Dismiss the "Sign in with Google" view
	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
  		self.dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func exportRecent(_ sender: UIButton) {
		DataManager.share.exportCSV()
	}
	
	
	//MARK: - Open Files
	@IBAction func openRecent(_ sender: UIButton) {
		let projectArray = DataManager.share.fetchEntityArray(name: "Project")
		var loadProject : Project? = nil
		
		if projectArray.count != 0 {
			loadProject = projectArray.last as? Project
		}
		
		DataManager.share.loadPDF(project:loadProject)
	}
	
	
	@IBAction func openPrevious(_ sender: UIButton) {
		let driveURL = URL(string: "googledrive://")!
		UIApplication.shared.open(driveURL, options: [:], completionHandler: nil)
	}
}
