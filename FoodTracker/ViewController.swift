//
//  ViewController.swift
//  FoodTracker
//
//  Created by Scott Kornblatt on 2/4/15.
//  Copyright (c) 2015 Scott Kornblatt. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
  
  @IBOutlet weak var tableView: UITableView!
  
  let kAppId = "31200cf5"
  let kAppKey = "41fcdaf89e9bcac65bf051632eb160dd"
  
  var searchController:UISearchController!
  var suggestedSearchFoods:[String] = []
  var filterSuggestedSearchFoods:[String] = []
  var apiSearchForFoods:[(name: String, idValue: String)] = []
  
  var favoritedUSDAItems:[USDAItem] = []
  var filteredFavoritedUSDAItems:[USDAItem] = []
  
  var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
  
  var jsonResponse:NSDictionary!
  
  var dataController = DataController()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = false
    
    searchController.searchBar.frame = CGRectMake(searchController.searchBar.frame.origin.x, searchController.searchBar.frame.origin.y, searchController.searchBar.frame.width, 44.0)
    
    self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles
    
    searchController.searchBar.delegate = self
    
    tableView.tableHeaderView = searchController.searchBar
    
    // ensures the searchController is displayed
    // in the current view controller - bull shit!!!...but needed
    definesPresentationContext = true
    
    self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
    
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "toDetailVCSegue" {
      if sender != nil {
        var detailVC = segue.destinationViewController as DetailViewController
        detailVC.usdaItem = sender as? USDAItem
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // Mark - TableViewDelegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
    
    if selectedScopeButtonIndex == 0 {
      if self.searchController.active {
        return self.filterSuggestedSearchFoods.count
      }
      else {
        return self.suggestedSearchFoods.count
      }
    }
    else if selectedScopeButtonIndex == 1 {
      return self.apiSearchForFoods.count
    }
    else {
      if self.searchController.active {
        return self.filteredFavoritedUSDAItems.count
      }
      else {
        return favoritedUSDAItems.count
      }
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
    
    var foodName:String
    
    let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
    
    if selectedScopeButtonIndex == 0 {
      if self.searchController.active {
        foodName = filterSuggestedSearchFoods[indexPath.row]
      }
      else {
        foodName = suggestedSearchFoods[indexPath.row]
      }
    }
    else if selectedScopeButtonIndex == 1 {
      foodName = self.apiSearchForFoods[indexPath.row].name
    }
    else {
      if self.searchController.active {
        foodName = self.filteredFavoritedUSDAItems[indexPath.row].name
      }
      else {
        foodName = self.favoritedUSDAItems[indexPath.row].name
      }
    }
    
    cell.textLabel?.text = foodName
    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    
    return cell
  }
  
  // Mark - UITableViewDelegate
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
    
    if selectedScopeButtonIndex == 0 {
      var searchFoodName:String
      
      if self.searchController.active {
        searchFoodName = filterSuggestedSearchFoods[indexPath.row]
      }
      else {
        searchFoodName = suggestedSearchFoods[indexPath.row]
      }
      self.searchController.searchBar.selectedScopeButtonIndex = 1
      makeRequest(searchFoodName)
    }
    else if selectedScopeButtonIndex == 1 {
      self.performSegueWithIdentifier("toDetailVCSegue", sender: nil)
      let idValue = apiSearchForFoods[indexPath.row].idValue
      dataController.saveUSDAItemForId(idValue, json: self.jsonResponse)
    }
    else if selectedScopeButtonIndex == 2 {
      if self.searchController.active {
        let usdaItem = filteredFavoritedUSDAItems[indexPath.row]
        self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
      }
      else {
        let usdaItem = favoritedUSDAItems[indexPath.row]
        self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
      }
    }
    
    
  }
  
  // Mark - UISearchResultsUpdating
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    
    let searchString = self.searchController.searchBar.text
    let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
    self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
    self.tableView.reloadData()
    
  }
  
  // Mark - UISearchBarDelegate
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    self.searchController.searchBar.selectedScopeButtonIndex = 1
    makeRequest(searchBar.text)
  }
  
  func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    
    if selectedScope == 2 {
      requestFavoritedUSDAItems()
    }
    
    self.tableView.reloadData()
  }
  
  // Mark - Helper Functions
  
  func filterContentForSearch(searchText: String, scope: Int) {
    
    if scope == 0 {
      self.filterSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food: String) -> Bool in
        var foodMatch = food.rangeOfString(searchText)
        return foodMatch != nil
      })
    }
    else if scope == 2 {
      self.filteredFavoritedUSDAItems = self.favoritedUSDAItems.filter({ (item:USDAItem) -> Bool in
        var stringMatch = item.name.rangeOfString(searchText)
        return stringMatch != nil
      })
    }
    
  }
  
  func makeRequest(searchString:String){
    
    // Get Request
    //    let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
    //
    //    let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
    //      var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
    //      println(stringData)
    //      println(response)
    //    })
    //    task.resume()
    
    // Post Request
    var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search")!)
    
    let session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    
    var params = [
      "appId" : kAppId,
      "appKey" : kAppKey,
      "query" : searchString,
      "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
      "limit" : "50",
      "filters" : ["exists" : ["usda_fields" : true ]]]
    
    var error:NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("applciation/json", forHTTPHeaderField: "Accept")
    
    var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
//            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(stringData)
      
      var conversionError : NSError?
      var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
      //println(jsonDictionary)
      
      if conversionError != nil {
        println(conversionError!.localizedDescription)
        let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("Error in Parsing \(errorString)")
      }
      else {
        if jsonDictionary != nil {
          self.jsonResponse = jsonDictionary!
          self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
          })        }
        else {
          println("Error could not parse JSON")
        }
      }
    })
    task.resume()
  }
  
  
  // mark - Setup CoreData
  
  func requestFavoritedUSDAItems () {
    let fetchRequest = NSFetchRequest(entityName: "USDAItem")
    let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
    let manangedObjectContext = appDelegate.managedObjectContext
    self.favoritedUSDAItems = manangedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as [USDAItem]
  }
  
  // Mark - NSNotificationCenter
  
  func usdaItemDidComplete(notification: NSNotification) {
    
    println("usdaItemDidComplete in ViewController")
    
    requestFavoritedUSDAItems()
    let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
    if selectedScopeButtonIndex == 2 {
      self.tableView.reloadData()
    }
  }
}

