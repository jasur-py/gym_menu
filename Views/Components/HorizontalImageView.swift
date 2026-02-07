import SwiftUI
import UIKit

struct HorizontalImageView: View {
    let imagePaths: [String]
    @State private var loadedImages: [UIImage] = []
    @State private var loadedImageData: [Data] = []
    @State private var isExpanded = false
    
    var body: some View {
        if !imagePaths.isEmpty {
            VStack(spacing: 8) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                    loadImages()
                }) {
                    HStack {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(isExpanded ? "Hide Images (\(imagePaths.count))" : "Show Images (\(imagePaths.count))")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                if isExpanded {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 12) {
                            ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                                // Use AnimatedGIFView for GIFs, regular Image for others
                                if index < loadedImageData.count && loadedImageData[index].isAnimatedGIF {
                                    AnimatedGIFView(imageData: loadedImageData[index])
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(8)
                                } else {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                            }
                            
                            // Show placeholders for images still loading
                            ForEach(loadedImages.count..<imagePaths.count, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(ProgressView())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 140)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .onAppear {
                loadImages()
            }
        }
    }
    
    private func loadImages() {
        if loadedImages.isEmpty {
            for path in imagePaths {
                if let imageData = ImageStorageService.shared.loadImageData(from: path),
                   let image = UIImage(data: imageData) {
                    loadedImages.append(image)
                    loadedImageData.append(imageData)
                }
            }
        }
    }
}

