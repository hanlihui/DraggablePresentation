//
//  DraggablePresentationController.swift
//  DraggablePresentation
//
//  Created by lihuiHan on 2018/7/25.
//  Copyright © 2018 lihuiHan. All rights reserved.
//

import Foundation
import UIKit

private extension CGFloat {
    static let springDampingRatio: CGFloat = 0.7
    static let springInitialVelocityY: CGFloat = 10
}

private extension Double {
    static let animationDuration: Double = 0.8
}

enum DragDirection {
    case up
    case down
}

enum DraggablePositon {
    case collapsed
    case half
    case open
    
    var heightMultiplier: CGFloat {
        switch self {
        case .collapsed:
            return 0.2
        case .half:
            return 0.48
        case .open:
            return 1
        }
    }
    
    var upBoundary: CGFloat {
        switch self {
        case .collapsed:
            return 0.0
        case .half:
            return 0.27
        case .open:
            return 0.65
        }
    }
    
    var downBoundary: CGFloat {
        switch self {
        case .collapsed:
            return 0.0
        case .half:
            return 0.35
        case .open:
            return 0.8
        }
    }
    
    var dimAlpha: CGFloat {
        switch self {
        case .collapsed:
            return 0.0
        case .half:
            return 0.0
        case .open:
            return 0.45
        }
    }
    
    func nextPosition(for direction: DragDirection) -> DraggablePositon {
        switch (self, direction) {
        case (.collapsed, .up): return .half
        case (.collapsed, .down): return .collapsed
        case (.half, .up): return .open
        case (.half, .down): return .collapsed
        case (.open, .up): return .open
        case (.open, .down): return .half
        }
    }
    
    func originY(for maxHeight: CGFloat) -> CGFloat {
        return maxHeight - maxHeight * heightMultiplier
    }
}

final class DraggablePresentationController: UIPresentationController {
    // MARK: Private
    private var dimmingView = UIView()
    private var draggablePosition = DraggablePositon.collapsed
    
    private let springTiming = UISpringTimingParameters(dampingRatio: .springDampingRatio, initialVelocity: CGVector(dx: 0, dy: .springInitialVelocityY))
    private var animator: UIViewPropertyAnimator?
    
    private var dragDirection = DragDirection.up
    private let maxFrame = CGRect(x: 0, y: 0, width: UIWindow.root.bounds.width, height: UIWindow.root.bounds.height)
    private var panOnPresented = UIGestureRecognizer()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let presentedOrigin = CGPoint(x: 0, y: draggablePosition.originY(for: maxFrame.height))
        let presentedSize = CGSize(width: maxFrame.width, height: maxFrame.height)
        let presentedFrame = CGRect(origin: presentedOrigin, size: presentedSize)
        return presentedFrame
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        containerView.insertSubview(dimmingView, at: 1)
        dimmingView.alpha = 0
        dimmingView.backgroundColor = UIColor.black
        dimmingView.frame = containerView.frame
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        animator = UIViewPropertyAnimator(duration: .animationDuration, timingParameters: self.springTiming)
        animator?.isInterruptible = true
        panOnPresented = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(panRecognizer:)))
        presentedView?.addGestureRecognizer(panOnPresented)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    @objc private func userDidPan(panRecognizer: UIPanGestureRecognizer) {
        let translationPoint = panRecognizer.translation(in: presentedView)
        let currentOriginY = draggablePosition.originY(for: maxFrame.height)
        let newOffset = currentOriginY + translationPoint.y
        
        dragDirection = newOffset > currentOriginY ? .down : .up
        
        let nextOriginY = draggablePosition.nextPosition(for: dragDirection).originY(for: maxFrame.height)
        let area = dragDirection == .up ? frameOfPresentedViewInContainerView.origin.y - maxFrame.origin.y : -(frameOfPresentedViewInContainerView.origin.y - nextOriginY)
        
        let canDraginProposeDirection = dragDirection == .up && draggablePosition == .open ? false : true
        
        if newOffset > 0 && canDraginProposeDirection {
            switch panRecognizer.state {
            case .began, .changed:
                presentedView?.frame.origin.y = newOffset
                if newOffset != area && draggablePosition == .open || draggablePosition.nextPosition(for: dragDirection) == .open {
                    let onePercent = area / 100
                    let percentage = (area - newOffset) / onePercent / 100
                    dimmingView.alpha = percentage * DraggablePositon.open.dimAlpha
                }
            case .ended:
                animate(newOffset)
            default:
                break
            }
        }else {
            if panRecognizer.state == .ended {
                animate(newOffset)
            }
        }
    }
    
    
    private func animate(_ dragOffset: CGFloat) {
        let distanceFromBottom = maxFrame.height - dragOffset
        switch dragDirection {
        case .up:
            if (distanceFromBottom > maxFrame.height * DraggablePositon.open.upBoundary){
                animate(to: .open)
            }else if (distanceFromBottom > maxFrame.height * DraggablePositon.half.upBoundary) {
                animate(to: .half)
            }else {
                animate(to: .collapsed)
            }
        case .down:
            if (distanceFromBottom > maxFrame.height * DraggablePositon.open.downBoundary) {
                animate(to: .open)
            }else if (distanceFromBottom > maxFrame.height * DraggablePositon.half.downBoundary) {
                animate(to: .half)
            }else{
                animate(to: .collapsed)
            }
        }
    }
    
    private func animate(to position: DraggablePositon) {
        guard let animator = animator else {
            return
        }
        animator.addAnimations {
            self.presentedView?.frame.origin.y = position.originY(for: self.maxFrame.height)
            self.dimmingView.alpha = position.dimAlpha
        }
        
        animator.addCompletion { (animatingPosition) in
            if animatingPosition == .end {
                self.draggablePosition = position
            }
        }
        animator.startAnimation()
    }
    
}

extension UIWindow {
    // This is the delegate's window; it should never be nil and it usually is the key window.
    @objc public class var root: UIWindow {
        guard let optionalRootWindow = UIApplication.shared.delegate?.window,
            let rootWindow = optionalRootWindow else { fatalError("Fatal Error: delegate's window is nil!") }
        return rootWindow
    }
    
    // Some Apple classes set a different window to be the key window while presenting viewcontrollers,
    // so keyWindow should be taken with a grain of salt and it might not be what we expect.
    // It should not be nil and, most of the time, it should be the same as `root`.
    public class var key: UIWindow {
        guard let keyWindow = UIApplication.shared.keyWindow else { fatalError("Fatal Error: now window is set to keyWindow") }
        return keyWindow
    }
}
