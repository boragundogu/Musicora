//
//  ProfileViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 28.05.2025.
//

import UIKit
import SnapKit
import AVFoundation
import Photos

final class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let profileView = ProfileView()
    
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        loadUserData()
        loadProfileImage()
    }
    
    private func setupNavigationBar() {
        title = NSLocalizedString("profile_page_title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupActions() {
        profileView.changePasswordButton.addTarget(self, action: #selector(didTapChangePassword), for: .touchUpInside)
        profileView.logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        profileView.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        profileView.changeLanguageButton.addTarget(self, action: #selector(languageButtonTapped), for: .touchUpInside)
    }
    
    private func loadUserData() {
        guard let user = User(from: UserDefaults.standard) else {
            showAlert(message: "Kullanıcı bilgileri yüklemede hata")
            return
        }
        profileView.configure(with: user)
    }
    
    @objc func languageButtonTapped() {
        let languageVC = LanguageSelectionViewController()
        languageVC.delegate = self
        navigationController?.pushViewController(languageVC, animated: true)
    }
    
    @objc private func editButtonTapped() {
        
        let alertController = UIAlertController(title: "Profil Fotoğrafı Seç", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Kamera", style: .default) { _ in
            self.checkCameraPermission()
        }
        let galleryAction = UIAlertAction(title: "Galeri", style: .default) { _ in
            self.checkLibraryPermission()
        }
        
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func saveImageToDocuments(image: UIImage) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = "profileImage.jpg"
        let fileUrl = documentDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        do {
            try data.write(to: fileUrl)
            print("resim kaydedildi")
        } catch {
            print("resim kayıt hatası:", error)
        }
    }
    
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        } else {
            printContent("kamera bulunamıyor")
            let alert = UIAlertController(title: "Hata", message: "Cihaz kamerası bulunamadı", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            print("resim seçmede hata")
            return
        }
        
        profileView.profileImageView.image = selectedImage
        
        saveImageToDocuments(image: selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func loadImageFromDocuments() -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileName = "profileImage.jpg"
        let fileUrl = documentsDirectory.appendingPathComponent(fileName)
        
        if let data = try? Data(contentsOf: fileUrl) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func loadProfileImage() {
        if let savedImage = loadImageFromDocuments() {
            profileView.profileImageView.image = savedImage
        } else {
            profileView.profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    @objc private func didTapChangePassword() {
        let changePasswordVC = ChangePasswordViewController()
        navigationController?.pushViewController(changePasswordVC, animated: true)
    }
    
    @objc private func didTapLogout() {
        let alert = UIAlertController(title: "Çıkış Yap",
                                      message: "Çıkış yapmak istediğinize emin misiniz?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { _ in
            self.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        let welcomeVC = WelcomeViewController()
        let navController = UINavigationController(rootViewController: welcomeVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            openCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.openCamera()
                    } else {
                        print("kamera izni reddedildi.")
                    }
                }
            }
            
        case .denied, .restricted:
            showSettingsAlert(for: .camera)
            
        @unknown default:
            print("bilinmeyen kamera izin durumu")
        }
        
    }
    
    private func checkLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            openGallery()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.openGallery()
                    } else {
                        print("galeri izni reddedildi.")
                    }
                }
            }
        case .denied, .restricted:
            showSettingsAlert(for: .photoLibrary)
            
        @unknown default:
            print("bilinmeyen galeri izin durumu")
        }
    }
    
    private enum PermissionType {
        case camera
        case photoLibrary
    }
    
    private func showSettingsAlert(for type: PermissionType) {
        let titleKey: String
        let messageKey: String
        
        switch type {
        case .camera:
            titleKey = "camera_permission_title"
            messageKey = "camera_permission_message"
        case .photoLibrary:
            titleKey = "photolibrary_permission_title"
            messageKey = "photolibrary_permission_message"
        }
        
        let title = NSLocalizedString(titleKey, comment: "")
        let message = NSLocalizedString(messageKey, comment: "")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("settings_button_title", comment: ""), style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_button_title", comment: ""), style: .cancel)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension ProfileViewController: LanguageSelectionDelegate {
    
    func didChangeLanguage() {
        
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            print("Ana pencere bulunamadı.")
            return
        }
        
        let splashViewController = SplashViewController()
        let rootViewController = UINavigationController(rootViewController: splashViewController)
        
        window.rootViewController = rootViewController
        
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.3
        
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: nil)
    }
}
