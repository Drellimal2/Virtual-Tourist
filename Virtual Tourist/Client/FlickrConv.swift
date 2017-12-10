//
//  FlickrConv.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrConstants.Constants.APIScheme
        components.host = FlickrConstants.Constants.APIHost
        components.path = FlickrConstants.Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func bboxString(lat : Double?, lng : Double?) -> String {
        // ensure bbox is bounded by minimum and maximums
        if let latitude = lat, let longitude = lng {
            let minimumLon = max(longitude - FlickrConstants.Constants.SearchBBoxHalfWidth, FlickrConstants.Constants.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrConstants.Constants.SearchBBoxHalfHeight, FlickrConstants.Constants.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrConstants.Constants.SearchBBoxHalfWidth, FlickrConstants.Constants.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrConstants.Constants.SearchBBoxHalfHeight, FlickrConstants.Constants.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }
    
    func getPhotos(pin: Pin, completionHandler : @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
        
        let methodParameters = [
            FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.SearchMethod,
            "per_page" : 50 as Any,
            FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey,
            FlickrConstants.ParameterKeys.BoundingBox: bboxString(lat: pin.lat, lng : pin.lng),
            FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.UseSafeSearch,
            FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL,
            FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat,
            FlickrConstants.ParameterKeys.NoJSONCallback: FlickrConstants.ParameterValues.DisableJSONCallback
        ]
        
        let task = taskMethod(methodParams: methodParameters as [String:AnyObject], completionHandler: completionHandler)
        
        task.resume()
        
        
    }
    
    
        
    
    
}
