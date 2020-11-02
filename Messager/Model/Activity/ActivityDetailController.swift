//
//  ActivityDetailController.swift
//  Messager
//
//  Created by 王品 on 2020/10/22.
//

import UIKit
import Firebase
import ButtonEnLargeClass
import MapKit
import FirebaseUI

class ActivityDetailController: UIViewController {
    var activityID = ""
    var starterUser = ""
    var p1User = ""
    var p2User = ""
    var p3User = ""
    var p4User = ""
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var userList = [User]()
    
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var startGroupChatButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.isHidden = true
        startGroupChatButton.isHidden = true
        loadData()
        getUserInfo()
        //let starterButton = UIButton.init(type: .custom)
        //starterButton.setEnLargeEdge(20,20,414,414)
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var details: UILabel!
    
    @IBOutlet weak var starterImage: UIImageView!
    @IBOutlet weak var starterName: UILabel!
    
    @IBOutlet weak var p1Image: UIImageView!
    @IBOutlet weak var p1Name: UILabel!
    @IBOutlet weak var p2Image: UIImageView!
    @IBOutlet weak var p2Name: UILabel!
    @IBOutlet weak var p3Image: UIImageView!
    @IBOutlet weak var p3Name: UILabel!
    @IBOutlet weak var p4Image: UIImageView!
    @IBOutlet weak var p4Name: UILabel!
    @IBOutlet weak var starterButton: UIButton!
    @IBOutlet weak var p1Button: UIButton!
    @IBOutlet weak var p2Button: UIButton!
    @IBOutlet weak var p3Button: UIButton!
    @IBOutlet weak var p4Button: UIButton!
    
    
    @IBAction func startGroupChat(_ sender: Any) {
        
        
    }
    
    
    @IBAction func toStarter(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let starterVC = storyboard.instantiateViewController(identifier: "OtherUserVC") as OtherUserViewController
        starterVC.currentUserID = starterUser
        print(starterUser)
        self.navigationController!.show(starterVC, sender: self)
    }
    
    @IBAction func edit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "editActivity") as? EditActivityController else {  return }
        editVC.activityID = self.activityID
        editVC.image = self.image.image
        editVC.titleAct = self.activityTitle.text!
        editVC.detail = self.details.text!
        editVC.location = self.location.text!
        self.present(editVC, animated: true, completion: nil)
    }
    
    func getUserInfo(){
        let docRef = db.collection(K.FStore.act).document(activityID)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                starterUser = data!["actCreatorId"] as! String
                p1User = self.starterUser
                p2User = self.starterUser
                p3User = self.starterUser
                p4User = self.starterUser
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    func loadData() {
        let docRef = db.collection(K.FStore.act).document(activityID)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.activityTitle.text = data?[K.Activity.title] as? String
                let image = data![K.Activity.image] as! String
                // read date later
                self.date.text = ""
                let starterId = data!["actCreatorId"] as? String
                if starterId == Auth.auth().currentUser?.uid {
                    self.editButton.isHidden = false
                    self.startGroupChatButton.isHidden = false
                }
                self.details.text = data!["actDetail"] as? String
                let joins = data![K.Activity.join] as! [String] //String array
                
                let userInfo = self.db.collection("User")
                let query = userInfo.whereField("id", isEqualTo: starterId)
                query.getDocuments { [self] (querySnapshot, error) in
                            if let error = error {
                                print("Error getting documents: \(error)")
                            } else {
                                for document in querySnapshot!.documents {
                                    let data = document.data()
                                    let uimage = data["avatarLink"] as! String
                                    let name = data["username"] as! String
                                    self.starterName.text = name
                                    let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+uimage)
                                    self.starterImage.sd_setImage(with: cloudFileRef)
                            }
                        }
                }
                
                //find userInfo for join list, Chongjing Part
                for join in joins {
                    let query = userInfo.whereField("id", isEqualTo: starterId)
                    query.getDocuments { [self] (querySnapshot, error) in
                                if let error = error {
                                    print("Error getting documents: \(error)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let data = document.data()
                                        var user = User()
                                        user.avatarLink = data["avatarLink"] as! String
                                        user.username = data["username"] as! String
                                        user.email = data["email"] as! String
                                        user.id = data["id"] as! String
                                        user.intro = data["intro"] as! String
                                        user.location = data["location"] as! String
                                        user.pushId = data["pushId"] as! String
                                        user.status = data["status"] as! String
                                        userList.append(user)
                                }
                            }
                        print("userList is: \(userList)")
                    }
                }
                
                let cloudFileRef = self.storage.reference(withPath: "activity-images/"+image)
                self.image.sd_setImage(with: cloudFileRef)

                        
            } else {
                print("Document does not exist")
            }
        }
        
        
//        docRef.getDocument() { (document, error) in
//            if let e = error{
//                print("error happens in getDocuments\(e)" )
//            }
//            else{
//                let data = document.data()
//                activityTitle.text = data?[K.Activity.title] as? String
//                let image = data[K.Activity.image] as! String
//                // read date later
//                self.date.text = ""
//                let starterId = data["actCreatorId"] as? String
//                if starterId == Auth.auth().currentUser?.uid {
//                    self.editButton.isHidden = false
//                    self.startGroupChatButton.isHidden = false
//                }
//                details.text = data["actDetail"] as? String
//
//                let userInfo = self.db.collection("User")
//                let query = userInfo.whereField("id", isEqualTo: starterId)
//                query.getDocuments { [self] (querySnapshot, error) in
//                            if let error = error {
//                                print("Error getting documents: \(error)")
//                            } else {
//                                for document in querySnapshot!.documents {
//                                    let data = document.data()
//                                    let uimage = data["avatarLink"] as! String
//                                    let name = data["username"] as! String
//                                    self.starterName.text = name
//                                    let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+uimage)
//                                                cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
//                                                    if let error = error {
//                                                        print(error.localizedDescription)
//                                                    } else {
//                                                        self.starterImage.image = UIImage(data: data!)
//                                                    }
//                                                }
//
//                            }
//                        }
//                }
//
//
//                let cloudFileRef = self.storage.reference(withPath: "activity-images/"+image)
//                            cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
//                                if let error = error {
//                                    print(error.localizedDescription)
//                                } else {
//                                    self.image.image = UIImage(data: data!)
//                                }
//                            }
//
//
//            }
//
//        }
    }
}
