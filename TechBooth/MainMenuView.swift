//
//  MainMenuView.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//
import MessageUI
import UIKit

class MainMenuView: UIViewController, GIDSignInUIDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var projectCollectionView: UICollectionView!
    var dataManager = DataManager.share
    let projectManager = ProjectManager.share
    @IBOutlet weak var googleUsernameLabel: UILabel!
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Google Sign In
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    @IBAction func signinGoogle(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = projectCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let width = projectCollectionView.bounds.height * 8.5 / 11
        let size = CGSize(width: width, height: projectCollectionView.bounds.height)
        layout.itemSize = size
        projectManager.fetchProjects()

        GIDSignIn.sharedInstance().uiDelegate = self
        //Uncomment to automatically sign in the user.
        GIDSignIn.sharedInstance().signInSilently()
        //googleUsernameLabel.text = GIDSignIn.sharedInstance().currentUser
        
        //		let projectArray = DataManager.share.fetchEntityArray(name: "Project")
        //		var loadProject : Project? = nil
        
        //		if projectArray.count != 0 {
        //			loadProject = projectArray.last as? Project
        //		}
        
        //		DataManager.share.loadPDF(project:loadProject)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        projectManager.fetchProjects()
//        projectCollectionView.reloadData()
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
        let path = DataManager.share.exportCSV()
        
        if( MFMailComposeViewController.canSendMail() ) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setSubject("Light Cues, Sound Cues and Notes for \(DataManager.share.currentProject!.name!)")
            
            //if let filePath = Bundle.main.path(forResource: "\(path)", ofType: "csv") {
            if let fileData = NSData(contentsOf: path!) {
                mailComposer.addAttachmentData(fileData as Data, mimeType: "text/csv", fileName: "\(DataManager.share.currentProject!.name!)")
                DataManager.share.exportPDF()
                let pdfPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Script.PDF").path
                let url = NSURL .fileURL(withPath: pdfPath)
                let pdfData = NSData(contentsOf: url)
                mailComposer.addAttachmentData(pdfData! as Data, mimeType: "application/pdf", fileName: "\(DataManager.share.currentProject!.name!) - PDF")
                
                if fileData.length == 0 {
                    mailComposer.setMessageBody("No annotations to export!", isHTML: false)
                }
            }
            
            //}
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Open Files
    @IBAction func openRecent(_ sender: UIButton) {
        var loadProject : Project? = nil
        
        if projectManager.projectArray.count > 0 {
            loadProject = projectManager.projectArray[0]
        }
        DataManager.share.loadPDF(project:loadProject)
    }
    
    
    @IBAction func openPrevious(_ sender: UIButton) {
        let driveURL = URL(string: "googledrive://")!
        UIApplication.shared.open(driveURL, options: [:], completionHandler: nil)
    }
    
    //MARK: Open Recent CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectManager.projectArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "docCell", for: indexPath) as! myDocCell
        let project = projectManager.projectArray[indexPath.row]
        let pdf = projectManager.getPDFForProject(project)
        cell.pdfView.page = pdf.page(at: 1)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectViewController" {
            let indexPath = projectCollectionView.indexPathsForSelectedItems![0]
            projectManager.loadPDFAtIndex(indexPath.row)
        }
    }
    
}
