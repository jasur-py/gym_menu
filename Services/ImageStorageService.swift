import UIKit

class ImageStorageService {
    static let shared = ImageStorageService()
    
    private let imagesDirectoryName = "Images"
    
    private init() {}
    
    private var imagesDirectoryURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesDirectory = documentsDirectory.appendingPathComponent(imagesDirectoryName)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
            try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
        
        return imagesDirectory
    }
    
    func saveImage(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadImage(from path: String) -> UIImage? {
        let fileURL = imagesDirectoryURL.appendingPathComponent(path)
        
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return nil
        }
        
        return image
    }
    
    func deleteImage(at path: String) {
        let fileURL = imagesDirectoryURL.appendingPathComponent(path)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func getImageURL(for path: String) -> URL {
        return imagesDirectoryURL.appendingPathComponent(path)
    }
}

