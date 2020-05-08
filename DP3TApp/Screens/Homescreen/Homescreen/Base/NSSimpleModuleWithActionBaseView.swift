///

import Foundation
import UIKit

class NSSimpleModuleWithActionBaseView: NSSimpleModuleBaseView {

    var touchUpCallback: (() -> Void)?
    
    init(title: String, subtitle: String? = nil, subview: UIView? = nil, boldText: String? = nil, text: String? = nil, image: UIImage? = nil, subtitleColor: UIColor? = nil, isSelected: Bool = false, touchUpCallback: (() -> Void)? = nil) {
        
        
        super.init(title: title, subtitle: subtitle, subview: subview, boldText: boldText, text: text, image: image, subtitleColor: subtitleColor, isSelected: isSelected)
        self.touchUpCallback = touchUpCallback
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap() {
        touchUpCallback?()
    }
    

}
