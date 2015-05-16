//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Scott Kornblatt on 2/4/15.
//  Copyright (c) 2015 Scott Kornblatt. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
  var usdaItem:USDAItem?
  
  @IBOutlet weak var textView: UITextView!
  
  @IBAction func eatItBarButtonItemPressed(sender: UIBarButtonItem) {
    
  }
  

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    if usdaItem != nil {
      textView.attributedText = createAttributedString(usdaItem!)
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func usdaItemDidComplete(notification: NSNotification) {
    println("usdaItemDidComplete in DetailViewController")
    usdaItem = notification.object as? USDAItem
    
    if self.isViewLoaded() && self.view.window != nil {
      textView.attributedText = createAttributedString(usdaItem!)
    }
  }
  
  func createAttributedString(usdaItem: USDAItem!) -> NSAttributedString {
    
    var itemAttributedString = NSMutableAttributedString()
    
    var centeredParagraphStyle = NSMutableParagraphStyle()
    centeredParagraphStyle.alignment = NSTextAlignment.Center
    centeredParagraphStyle.lineSpacing = 10.0
    
    var titleAttributesDictionary = [
      NSForegroundColorAttributeName: UIColor.blackColor(),
      NSFontAttributeName: UIFont.boldSystemFontOfSize(22.0),
      NSParagraphStyleAttributeName: centeredParagraphStyle]
    
    let titleString = NSAttributedString(string: "\(usdaItem.name)\n", attributes: titleAttributesDictionary)
    
    itemAttributedString.appendAttributedString(titleString)
    
    var leftAlignedParagraphStyle = NSMutableParagraphStyle()
    leftAlignedParagraphStyle.alignment = NSTextAlignment.Left
    leftAlignedParagraphStyle.lineSpacing = 20.0
    
    var styleFirstWordAttributesDictionary = [
      NSForegroundColorAttributeName: UIColor.blackColor(),
      NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0),
      NSParagraphStyleAttributeName: leftAlignedParagraphStyle]
    
    var style1AttributesDictionary = [
      NSForegroundColorAttributeName: UIColor.darkGrayColor(),
      NSFontAttributeName: UIFont.systemFontOfSize(18.0),
      NSParagraphStyleAttributeName: leftAlignedParagraphStyle]
    
    var style2AttributesDictionary = [
      NSForegroundColorAttributeName: UIColor.lightGrayColor(),
      NSFontAttributeName: UIFont.systemFontOfSize(18.0),
      NSParagraphStyleAttributeName: leftAlignedParagraphStyle]
    
    let calciumTitleString = NSAttributedString(string: "Calcium ", attributes: styleFirstWordAttributesDictionary)
    let calciumBodySring = NSAttributedString(string: "\(usdaItem.calcium)% \n", attributes: style1AttributesDictionary)
    itemAttributedString.appendAttributedString(calciumTitleString)
    itemAttributedString.appendAttributedString(calciumBodySring)
    
    let carbohydrateTitleString = NSAttributedString(string: "Carbohydrate ", attributes: styleFirstWordAttributesDictionary)
    let carbohydrateBodyString = NSAttributedString(string: "\(usdaItem.carbohydrate)% \n", attributes: style1AttributesDictionary)
    itemAttributedString.appendAttributedString(carbohydrateTitleString)
    itemAttributedString.appendAttributedString(carbohydrateBodyString)
    
    let cholesterolTitleString = NSAttributedString(string: "Cholesterol ", attributes: styleFirstWordAttributesDictionary)
    let cholesterolBodyString = NSAttributedString(string: "\(usdaItem.cholesterol) % \n", attributes: style1AttributesDictionary)
    itemAttributedString.appendAttributedString(cholesterolTitleString)
    itemAttributedString.appendAttributedString(cholesterolBodyString)
    
    let energyTitleString = NSAttributedString(string: "Energy ", attributes: styleFirstWordAttributesDictionary)
    let energyBodyString = NSAttributedString(string: "\(usdaItem.energy)% \n", attributes: style1AttributesDictionary)
    itemAttributedString.appendAttributedString(energyTitleString)
    itemAttributedString.appendAttributedString(energyBodyString)
    
    let fatTotalTitleString = NSAttributedString(string: "FatTotal ", attributes: styleFirstWordAttributesDictionary)
    let fatTotalBodyString = NSAttributedString(string: "\(usdaItem.fatTotal)% \n", attributes: style1AttributesDictionary)
    itemAttributedString.appendAttributedString(fatTotalTitleString)
    itemAttributedString.appendAttributedString(fatTotalBodyString)
    
    let proteinTitleString = NSAttributedString(string: "Protein ", attributes: styleFirstWordAttributesDictionary)
    let proteinBodyString = NSAttributedString(string: "\(usdaItem.protein)% \n", attributes: style1AttributesDictionary)
    itemAttributedString.appendAttributedString(proteinTitleString)
    itemAttributedString.appendAttributedString(proteinBodyString)
    
    let sugarTitleString = NSAttributedString(string: "Sugar ", attributes: styleFirstWordAttributesDictionary)
    let sugarBodyString = NSAttributedString(string: "\(usdaItem.sugar)% \n", attributes: style1AttributesDictionary)
    itemAttributedString.appendAttributedString(sugarTitleString)
    itemAttributedString.appendAttributedString(sugarBodyString)
    
    let vitaminCTitleString = NSAttributedString(string: "VitaminC ", attributes: styleFirstWordAttributesDictionary)
    let vitaminCBodyString = NSAttributedString(string: "\(usdaItem.vitaminC)% \n", attributes: style1AttributesDictionary)
    itemAttributedString.appendAttributedString(vitaminCTitleString)
    itemAttributedString.appendAttributedString(vitaminCBodyString)
    
    return itemAttributedString
  }
}