//
//  DataManager.swift
//  TechBooth
//
//  Created by Stefan Verveniotis & Dylan McCrindle on 2016-12-14.
//
//

import UIKit
import CoreData

class DataManager {
	
	
	//Make a new Project
//	let newProject = Project(context: DataManager.share.context())
//	newProject.pdf = "Fyi.pdf"
	
	//Load from core data
//	let projectArray = DataManager.share.fetchEntityArray(name: "Project")
//	DataManager.share.loadPDF(project:projectArray[0] as! Project)
	
	//Singleton
	static let share = DataManager()
	var document: CGPDFDocument!
	var pageCount = 0
    var pageRect = CGRect(x: 0, y: 0, width: 0, height: 0)
	
	private init() {	}
	
	// MARK: - Core Data stack
	
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "TechBooth")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	func context() -> NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	// MARK: - Core Data Saving
	
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
	
	func loadPDF(project: Project?) {
		
		if(project == nil){
			//TEMP PDF load if nothing exists
			let newDoc: CGPDFDocument = CGPDFDocument(Bundle.main.url(forResource: "Fyi", withExtension: "pdf")! as CFURL)!
			DataManager.share.document = newDoc
			DataManager.share.pageCount = newDoc.numberOfPages
			DataManager.share.pageRect = (newDoc.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox))!
		}
		else{
			let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)			
			let documentsDirectory = paths[0]
			let path = documentsDirectory.appendingPathComponent("Inbox/\(project!.pdf!)")
			
			let newDoc = CGPDFDocument(path as CFURL)!
			self.document = newDoc
			self.pageCount = newDoc.numberOfPages
			self.pageRect = (newDoc.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox))!
		}
	}
	
	//func fetchPDFAnnotations(name:String) -> [AnyObject]{
	//
	//}
	
	//909794791437-078hatmo9nv239vavup7psa1e84abp5c.apps.googleusercontent.com

}
