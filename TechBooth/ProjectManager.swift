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
    
    func openRecent() {
        if projectArray.count > 0 {
            dataManager.loadPDF(project: projectArray[0])
            return
        }
        dataManager.loadPDF(project: nil)
    }
    
    func loadPDFAtIndex(_ index: Int) {
        dataManager.loadPDF(project: projectArray[index])
    }
}
