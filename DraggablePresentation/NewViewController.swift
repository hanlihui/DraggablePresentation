//
//  NewViewController.swift
//  DraggablePresentation
//
//  Created by lihuiHan on 2018/7/25.
//  Copyright © 2018 lihuiHan. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var handleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    private func setUpViews() {
        handleView.layer.cornerRadius = 2.5
        containerView.round(corners: [.topLeft, .topRight], radius: 8)
    }
}

extension UIView {
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
