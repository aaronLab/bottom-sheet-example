//
//  MyBottomSheetViewController.swift
//  BottomSheetExample
//
//  Created by Aaron Lee on 2021/11/05.
//

import UIKit

// MARK: - MyBottomSheetViewController

class MyBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Private Properties
    
    private let contentViewController = ContentViewController()
    
    // MARK: - Overrides
    
    override var height: CGFloat? {
        return view.frame.height / 2
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
}

// MARK: - Layout

extension MyBottomSheetViewController {
    
    private func configureView() {
        embedContentViewController()
    }
    
    private func embedContentViewController() {
        
        let navigationViewController = UINavigationController(rootViewController: contentViewController)
        navigationViewController.setNavigationBarHidden(false, animated: false)
        addChild(navigationViewController)
        
        contentView.addSubview(navigationViewController.view)
        navigationViewController.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        navigationViewController.didMove(toParent: self)
        
    }
    
}

// MARK: - MyStackViewBottomSheetViewController

class MyStackViewBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Private Properties
    
    private let stackView = UIStackView()
        .then {
            $0.axis = .vertical
            $0.spacing = 32
            $0.alignment = .fill
            $0.distribution = .fillEqually
        }
    
    // MARK: - Overrides
    
    override var contentViewCornerRadius: CGFloat {
        return .zero
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
}

// MARK: - Layout

extension MyStackViewBottomSheetViewController {
    
    private func configureView() {
        layoutStackView()
    }
    
    private func layoutStackView() {
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        Array(1...5).forEach {
            
            let label = UILabel()
            label.text = "\($0)"
            stackView.addArrangedSubview(label)
            
        }
        
    }
    
}
