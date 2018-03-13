//
//  WaterfallLayout.swift
//  WaterfallFlowExample-Swift
//
//  Created by Liu Chuan on 2018/3/16.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit

/// 瀑布流数据源代理
@objc protocol WaterfallLayoutDataSource : class {
    
    /// 指定ITEM的高度
    ///
    /// - Parameters:
    ///   - layout: 布局
    ///   - indexPath: 位置
    /// - Returns: 高度
    func waterfallLayout(_ layout : WaterfallLayout, indexPath : IndexPath) -> CGFloat
    
    /// 瀑布流一共有多少列，默认时三列
    /// - Parameter layout: 布局
    /// - Returns: 列数
    @objc optional func numberOfColsInWaterfallLayout(_ layout : WaterfallLayout) -> Int
}

/// 瀑布流布局
class WaterfallLayout: UICollectionViewFlowLayout {
    
    // MARK: 对外提供属性
    /// 瀑布流数据源代理
    weak var dataSource : WaterfallLayoutDataSource?
    
    // MARK: 私有属性
    /// 布局属性数组
    private lazy var attrsArray : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    
    /// 每一列的高度
    private lazy var colHeights : [CGFloat] = {
        //列数
        let cols = self.dataSource?.numberOfColsInWaterfallLayout?(self) ?? 2
        //根据列数创建数组
        var colHeights = Array(repeating: self.sectionInset.top, count: cols)
        return colHeights
    }()
    
    /// 最高的高度
    private var maxH : CGFloat = 0
    
    /// 索引
    private var startIndex = 0
}


// MARK: - 布局
extension WaterfallLayout {
    
    // 初始化\首次布局\更新布局 都会调用
    override func prepare() {
        super.prepare()
        
        /// 获取item的个数
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        
        /// 获取列数
        let cols = dataSource?.numberOfColsInWaterfallLayout?(self) ?? 2

        /// 集合视图的宽度
        let collectionW: CGFloat = collectionView!.bounds.width
        
        /// 分组的左边
        let sectionLeft: CGFloat = sectionInset.left
        
        /// 分组的右边
        let sectionRight: CGFloat = sectionInset.right
        
        /// Item的宽度（屏幕宽度铺满）
        let itemW = (collectionW - sectionLeft - sectionRight - minimumInteritemSpacing * CGFloat(cols - 1)) / CGFloat(cols)
 
        //计算所有的item的属性
        for i in startIndex ..< itemCount {
            
            // 设置每一个Item位置相关的属性
            let indexPath = IndexPath(item: i, section: 0)
            
            ///  根据位置创建Attributes属性
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 获取CELL的高度
            guard let height = dataSource?.waterfallLayout(self, indexPath: indexPath) else {
                fatalError("请设置数据源,并且实现对应的数据源方法")
            }
            /// 取出当前列所属的列索引
            let index = i % cols
            
            /// 获取当前列的总高度
            var colH = colHeights[index]
            
            /// 当前 列的高度 + 当前ITEM 的高度 + 单元格之间的最小行间距
            colH = colH + height + minimumLineSpacing
            
            // 重新设置当前列的高度
            colHeights[i % cols] = colH
            
            // 设置item的属性
            attrs.frame = CGRect(x: sectionInset.left + (minimumInteritemSpacing + itemW) * CGFloat(index), y: colH - height - minimumLineSpacing, width: itemW, height: height)
            
            attrsArray.append(attrs)
        }
        // 记录最大值
        maxH = colHeights.max()!
        
        // 给startIndex重新赋值
        startIndex = itemCount
    }
}
// MARK: - 重写 UICollectionViewLayout 方法
extension WaterfallLayout {
    // 返回所有的布局属性
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    // 返回 collectionView 内容大小
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 0, height: maxH + sectionInset.bottom - minimumLineSpacing)
    }
}
