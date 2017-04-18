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
    var projectArray = [Project]()
    let dataManager = DataManager.share
    var session = Session()
    func fetchProjects() {
        projectArray = dataManager.getProjects()
    }
    
    func getPDFForProject(_ project: Project) -> CGPDFDocument {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let path = documentsDirectory.appendingPathComponent("\(dir)/\(project.name!)/\(project.pdf!)")
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

    func beginSession(index: Int) {
        session.project = projectArray[index]
        session.project.lastOpened = NSDate()
        dataManager.saveContext()
        session.document = getPDFForProject(session.project)
    }
}
