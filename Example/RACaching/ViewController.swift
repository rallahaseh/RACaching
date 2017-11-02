//
//  ViewController.swift
//  RACaching
//
//  Created by rallahaseh on 11/01/2017.
//  Copyright (c) 2017 rallahaseh. All rights reserved.
//

import UIKit
import RACaching

class ViewController: UITableViewController, RAURLObserverProtocol {
    
    lazy var photos: NSDictionary = NSDictionary()
    
    var resourceManager: RAResourceManager!
    
    let identifierName = "viewControllerIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Pinterest"
        loadPhotos()
        resourceManager = RAResourceManager.init(configuration: nil)
    }
    
    func loadPhotos() {
        let fetcher: FetchingData = FetchingData()
        fetcher.loadPinterestData { (returnedData, reurnedErrors) in
            if reurnedErrors == nil {
                DispatchQueue.main.async {
                    self.photos = returnedData!
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        let rowKey = photos.allKeys[indexPath.row] as! String
        let url = (photos.value(forKey: rowKey) as? String)!
        
        
        if (!tableView.isDragging && !tableView.isDecelerating) {
            self.resourceManager.getDataFor(url, withIdentifier: identifierName, withUrlObserver: self)
        }
        
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        indicator.startAnimating()
        
        
        cell.textLabel?.text = String(indexPath.row+1) + ". " + rowKey
        cell.textLabel?.textColor = UIColor.black
        cell.imageView?.image = #imageLiteral(resourceName: "pinterest")
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height / 10
    }
    
    func compressData(_ urlString: String, data: Data) -> Data {
        let unfilteredImage = UIImage(data:data)
        let image = self.applySepiaFilter(unfilteredImage!)
        return UIImagePNGRepresentation(image!)!
    }
    
    func applySepiaFilter(_ image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: "inputIntensity")
        if let outputImage = filter!.outputImage {
            let outImage = context.createCGImage(outputImage, from: outputImage.extent)
            return UIImage(cgImage: outImage!)
        }
        return nil
    }
    
    
    func didFetchURLData(_ urlString: String, data: Data?, errorMessage: String) {
        
        var image : UIImage?
        if let imageData = data {
            image = UIImage(data:imageData)
        }
        
        let array = photos.allValues as NSArray
        
        let index = array.index(of: urlString)
        
        let indexPath = IndexPath.init(row: index, section: 0)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let indicator = cell.accessoryView as! UIActivityIndicatorView
            DispatchQueue.main.async {
                if let fillImage = image {
                    cell.imageView?.image = fillImage
                } else {
                    cell.textLabel?.text = "\(indexPath.row+1).\(self.photos.allKeys[indexPath.row] as! String) - \(errorMessage)"
                    cell.textLabel?.textColor = UIColor.red
                }
                indicator.stopAnimating()
            }
        }
    }
}

extension ViewController
{
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for (_, value) in self.photos {
            self.resourceManager.cancelDataFor((value as? String)!, withIdentifier: identifierName)
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
    }
    
    func loadImagesForOnscreenCells() {
        if let pathsArray = self.tableView.indexPathsForVisibleRows {
            for indexpath in pathsArray {
                let rowKey = photos.allKeys[indexpath.row] as! String
                let url = (photos.value(forKey: rowKey) as? String)!
                self.resourceManager.getDataFor(url, withIdentifier: identifierName, withUrlObserver: self)
            }
        }
        
    }
}
