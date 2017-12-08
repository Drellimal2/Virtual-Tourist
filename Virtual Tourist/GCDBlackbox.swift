//
//  GCDBlackbox.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
