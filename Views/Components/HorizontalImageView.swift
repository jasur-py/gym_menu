import SwiftUI
import UIKit

struct HorizontalImageView: View {
    let imagePaths: [String]
    @State private var loadedImages: [UIImage] = []
    @State private var loadedImageData: [Data] = []
    @State private var isExpanded = false
    @State private var selectedImageIndex: Int? = nil
    
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
                                Group {
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
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedImageIndex = index
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
            .fullScreenCover(isPresented: Binding(
                get: { selectedImageIndex != nil },
                set: { if !$0 { selectedImageIndex = nil } }
            )) {
                FullScreenImageViewer(
                    images: loadedImages,
                    imageDataList: loadedImageData,
                    initialIndex: selectedImageIndex ?? 0
                )
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

// MARK: - Full Screen Image Viewer
struct FullScreenImageViewer: View {
    let images: [UIImage]
    let imageDataList: [Data]
    let initialIndex: Int
    
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    init(images: [UIImage], imageDataList: [Data], initialIndex: Int) {
        self.images = images
        self.imageDataList = imageDataList
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            // Image pager
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    ZStack {
                        if index < imageDataList.count && imageDataList[index].isAnimatedGIF {
                            AnimatedGIFView(
                                imageData: imageDataList[index],
                                contentMode: .scaleAspectFit
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(16)
                        } else {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(16)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismiss()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // UI overlay (close button + counter)
            VStack {
                // Close button - top right
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Image counter - bottom center
                if images.count > 1 {
                    Text("\(currentIndex + 1) / \(images.count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                        .padding(.bottom, 40)
                }
            }
        }
        .statusBarHidden(true)
    }
}
