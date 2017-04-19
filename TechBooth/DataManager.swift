//
//  DataManager.swift
//  TechBooth
//
//  Created by Stefan Verveniotis & Dylan McCrindle on 2016-12-14.
//
//

import UIKit
import CoreData
import GoogleAPIClientForREST
import GTMOAuth2

class DataManager {
	
	
	//Make a new Project
//	let newProject = Project(context: DataManager.share.context())
//	newProject.pdf = "Fyi.pdf"
	
	
	
	//Load from core data
//	let projectArray = DataManager.share.fetchEntityArray(name: "Project")
//	DataManager.share.loadPDF(project:projectArray[0] as! Project)
	
	//Singleton
	static let share = DataManager()
	
	//PDF Variables
	var currentProject: Project? = nil
	var document: CGPDFDocument!
	var pageCount = 0
    var pageRect = CGRect(x: 0, y: 0, width: 0, height: 0)
	
	//Google Variables
	let service = GTLRDriveService()
	
	//Store Directory
	let dir = "Project"
	
	private init() {	}
	
	// MARK: - Core Data
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "TechBooth")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	
	func context() -> NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
    func getProjects() -> [Project] {
        let request = NSFetchRequest<Project>(entityName: "Project")
        let sort = NSSortDescriptor(key: "lastOpened", ascending: false)
        request.sortDescriptors = [sort]
        do {
            let projectArray = try self.context().fetch(request)
            return projectArray
        } catch {
            return [Project]()
        }
    }
    

	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	// MARK: - Core Data Fetching
	func fetchEntityArray(name:String) -> [AnyObject]{

		let context = persistentContainer.viewContext
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
		
		do {
			let results = try context.fetch(request) as [AnyObject]
			return results
			
		} catch {
			print("Error with request: \(error)")
			return []
		}
	}
	
	func fetchPageAnnotations(page: Int) -> [Annotation] {
		let projectAnnotations = currentProject!.pdfAnnotations?.allObjects as! [Annotation]
		var pageAnnotations: [Annotation] = []

		for annotation in projectAnnotations {
			if Int(annotation.pageNumber) == page {
				pageAnnotations.append(annotation)
			}
		}
		return sortAnnotations(annotArray: pageAnnotations)
	}
	
	func fetchSortedAnnotationsOf(type: Int) -> [Annotation]{
		
		var typeArray: [Annotation] = []
		for page in 0...pageCount {
            typeArray.append(contentsOf: fetchSortedAnnotationsOf(type: type, page: page))
        }
		return typeArray
	}
	
	func fetchSortedAnnotationsOf(type: Int, page: Int) -> [Annotation]{
		
		let pageAnnotations = fetchPageAnnotations(page: page)
		var typeArray: [Annotation] = []
        
		for annotation in pageAnnotations {
			if Int(annotation.type) ==  type{
				typeArray.append(annotation)
			}
		}
		return sortAnnotations(annotArray: typeArray)
	}
	
	// MARK: - Creating/Loading
	func loadPDF(project: Project?) {
		
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]

		if(project == nil){
			//TEMP PDF load if nothing exists
			
			let newProject = Project(context: context())
			newProject.pdf = "Fyi.pdf"
			newProject.name = "FYI"

			let bundlePath = Bundle.main.url(forResource: "Fyi", withExtension: "pdf")
			
			let fileFolderPath = documentsDirectory.appendingPathComponent("\(dir)/\(newProject.name!)")
			let filePath =  fileFolderPath.appendingPathComponent(newProject.pdf!)
			
			do {
				try FileManager.default.createDirectory(atPath: fileFolderPath.path, withIntermediateDirectories: false, attributes: nil)
				try FileManager.default.copyItem(atPath: bundlePath!.path, toPath: filePath.path)
			} catch {
				print(error)
			}
			openProject(project: newProject)
		}
		else{
			let importPath = documentsDirectory.appendingPathComponent("/Inbox/\(project!.pdf!)")
			let subPath = documentsDirectory.appendingPathComponent("\(dir)/\(project!.name!)")
			let movePath = subPath.appendingPathComponent(project!.pdf!)
			do {
				try FileManager.default.createDirectory(atPath: subPath.path, withIntermediateDirectories: false, attributes: nil)
				try FileManager.default.moveItem(atPath: importPath.path, toPath: movePath.path)
				print("Move successful")
			} catch let error {
				print("Error: \(error.localizedDescription)")
			}
			openProject(project: project)
		}
	}
	
	func openProject(project: Project?) {
        project?.lastOpened = NSDate()
        saveContext()
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		
		let path = documentsDirectory.appendingPathComponent("\(dir)/\(project!.name!)/\(project!.pdf!)")
		let newDoc = CGPDFDocument(path as CFURL)!
		document = newDoc
		pageCount = newDoc.numberOfPages
		pageRect = (newDoc.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox))!
		currentProject = project!
	}

	func makeAnnotation(page:Int, type:Int, inRect: CGRect, box:CGRect, point:CGPoint) -> Annotation{
		
		let newAnnotation = Annotation(context: context())
		
		newAnnotation.project = currentProject
		newAnnotation.pageNumber = Int16(page)
		newAnnotation.type = Int16(type)
		newAnnotation.cueDescription = "No Description"
		newAnnotation.uniqueID = UUID().uuidString
		
		saveContext()
		
		saveBox(box: box, inRect: inRect, annotation: newAnnotation)
		savePoint(point: point, inRect: inRect, annotation: newAnnotation)
		reorderforNewCues(changeAnnot: newAnnotation)
		
		return newAnnotation
	}
	
	// MARK: - Sorting
	func sortAnnotations(annotArray:[Annotation]) -> [Annotation]{
		let sortedArray = annotArray.sorted { (annot1, annot2) -> Bool in
			return annot1.dotY < annot2.dotY
		}
		return sortedArray
	}
	
	func reorderCuesOn(page: Int, type: Int){
		let annotationsOfType = fetchSortedAnnotationsOf(type: type, page: page)
		var count = 1
		for annotation in annotationsOfType {
			annotation.cueNum = Int16(count)
			count += 1
		}
		saveContext()
	}
	
	
	func reorderforNewCues(changeAnnot: Annotation){
		let annotationsOfType = fetchSortedAnnotationsOf(type: Int(changeAnnot.type), page: Int(changeAnnot.pageNumber))
		var count = 1
		for annotation in annotationsOfType {
			if (annotation.dotY == changeAnnot.dotY){
				changeAnnot.cueNum = Int16(count)
				for index in count-1..<annotationsOfType.count{
					annotationsOfType[index].cueNum = Int16(count)
					count += 1
				}
				break
			}
			count += 1
		}
		saveContext()
	}
	
	// MARK: - Convert box and point values
	func saveBox(box:CGRect, inRect: CGRect, annotation:Annotation) {
		annotation.boxX = Float(box.origin.x / inRect.size.width)
		annotation.boxY = Float(box.origin.y / inRect.size.height)
		annotation.boxWidth = Float(box.size.width / inRect.size.width)
		annotation.boxHeight = Float(box.size.height / inRect.size.height)
		saveContext()
	}
	
	func savePoint(point:CGPoint, inRect: CGRect, annotation:Annotation) {
		annotation.dotX = Float(point.x / inRect.size.width)
		annotation.dotY = Float(point.y / inRect.size.height)
		saveContext()
	}
	
	
    func exportPDF() {
        let fileName = "Script.PDF"
        let writePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName).path
        
        let pageSize = document.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox)
        
        UIGraphicsBeginPDFContextToFile(writePath, CGRect.zero, nil)
        
        let currentContext = UIGraphicsGetCurrentContext()
        //currentContext!.textMatrix = CGAffineTransform .identity
        
        for page in 1...document.numberOfPages {
            
            let renderView = UIView(frame: pageSize!)
            
            for annotation in DataManager.share.fetchPageAnnotations(page: page) {
                let annot = Annot.init(annotation: annotation, rect: renderView.bounds, allowEdits: false)
                renderView.addSubview(annot)
            }
            
            UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: (pageSize?.size.width)!, height: (pageSize?.size.height)!), nil)
            currentContext!.scaleBy(x: 1.0, y: -1.0)
            currentContext!.translateBy(x: 0, y: -(pageSize?.size.height)!)
            let pageToDraw = document.page(at: page)
            
            currentContext!.drawPDFPage(pageToDraw!)
            
            currentContext!.scaleBy(x: 1.0, y: -1.0)
            currentContext!.translateBy(x: 0, y: -(pageSize?.size.height)!)
            
            renderView.layer.render(in: currentContext!) 
            
        }
        UIGraphicsEndPDFContext()
    }
	
	func exportCSV() -> URL? {
//		if (GIDSignIn.sharedInstance().currentUser != nil) {
//			let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
//			
//			let scopes = kGTLRAuthScopeDrive
//			let keychainItemName = "TechBooth";
//			let clientId = "879595095226-t50jdtevu3ipgk3ug5sld25vo1s4uh9k.apps.googleusercontent.com";
//		}
		
		var csvFile = ""
		let filePath = "\(dir)/\(currentProject!.name!)/\(currentProject!.name!)"
		
		var annotationsArray = [Annotation]()
		for index in 0 ..< 3 {
			var cueType = ""
			switch index {
				case 0:
					cueType = "Light"
				case 1:
					cueType = "Sound"
				case 2:
					cueType = "Note"
				default:
					cueType = ""
			}
			
			annotationsArray = fetchSortedAnnotationsOf(type: index)
			for annotation in annotationsArray {
				
    				csvFile += ("\(annotation.pageNumber).\(annotation.cueNum),\(cueType),\(annotation.cueDescription!),\(annotation.uniqueID!)\n")
			}
		}
		
		if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			
			let path = directory.appendingPathComponent("\(filePath).csv")
			
			do {
				try csvFile.write(to: path, atomically: false, encoding: String.Encoding.utf8)
			}
			catch {}
			
			return path
		}
		return nil
	}
	
	func imageFromPDF(pageNum: Int) -> UIImage? {
		guard let page = self.document.page(at: pageNum) else { return nil }
		
		let pageRect = page.getBoxRect(.mediaBox)
		let renderer = UIGraphicsImageRenderer(size: pageRect.size)
		let img = renderer.image { ctx in
			UIColor.white.set()
			ctx.fill(pageRect)
			
			ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height);
			ctx.cgContext.scaleBy(x: 1.0, y: -1.0);
			
			ctx.cgContext.drawPDFPage(page);
		}
		
		return img
	}
}
