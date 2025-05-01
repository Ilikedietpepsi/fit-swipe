//
//  UploadOutfitView.swift
//  fit-swipe
//
//  Created by 何振民 on 2025/4/22.
//
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct UploadOutfitView: View {
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isUploading = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Your Outfit")
                .font(.title2)
                .bold()

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(10)
            } else {
                Button("Choose Image") {
                    showImagePicker = true
                }
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            if selectedImage != nil {
                Button("Upload Outfit") {
                    uploadImage()
                }
                .disabled(isUploading)
                .padding()
                .background(isUploading ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    func uploadImage() {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8),
              let user = Auth.auth().currentUser else { return }

        isUploading = true
        let outfitId = UUID().uuidString
        let storageRef = Storage.storage().reference()
            .child("outfits/\(user.uid)/\(outfitId).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ Upload failed: \(error.localizedDescription)")
                isUploading = false
                return
            }

            storageRef.downloadURL { url, error in
                if let downloadURL = url {
                    saveOutfitData(imageURL: downloadURL.absoluteString, userId: user.uid, outfitId: outfitId)
                } else {
                    print("❌ Failed to get download URL")
                }
                isUploading = false
            }
        }
    }

    func saveOutfitData(imageURL: String, userId: String, outfitId: String) {
        let outfitData: [String: Any] = [
            "userId": userId,
            "imageURL": imageURL,
            "tags": [],  // You can add this later
            "timestamp": Timestamp(),
            "rating": 0
        ]

        Firestore.firestore().collection("outfits").document(outfitId).setData(outfitData) { error in
            if let error = error {
                print("❌ Firestore save error: \(error.localizedDescription)")
            } else {
                print("✅ Outfit uploaded and saved!")
                dismiss()
            }
        }
    }
}

