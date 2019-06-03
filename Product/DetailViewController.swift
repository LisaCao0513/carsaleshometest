//
//  DetailViewController.swift
//  Product
//
//  Created by black_dex on 2019/6/2.
//  Copyright © 2019 black_dex. All rights reserved.
//
import UIKit
import Alamofire
import HandyJSON
import SDWebImage
import Foundation

class DetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tbView: UITableView!
    
    var detailId :String?
    var detailImg :String?
    var contentArr = [AnyObject]()
    var imageArr = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.isNavigationBarHidden = false
        self.contentArr = []
        let nib = UINib(nibName: "DetailCell", bundle: nil) //nibName指的是我们创建的Cell文件名
        self.tbView.register(nib, forCellReuseIdentifier: "DetailCell")
        self.tbView.delegate = self
        self.tbView.dataSource = self
        let str = "https://app-car.carsalesnetwork.com.au"
        let str1 = "?username=test&password=2h7H53eXsQupXvkz"
        let urlStr = str+self.detailId!+str1
        
        Alamofire.request(urlStr, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (DataResponse) in
            switch DataResponse.result {
            case .success:
                if let value = DataResponse.result.value{
                    print("value:====\(value)")
                    let json:Dictionary = value as! Dictionary<String,AnyObject>
                    let machineList = json["Result"]
                    self.contentArr = machineList as! [AnyObject]
                    
                    self.tbView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DetailCell = tableView.dequeueReusableCell(withIdentifier:"DetailCell", for: indexPath) as!DetailCell
        let itemObj:NSDictionary! = self.contentArr[indexPath.row] as? NSDictionary
        let detailJson:NSDictionary! = itemObj.value(forKey: "Overview") as? NSDictionary

        cell.stateLabel?.text = itemObj.value(forKey: "SaleStatus") as? String
//        cell.ZC.setUrlsGroup(detailJson.value(forKey: "Photos"), titlesGroup: nil)
        cell.priceLabel?.text = detailJson.value(forKey: "Price") as? String
        cell.adressLabel?.text = detailJson.value(forKey: "Location") as? String
        cell.commentLabel?.text = itemObj.value(forKey: "Comments") as? String
        let arrar = detailJson["Photos"] as AnyObject
        self.imageArr = arrar as! [AnyObject]
        if self.imageArr.count>0 {
            let imgUrl:String! = self.imageArr[0] as? String
            cell.imgVIew.sd_setImage(with: URL.init(string: imgUrl), placeholderImage: UIImage.init(named: ""), options: SDWebImageOptions(rawValue: 0), completed: nil)
        }
//        let pageFlowView = PageFlowView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
//        pageFlowView.backgroundColor = UIColor.white
//
//        pageFlowView.delegate = self as? PageFlowViewDelegate
//        pageFlowView.dataSource = self as? PageFlowViewDataSource
//        pageFlowView.minimumPageAlpha = 0.1
//        pageFlowView.isCarousel = true
//        pageFlowView.orientation = .horizontal
//        pageFlowView.isOpenAutoScroll = true
//
//        //初始化pageControl
//        let pageControl = UIPageControl.init(frame: CGRect.init(x: 0, y: pageFlowView.bounds.height-32, width: UIScreen.main.bounds.width, height: 8))
//        pageFlowView.pageControl = pageControl
//        pageFlowView.addSubview(pageControl)
//        pageFlowView.reloadData()
//        cell.cycleView.addSubview(pageFlowView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
}

extension ViewController : PageFlowViewDelegate {
    func sizeForPageInFlowView(flowView: PageFlowView) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width-60, height: (UIScreen.main.bounds.width-60)*9/16)
    }
    
    func didScrollToPage(pageNumber: Int, inFlowView flowView: PageFlowView) {
        print("滚动到了第\(pageNumber)页")
    }
    
    func didSelectCell(subView: IndexBannerSubiew, subViewIndex subIndex: Int) {
        print("点击了第\(subIndex+1)页")
    }
    
}
extension ViewController : PageFlowViewDataSource {
    func numberOfPagesInFlowView(flowView: PageFlowView) -> Int {
        let itemObj:NSDictionary! = self.contentArr.first as? NSDictionary
        let detailJson:NSDictionary! = itemObj.value(forKey: "Overview") as? NSDictionary
        let arrar = detailJson["Photos"] as AnyObject
        let count:Int = arrar.count
        return count
    }
    
    func cellForPageAtIndex(flowView: PageFlowView, atIndex index: Int) -> IndexBannerSubiew {
        var bannerView = flowView.dequeueReusableCell()
        if bannerView == nil {
            bannerView = IndexBannerSubiew.init(frame: CGRect.init(x: 0, y: 0, width: 320, height: 200))
            bannerView?.tag = index
            bannerView?.layer.cornerRadius = 4
            bannerView?.layer.masksToBounds = true
        }
        let itemObj:NSDictionary! = self.contentArr.first as? NSDictionary
        let detailJson:NSDictionary! = itemObj.value(forKey: "Overview") as? NSDictionary
        let ar = detailJson["Photos"]
//        self.imageArr = ar as! [AnyObject]
//        bannerView?.mainImageView.image = array[index]
        
        return bannerView!
    }
}
