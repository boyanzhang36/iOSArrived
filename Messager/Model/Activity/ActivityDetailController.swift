//
//  ActivityDetailController.swift
//  Messager
//
//  Created by 王品 on 2020/10/22.
//

import UIKit
import Firebase
import ButtonEnLargeClass

class ActivityDetailController: UIViewController {
    var activityID = ""
    var starterUser = ""
    var p1User = ""
    var p2User = ""
    var p3User = ""
    var p4User = ""
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var startGroupChatButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.isHidden = true
        startGroupChatButton.isHidden = true
        loadData()
        getUserInfo()
        let button = UIButton.init(type: .custom)

                button.setEnLargeEdge(224,0,0,0)
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
        let query = db.collection(K.FStore.act).whereField("uid", isEqualTo: activityID)
        query.getDocuments { [self] (querySnapshot, error) in
            if let e = error{
                print("error happens in getDocuments\(e)" )
            }
            else{
                let doc = querySnapshot!.documents[0]
                let data = doc.data()
                starterUser = data["userId"] as! String
                p1User = data["userId"] as! String
                p2User = data["userId"] as! String
                p3User = data["userId"] as! String
                p4User = data["userId"] as! String
                }
        }
    }
    
    func loadData() {
        let query = db.collection(K.FStore.act).whereField("uid", isEqualTo: activityID)
        query.getDocuments { [self] (querySnapshot, error) in
            if let e = error{
                print("error happens in getDocuments\(e)" )
            }
            else{
                let doc = querySnapshot!.documents[0]
                let data = doc.data()
                activityTitle.text = data[K.Activity.title] as? String
                let image = data[K.Activity.image] as! String
                // read date later
                date.text = ""
                let starterId = data["userId"] as? String
                if starterId == Auth.auth().currentUser?.uid {
                    editButton.isHidden = false
                    startGroupChatButton.isHidden = false
                }
                details.text = data["actDetail"] as? String
                
                let userInfo = db.collection("User")
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
                                                cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
                                                    if let error = error {
                                                        print(error.localizedDescription)
                                                    } else {
                                                        self.starterImage.image = UIImage(data: data!)
                                                    }
                                                }

                            }
                        }
                }

                
                let cloudFileRef = self.storage.reference(withPath: "activity-images/"+image)
                            cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    self.image.image = UIImage(data: data!)
                                }
                            }

                        
            }

        }
    }
}