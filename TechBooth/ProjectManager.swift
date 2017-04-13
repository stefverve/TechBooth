//
//  ProjectManager.swift
//  TechBooth
//
//  Created by Minhung Ling on 2017-04-13.
//
//

import UIKit

class ProjectManager: NSObject {
    static let share = ProjectManager()
    let dir = "Project"
    var session = Session()
    var projectArray = [Project]()
    let dataManager = DataManager.share

    func fetchProjects() {
        projectArray = dataManager.getProjects()
    }
    
    func openProject(project: Project?) -> CGPDFDocument {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let path = documentsDirectory.appendingPathComponent("\(dir)/\(project!.name!)/\(project!.pdf!)")
        let newDoc = CGPDFDocument(path as CFURL)!
        return newDoc
    }
}



//MARK: Session extension

extension ProjectManager {
    struct Session {
        var project: Project!
        var document: CGPDFDocument!
        var pageCount = 0
        var pageRect = CGRect()
    }

//    func openProject(project: Project?) {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        
//        let path = documentsDirectory.appendingPathComponent("\(dir)/\(project!.name!)/\(project!.pdf!)")
//        let newDoc = CGPDFDocument(path as CFURL)!
//        session.document = newDoc
//        session.pageCount = newDoc.numberOfPages
//        session.pageRect = (newDoc.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox))!
//        session.project = project!
//    }
    

}
