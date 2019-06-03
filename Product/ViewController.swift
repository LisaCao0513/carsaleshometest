//
//  ViewController.swift
//  Product
//
//  Created by black_dex on 2019/5/31.
//  Copyright © 2019 black_dex. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON
import SDWebImage

struct Product:HandyJSON {
    var Id:String = ""
    var Location:String = ""
    var MainPhoto:String = ""
    var Price:String = ""
    var Title:String = ""
    var DetailsUrl:String = ""
}
class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tbView: UITableView!
//    var contentArr:NSMutableArray?
    var contentArr = [AnyObject]()//用var声明
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.isNavigationBarHidden = false
        self.contentArr = []
//        self.contentArr = self.readDataSource()
        
        let nib = UINib(nibName: "ProductCell", bundle: nil) //nibName指的是我们创建的Cell文件名
        self.tbView.register(nib, forCellReuseIdentifier: "ProductCell")
        
//        let headers: HTTPHeaders = [
//            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
//            "Accept": "application/json"
//        ]
//        let parameters:Dictionary = ["username":"test","password":"2h7H53eXsQupXvkz"]
        Alamofire.request("https://app-car.carsalesnetwork.com.au/stock/car/test/v1/listing?username=test&password=2h7H53eXsQupXvkz", method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (DataResponse) in
            switch DataResponse.result {
            case .success:
                if let value = DataResponse.result.value{
                print("value:====\(value)")
                let json:Dictionary = value as! Dictionary<String,AnyObject>
                let machineList = json["Result"]
                    self.contentArr = machineList as! [AnyObject]
                    print("array:====\(self.contentArr)")
//                    for dic in machineList{
//                        self.contentArr.append(dic as AnyObject)
//                    }
                    self.tbView.reloadData()
                }
            case .failure(let error):
                
                let alert = UIAlertController(title: "请求出错", message: error.localizedDescription, preferredStyle: .alert)
                //创建UIAlertController的Action
                let OK = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                    print("you selected ok")
                }
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
                    print("you selected cancel")
                }
                //将Actiont加入到AlertController
                alert.addAction(OK)
                alert.addAction(Cancel)
                //以模态方式弹出
                self.present(alert, animated: true, completion: nil)
                print(error)
            }
        }
    }

    func readDataSource() -> NSArray! {
        var jsonArr:NSArray = []
        let path = Bundle.main.path(forResource: "data.json", ofType: nil)
        let url = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: url)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            jsonArr = jsonData as! NSArray
        } catch let err as Error? {
            print("err:\(String(describing: err))")
        }
        return jsonArr
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ProductCell = tableView.dequeueReusableCell(withIdentifier:"ProductCell", for: indexPath) as!ProductCell
        let itemObj:NSDictionary! = self.contentArr[indexPath.row] as? NSDictionary
        let imgUrl:String! = itemObj.value(forKey: "MainPhoto") as? String
        cell.imgView.sd_setImage(with: URL.init(string: imgUrl), placeholderImage: UIImage.init(named: ""), options: SDWebImageOptions(rawValue: 0), completed: nil)
        cell.titleLabel?.text = itemObj.value(forKey: "Title") as? String
        cell.priceLabel?.text = itemObj.value(forKey: "Price") as? String
        cell.adressLabel?.text = itemObj.value(forKey: "Location") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height/2
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemObj:NSDictionary! = self.contentArr[indexPath.row] as? NSDictionary
        let storyID = "DetailViewController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var nextView:DetailViewController
        nextView = storyboard.instantiateViewController(withIdentifier: storyID) as! DetailViewController
        nextView.detailId = itemObj["DetailsUrl"] as? String
        nextView.detailImg = itemObj["MainPhoto"] as? String
//        self.navigationController?.pushViewController(nextView, animated: true)
        self.present(nextView, animated: true, completion: nil)
    }
}

