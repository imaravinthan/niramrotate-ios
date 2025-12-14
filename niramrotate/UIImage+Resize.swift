//
//  UIImage+Resize.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import UIKit

extension UIImage {
    func resized(max: CGFloat) -> UIImage {
        let ratio = min(max / size.width, max / size.height)
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )

        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
