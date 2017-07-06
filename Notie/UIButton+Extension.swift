//
//  UIButton+MNExtension.swift
//  Notie
//
//  Created by Vlad Vovk on 6/26/17.
//
//

import Foundation

@IBDesignable
class LeftAlignedIconButton: UIButton {
    private let componentsIndent: CGFloat = 10
    private let verticalIndent: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        semanticContentAttribute = .forceLeftToRight
        contentHorizontalAlignment = .center
        titleLabel?.textAlignment = .left
        titleEdgeInsets = UIEdgeInsets(top: 0, left: componentsIndent, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        var result = super.intrinsicContentSize
        result.height += 2 * verticalIndent
        return result
    }
}
