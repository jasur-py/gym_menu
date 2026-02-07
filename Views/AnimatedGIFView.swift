import SwiftUI
import UIKit
import ImageIO

/// A SwiftUI view that displays animated GIFs
struct AnimatedGIFView: UIViewRepresentable {
    let imageData: Data
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        if let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
            let frameCount = CGImageSourceGetCount(source)
            
            if frameCount > 1 {
                // It's an animated GIF
                var images: [UIImage] = []
                var totalDuration: TimeInterval = 0
                
                for i in 0..<frameCount {
                    if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                        let image = UIImage(cgImage: cgImage)
                        images.append(image)
                        
                        // Get frame duration
                        if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                           let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                            let frameDuration = gifInfo[kCGImagePropertyGIFDelayTime as String] as? TimeInterval ?? 0.1
                            totalDuration += frameDuration
                        } else {
                            totalDuration += 0.1
                        }
                    }
                }
                
                imageView.animationImages = images
                imageView.animationDuration = totalDuration
                imageView.animationRepeatCount = 0 // Infinite loop
                imageView.startAnimating()
            } else if let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
                // Static image
                imageView.image = UIImage(cgImage: cgImage)
            }
        } else if let image = UIImage(data: imageData) {
            // Fallback to regular image loading
            imageView.image = image
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // No need to update
    }
}

extension Data {
    var isAnimatedGIF: Bool {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil) else {
            return false
        }
        let frameCount = CGImageSourceGetCount(source)
        return frameCount > 1
    }
}
