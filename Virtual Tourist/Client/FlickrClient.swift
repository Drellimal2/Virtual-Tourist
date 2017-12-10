//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    
    func taskMethod(methodParams : [String:AnyObject], pageNum : Int = 1, count : Int = 0, completionHandler : @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // create session and request
        let session = URLSession.shared
        var methodParameters = methodParams
        methodParameters[FlickrConstants.ParameterKeys.Page] = pageNum as AnyObject
        
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))

        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func makeError(_ desc : String, _ code : Int = 1) -> NSError{
                let userInfo: [AnyHashable : Any] =
                    [
                        NSLocalizedDescriptionKey :  NSLocalizedString("Client Error", value: desc, comment: "") ,
                        NSLocalizedFailureReasonErrorKey : NSLocalizedString("Client Error", value: desc, comment: "")
                ]
                return NSError(domain: "Flickr", code: code, userInfo: userInfo as? [String : Any])
            }
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(nil, error! as NSError)
                print(error.debugDescription)
                return
            }
            
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(nil, makeError("Your request returned a status code other than 2xx!"))
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(nil, makeError("No data recieved!"))

                print("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(nil, makeError("Could not parse data!"))

                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrConstants.ResponseKeys.Status] as? String, stat == FlickrConstants.ResponseValues.OKStatus else {
                completionHandler(nil, makeError("Flickr API returned an error!"))

                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandler(nil, makeError("Cannot find photos key!"))
                print("Cannot find keys '\(FlickrConstants.ResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[FlickrConstants.ResponseKeys.Pages] as? Int else {
                completionHandler(nil, makeError("Cannot find pages key!"))
                print("Cannot find key '\(FlickrConstants.ResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            if count >= 0 || totalPages == 1 {
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[FlickrConstants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                    completionHandler(nil, makeError("Cannot find photo key!"))
                    print("Cannot find key '\(FlickrConstants.ResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }
                
                completionHandler(photosArray as AnyObject, nil)

                
            }
            // pick a random page!
            let pageLimit = min(totalPages, 80)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            let cnt = count + 1
            let _ = self.taskMethod(methodParams: methodParams, pageNum: randomPage, count : cnt,completionHandler: completionHandler)
            
        }
        return task
        
    }
        
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    
}

