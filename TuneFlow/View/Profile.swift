//
//  Profile.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 21/06/2026.
//

import UIKit
import PhotosUI

class Profile: UIViewController {
    
    @IBOutlet weak var profileShape: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        started()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileShape.layer.cornerRadius = profileShape.frame.width / 2
        profileShape.clipsToBounds = true
        profileShape.imageView?.contentMode = .scaleAspectFill
    }
    
    private func started() {
        
        profileShape.layer.cornerRadius = profileShape.frame.width / 2
        profileShape.clipsToBounds = true
        profileShape.imageView?.contentMode = .scaleAspectFill
        barButtonItem()
        
    }
    
    func barButtonItem() {
        let bar = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(LogoutPressed))
        navigationItem.rightBarButtonItem = bar
    }
    
    @objc
    private func LogoutPressed() {
        
        // LogOut
        
    }
    
    
    
    @IBAction func changeImage(_ sender: UIButton) {
        
        // when user want add or change profile picture
        
        // Action Sheet for Take camera or change image
        showPhotoAlert()
    }
    
    func showPhotoAlert() {
        let alert = UIAlertController(title: "Change photo", message: "You can change or take a photo!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.getPhotoAndChanged(type: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Open Libraby", style: .default, handler: { [weak self] _ in
            self?.getPhotoAndChanged(type: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func getPhotoAndChanged(type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        
        picker.sourceType = type
        picker.allowsEditing = true
        
        picker.delegate = self
        
        present(picker, animated: true)
        
        
    }
    
}


extension Profile: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }
        
        // ✅ Resize image to match button size
        let size = profileShape.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        profileShape.setImage(resizedImage, for: .normal)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}
