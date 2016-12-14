//
//  ModelController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class ModelController: NSObject, UIPageViewControllerDataSource {
    
    override init() {
        super.init()
        // Create the data model.
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> SinglePageViewController? {
        // Return the data view controller for the given index.
        let nPages = DataManager.share.pageCount
        if (nPages == 0) || (index >= nPages) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let singlePageViewController = storyboard.instantiateViewController(withIdentifier: "SinglePageViewController") as! SinglePageViewController
        singlePageViewController.page = DataManager.share.document.page(at: index+1)
        singlePageViewController.pageNum = index
        return singlePageViewController
    }
    
    func indexOfViewController(_ viewController: SinglePageViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return viewController.pageNum
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! SinglePageViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! SinglePageViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == DataManager.share.pageCount {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}


