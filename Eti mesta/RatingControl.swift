//
//  RatingControl.swift
//  My Places (with comments)
//
//  Created by Артём Тюрморезов on 06.10.2022.
//

import UIKit
import RealmSwift
import Cosmos
@IBDesignable class RatingControl: UIStackView {
    var rating = 0 {
        didSet {
            updateButtonStates()
        }
    }
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44, height: 44) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starsCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

//MARK: - initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    @objc func ratingButtonTapped(button: UIButton) {
        guard let indexOfStars = ratingButtons.firstIndex(of: button) else { return }
        let selectedStar = indexOfStars + 1
        
        if selectedStar == rating {
            rating = 0
        } else {
            rating = selectedStar
        }
    }
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        let starsConfig = UIImage.SymbolConfiguration(pointSize: 40)
        let emptyStar = UIImage(systemName: "star", withConfiguration: starsConfig)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        let filledStar = UIImage(systemName: "star.fill", withConfiguration: starsConfig)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        let highlitedStar = UIImage(systemName: "star.fill", withConfiguration: starsConfig)?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        
        
        for _ in 0..<starsCount {
            let button = UIButton()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlitedStar, for: .highlighted)
            button.setImage(highlitedStar, for: [.highlighted, .selected])
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
}
