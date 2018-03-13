//
//  ViewController.swift
//  WaterfallFlowExample-Swift
//
//  Created by Liu Chuan on 2018/3/16.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit


/// 单元格重用标识符
private let CellID = "CellID"


class ViewController: UIViewController {
    
    /// 单元格的个数
    private lazy var cellCount: Int = 30
    
    /// 列数
    private lazy var listCount: Int = 3
    
    /// 集合视图
    private lazy var collectionView : UICollectionView = { [unowned self] in
        
        // 创建布局
        let layout = WaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.dataSource = self
        
        // 创建UICollectionView
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellID)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath)
        
        cell.backgroundColor = UIColor.randomColor()
        
        if indexPath.item == cellCount - 1 {
            cellCount += 30
            // asyncAfter 延迟调用.    延时0.2秒执行
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.2) {
                DispatchQueue.main.sync {   //操作完成，调用主线程来重新加载界面
                    collectionView.reloadData()
                }
            }
            print("加载更多.....")
        }
        return cell
    }
}

// MARK: - WaterfallLayoutDataSource
extension ViewController: WaterfallLayoutDataSource {
    
    func waterfallLayout(_ layout: WaterfallLayout, indexPath: IndexPath) -> CGFloat {
       
        /*** 使用arc4random_uniform函数取一个100~150的随机数（包括100和150） ****/
        return CGFloat(arc4random_uniform(150) + 100)
    }
    
    func numberOfColsInWaterfallLayout(_ layout: WaterfallLayout) -> Int {
        return listCount
    }
}

// MARK: - UIColor 扩展
extension UIColor{  // 在extension中给系统的类扩充构造函数,只能扩充`便利构造函数`
    
    /// 便利构造函数
    convenience init(r : CGFloat, g : CGFloat, b : CGFloat, alpha : CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }

    /// 随机色
    ///
    /// - Returns: UIColor
    class func randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
}

