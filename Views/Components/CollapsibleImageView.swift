import SwiftUI
import UIKit

struct CollapsibleImageView: View {
    let image: UIImage?
    let imagePath: String?
    
    @State private var isExpanded = false
    @State private var loadedImage: UIImage?
    
    var body: some View {
        if image != nil || imagePath != nil {
            VStack(spacing: 8) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                    
                    // Load image if not already loaded and we have a path
                    if loadedImage == nil, let path = imagePath, image == nil {
                        loadedImage = ImageStorageService.shared.loadImage(from: path)
                    }
                }) {
                    HStack {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(isExpanded ? "Hide Image" : "Show Image")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                if isExpanded {
                    if let displayImage = image ?? loadedImage {
                        Image(uiImage: displayImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        ProgressView()
                            .padding()
                            .transition(.opacity)
                    }
                }
            }
            .onAppear {
                // Pre-load image if we have a path but no image
                if image == nil, let path = imagePath {
                    loadedImage = ImageStorageService.shared.loadImage(from: path)
                } else if let img = image {
                    loadedImage = img
                }
            }
        }
    }
}

