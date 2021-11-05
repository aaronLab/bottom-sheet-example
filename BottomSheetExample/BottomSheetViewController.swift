//
//  BottomSheetViewController.swift
//  BottomSheetExample
//
//  Created by Aaron Lee on 2021/11/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SnapKit
import Then

open class BottomSheetViewController: UIViewController {
    
    // MARK: - Public Properties
    
    /// The background color of the view controller below the content view.
    ///
    /// - `UIColor.secondarySystemBackground.withAlphaComponent(0.6)` for iOS 13 or later.
    /// - `UIColor.black.withAlphaComponent(0.6)` for others.
    open var backgroundColor: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemBackground.withAlphaComponent(0.6)
        }
        
        return .black.withAlphaComponent(0.6)
    }
    
    /// Background view
    open var backgroundView = UIView()
    
    /// The background color of the content view
    ///
    /// Default value
    /// - `UIColor.systemBackground` for iOS 13 or later.
    /// - `UIColor.white` for others.
    open var contentViewBackgroundColor: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }
        
        return .white
    }
    
    /// The height of the content view
    ///
    /// Default value is `nil`
    ///
    /// If you set this value explicitly, the height of the content view will be fixed.
    open var height: CGFloat? {
        return nil
    }
    
    /// Content view
    open var contentView: UIView = UIView()
    
    /// Corner radius of the content view(top left, top right)
    ///
    /// Default value is `8.0`
    open var contentViewCornerRadius: CGFloat {
        return 16
    }
    
    /// Present / Dismiss transition duration
    ///
    /// Default value is 0.3
    open var transitionDuration: CGFloat {
        return 0.3
    }
    
    /// Dismiss velocity threshold
    ///
    /// Default value is 500
    open var dismissVelocityThreshold: CGFloat {
        return 500
    }
    
    // MARK: - Private Properties
    
    private var bag = DisposeBag()
    
    private var originCentreY: CGFloat = .zero
    
    // MARK: - Init
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        curveTopCorners()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindRx()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.presentTransition()
        }
    }
    
    private func presentTransition() {
        originCentreY = contentView.center.y
        
        let contentViewHeight = contentView.frame.height
        contentView.center.y += contentViewHeight
        
        UIView.animate(withDuration: transitionDuration) {
            self.contentView.center.y -= contentViewHeight
        }
    }
    
}

// MARK: - Helper

extension BottomSheetViewController {
    
    private func curveTopCorners() {
        let size = CGSize(width: contentViewCornerRadius, height: .zero)
        
        let path = UIBezierPath(roundedRect: contentView.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: size)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = contentView.bounds
        maskLayer.path = path.cgPath
        contentView.layer.mask = maskLayer
    }
    
}

// MARK: - Layout

extension BottomSheetViewController {
    
    private func configureView() {
        view.backgroundColor = .clear
        
        layoutBackgroundView()
        layoutContentView()
    }
    
    private func layoutBackgroundView() {
        backgroundView.backgroundColor = backgroundColor
        
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func layoutContentView() {
        contentView.backgroundColor = contentViewBackgroundColor
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.lessThanOrEqualToSuperview().priority(.low)
        }
        
        if let height = height {
            contentView.snp.makeConstraints {
                $0.height.equalTo(height)
            }
        }
    }
    
}

// MARK: - Bind

extension BottomSheetViewController {
    
    private func bindRx() {
        bindBackgroundViewTapGesture()
        bindContentViewPanGesture()
    }
    
    private func bindBackgroundViewTapGesture() {
        backgroundView
            .rx
            .gesture(.tap(configuration: { _, delegate in
                delegate.simultaneousRecognitionPolicy = .never
            }))
            .when(.recognized)
            .bind { [weak self] gesture in
                DispatchQueue.main.async {
                    self?.shouldDismissSheet()
                }
            }
            .disposed(by: bag)
    }
    
    private func shouldDismissSheet() {
        let contentViewHeight = contentView.frame.height
        
        UIView.animate(withDuration: transitionDuration) {
            self.contentView.center.y += contentViewHeight
            self.backgroundView.backgroundColor = .clear
        } completion: { _ in
            self.dismiss(animated: false)
        }
        
    }
    
    private func bindContentViewPanGesture() {
        contentView
            .rx
            .gesture(.pan(configuration: nil))
            .bind { [weak self] gesture in
                guard let self = self,
                      let gesture = gesture as? UIPanGestureRecognizer else { return }
                
                self.contentViewDidPan(gesture, in: self.contentView)
            }
            .disposed(by: bag)
    }
    
    private func verticalVelocity(_ gesture: UIPanGestureRecognizer, in view: UIView) -> CGFloat {
        let velocity = gesture.velocity(in: view)
        
        return velocity.y
    }
    
    private func contentViewDidPan(_ gesture: UIPanGestureRecognizer, in view: UIView) {
        
        if gesture.state == .changed {
            contentViewPanGestureDidChange(gesture, in: view)
        }
        
        if gesture.state == .ended {
            contentViewPanGestureDidEnd(gesture, in: view)
        }
    }
    
    private func contentViewPanGestureDidChange(_ gesture: UIPanGestureRecognizer, in view: UIView) {
        guard gesture.view != nil else { return }
        
        let translation = gesture.translation(in: view)
        let translatedY = gesture.view!.center.y + translation.y
        
        if translatedY < originCentreY { return }
        
        gesture.view!.center = CGPoint(x: gesture.view!.center.x, y: gesture.view!.center.y + translation.y)
        
        gesture.setTranslation(.zero, in: view)
        
        let ratio = (view.center.y - originCentreY) / originCentreY
        let alpha = 1 - ratio
        UIView.animate(withDuration: transitionDuration) {
            self.backgroundView.alpha = alpha
        }
        
    }
    
    private func contentViewPanGestureDidEnd(_ gesture: UIPanGestureRecognizer, in view: UIView) {
        guard shouldDismiss(gesture, in: view, threshold: dismissVelocityThreshold) else {
            
            DispatchQueue.main.async {
                self.shouldRestoreSheet()
            }
            
            return
        }
        
        DispatchQueue.main.async {
            self.shouldDismissSheet()
        }
    }
    
    private func shouldDismiss(_ gesture: UIPanGestureRecognizer, in view: UIView, threshold: CGFloat) -> Bool {
        let verticalVelocity = verticalVelocity(gesture, in: view)
        let movedDownHalf = view.frame.minY >= originCentreY
        
        return verticalVelocity > dismissVelocityThreshold || movedDownHalf
    }
    
    private func shouldRestoreSheet() {
        UIView.animate(withDuration: transitionDuration) {
            self.contentView.center.y = self.originCentreY
            self.backgroundView.alpha = 1
        }
        
    }
    
}
