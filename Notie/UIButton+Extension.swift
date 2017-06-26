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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        semanticContentAttribute = .forceLeftToRight
        contentHorizontalAlignment = .center
        titleLabel?.textAlignment = .left
        titleEdgeInsets = UIEdgeInsets(top: 0, left: componentsIndent, bottom: 0, right: 0)
        
        let titleLabelHeight = titleLabel?.intrinsicContentSize.height ?? 0
        let imageHeight = imageView?.intrinsicContentSize.height ?? 0
        let maxHeight = max(titleLabelHeight, imageHeight)
        let newHeight = maxHeight > 0 ? maxHeight + componentsIndent : 0
        
        var newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: newHeight)
        frame = newFrame;
    }
}
