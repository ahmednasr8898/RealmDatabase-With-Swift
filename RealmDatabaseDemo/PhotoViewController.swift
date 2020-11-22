//
//  PhotoViewController.swift
//  RealmDatabaseDemo
//
//  Created by Ahmed Nasr on 11/22/20.
//

import UIKit
import RealmSwift

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageSave: UIImageView!
    @IBOutlet weak var imagefetch: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //for open gallary to select photo
    @IBAction func openGallaryOnClick(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    //when finsh from select photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return }
        imageSave.image = image
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    //save photo to realm Database
    @IBAction func saveImageOnClick(_ sender: Any) {
        guard  let data = imageSave.image?.jpegData(compressionQuality: 0.5) else { return }
        let photo = PhotoModel()
        photo.imageData = data as NSData
        let realm = try! Realm()
        try! realm.write {
         realm.add(photo)
        }
    }
    //get photos from realm database
    @IBAction func fetchImageOnClick(_ sender: Any) {
        let realm = try! Realm()
        let arr = realm.objects(PhotoModel.self)
        imagefetch.image = UIImage(data: arr[0].imageData as Data)
    }
}

