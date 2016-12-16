//
//  MainMenuView.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class MainMenuView: UIViewController, GIDSignInUIDelegate {

    
	
	
	@IBAction func signinGoogle(_ sender: UIButton) {
		GIDSignIn.sharedInstance().signIn()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		GIDSignIn.sharedInstance().uiDelegate = self
		
  // Uncomment to automatically sign in the user.
  //GIDSignIn.sharedInstance().signInSilently()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//MARK: - Google Sign In
	// Stop the UIActivityIndicatorView animation that was started when the user
	// pressed the Sign In button
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
}
