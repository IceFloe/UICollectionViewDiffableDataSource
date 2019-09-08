//
//  MenuItem.swift
//  UICollectionViewCompositionalLayout
//
//  Created by Alex Gurin on 8/25/19.
//

import UIKit

enum MenuItem: String, CaseIterable {
    case snapshot = "Snapshot Usage"
    case data = "Data Usage"
    case diffEnum = "Enum Elements"
    case diffAnyHashable = "AnyHashable Elements"

    var viewController: UIViewController {
        switch self {
        case .snapshot:
            return SnapshotViewController()
        case .data:
            return DataViewController()
        case .diffEnum:
            return DifferentElementsEnumViewController()
        case .diffAnyHashable:
            return AnyHashableViewController()
        }
    }
}

