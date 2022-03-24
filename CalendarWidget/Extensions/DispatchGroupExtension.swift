//
//  DispatchGroupExtension.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 30.03.21.
//

import Foundation

extension DispatchGroup {

    func notifyWait(target: DispatchQueue, timeout: DispatchTime, handler: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .default).async {
            _ = self.wait(timeout: timeout)
            target.async {
                handler()
            }
        }
    }

}

