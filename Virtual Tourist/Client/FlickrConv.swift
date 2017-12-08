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
        components.scheme = FlickrUtils.Constants.APIScheme
        components.host = FlickrUtils.Constants.APIHost
        components.path = FlickrUtils.Constants.APIPath
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
            let minimumLon = max(longitude - FlickrUtils.Constants.SearchBBoxHalfWidth, FlickrUtils.Constants.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrUtils.Constants.SearchBBoxHalfHeight, FlickrUtils.Constants.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrUtils.Constants.SearchBBoxHalfWidth, FlickrUtils.Constants.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrUtils.Constants.SearchBBoxHalfHeight, FlickrUtils.Constants.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }
    
    func getPhotos(lat : Double, lng : Double, completionHandler : @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
        
        let methodParameters = [
            FlickrUtils.ParameterKeys.Method: FlickrUtils.ParameterValues.SearchMethod,
            FlickrUtils.ParameterKeys.APIKey: FlickrUtils.ParameterValues.APIKey,
            FlickrUtils.ParameterKeys.BoundingBox: bboxString(lat: lat, lng : lng),
            FlickrUtils.ParameterKeys.SafeSearch: FlickrUtils.ParameterValues.UseSafeSearch,
            FlickrUtils.ParameterKeys.Extras: FlickrUtils.ParameterValues.MediumURL,
            FlickrUtils.ParameterKeys.Format: FlickrUtils.ParameterValues.ResponseFormat,
            FlickrUtils.ParameterKeys.NoJSONCallback: FlickrUtils.ParameterValues.DisableJSONCallback
        ]
        
        let task = taskMethod(methodParams: methodParameters as [String:AnyObject], completionHandler: completionHandler)
        
        task.resume()
        
        
        
    }
    
}
