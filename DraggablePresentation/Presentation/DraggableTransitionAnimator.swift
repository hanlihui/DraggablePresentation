//
//  DraggableTransitionAnimator.swift
//  DraggablePresentation
//
//  Created by lihuiHan on 2018/7/25.
//  Copyright © 2018 lihuiHan. All rights reserved.
//

import UIKit

final class DraggableTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let vcToPresent: UIViewController
    private weak var presentingVC: UIViewController?
    
    init(viewControllerToPresent: UIViewController, presentingViewController: UIViewController) {
        self.vcToPresent = viewControllerToPresent
        self.presentingVC = presentingViewController
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DraggablePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
