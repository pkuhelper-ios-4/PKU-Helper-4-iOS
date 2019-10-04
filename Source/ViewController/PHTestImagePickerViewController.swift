//
//  PHTestImagePickerViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

class PHTestImagePickerViewController: PHBaseViewController {

    let photoPickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.allowsEditing = false
        controller.mediaTypes = ["public.image"]
        return controller
    }()


    let pickerToggleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("Choose a phone", for: .normal)
        button.titleLabel?.textColor = .black
        return button
    }()

    let selectedImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFit
        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        photoPickerController.delegate = self

        view.addSubview(selectedImageView)
        selectedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(pickerToggleButton)
        pickerToggleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(50)
            make.size.equalTo(CGSize(width: 160, height: 40))
        }

        pickerToggleButton.addTarget(self, action: #selector(PHTestImagePickerViewController.toggleButtonTapped), for: .touchUpInside)
    }

    @objc func toggleButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            debugPrint("access denied")
            return
        }
        present(photoPickerController, animated: true, completion: nil)
    }
}


extension PHTestImagePickerViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origin = info[.originalImage] as? UIImage? {
            selectedImageView.image = origin
        }
        photoPickerController.dismiss(animated: true, completion: nil)
    }

}


extension PHTestImagePickerViewController: UINavigationControllerDelegate {

}
**/
