import Foundation
import UIKit
import PageMenu

class MainMenuViewController: BaseViewController, CAPSPageMenuDelegate {
    
    var pageMenu: CAPSPageMenu?
    var controllerArray: [UIViewController] = []
    var currentIndex: Int = 0
    
    @IBOutlet weak var mainscreen: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 各ページのViewcontrollerを用意する
        let articleListStoryboard = UIStoryboard(name: "ArticleList", bundle: nil)
        let articleListViewController = articleListStoryboard.instantiateInitialViewController() as! UIViewController
        let stockListStoryboard = UIStoryboard(name: "StockList", bundle: nil)
        let stockListViewController = stockListStoryboard.instantiateInitialViewController() as! UIViewController
        let tagListStoryboard = UIStoryboard(name: "TagList", bundle: nil)
        let tagListViewController = tagListStoryboard.instantiateInitialViewController() as! UIViewController
        controllerArray = [articleListViewController, stockListViewController, tagListViewController]
        
        let baseColor = UIColor(red: 121/255, green: 183/255, blue: 74/255, alpha: 1)
        let menuParams: [CAPSPageMenuOption] = [
            .SelectionIndicatorHeight(4),
            .BottomMenuHairlineColor(baseColor),
            .SelectionIndicatorColor(baseColor),
            .ViewBackgroundColor(UIColor.whiteColor()),
            .SelectedMenuItemLabelColor(baseColor),
            .UnselectedMenuItemLabelColor(UIColor.grayColor()),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .MenuItemWidthBasedOnTitleTextWidth(true)
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.mainscreen.frame.width, self.mainscreen.frame.height), pageMenuOptions: menuParams)
        
        pageMenu!.delegate = self
        self.mainscreen.addSubview(pageMenu!.view)
    }
    
    override func viewWillAppear(animated: Bool) {
        let currentVC = controllerArray[currentIndex] as! PageViewController
        self.navigationItem.setRightBarButtonItems(currentVC.navigationRightBarButtons(), animated: false)
        addObservePushVCFromChildVC()
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeObservePushVCFromChildVC()
    }
    
    func didMoveToPage(controller: UIViewController, index: Int) {
        currentIndex = index
        addObservePushVCFromChildVC()
    }
    
    func willMoveToPage(controller: UIViewController, index: Int) {
        // 子VCの監視を外す
        removeObservePushVCFromChildVC()
        // navigationBarButtonの設定
        if let nextVC = controllerArray[index] as? PageViewController {
            self.navigationItem.setRightBarButtonItems(nextVC.navigationRightBarButtons(), animated: true)
        }
    }
    
    // 子VCの投げてくるpushViewControllerを拾って遷移する
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if object as! PageViewController == controllerArray[currentIndex] && keyPath == "pushViewController" {
            let pageViewController = controllerArray[currentIndex] as! PageViewController
            self.navigationController?.pushViewController(pageViewController.pushViewController!, animated: true)
        }
    }
    
    // 子VCの遷移をキャッチ
    private func addObservePushVCFromChildVC() {
        let currentVC = controllerArray[currentIndex] as! PageViewController
        currentVC.addObserver(self, forKeyPath: "pushViewController", options: .New, context: nil)
    }
    
    private func removeObservePushVCFromChildVC() {
        let currentVC = controllerArray[currentIndex] as! PageViewController
        currentVC.removeObserver(self, forKeyPath: "pushViewController")
    }

}