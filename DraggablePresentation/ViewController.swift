//
//  ViewController.swift
//  DraggablePresentation
//
//  Created by lihuiHan on 2018/7/25.
//  Copyright © 2018 lihuiHan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
     var animator: DraggableTransitionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func show(_ sender: Any) {
        guard let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewViewController") as? NewViewController else {
            return
        }
        animator = DraggableTransitionDelegate(viewControllerToPresent: newViewController, presentingViewController: self)
        newViewController.transitioningDelegate = animator
        newViewController.modalPresentationStyle = .custom
        
        present(newViewController, animated: true)
    }
    

}

