//
//  ChatViewController.swift
//  HelloFirebase
//
//  Created by Duncan on 2016/4/2.
//  Copyright © 2016年 Duncan. All rights reserved.
//

import UIKit
import CoreBluetooth

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate {
    
    var messageList = NSMutableDictionary()
    var childAddedHanhler = FirebaseHandle()
    var arrayOfKey:Array<String> = []
    
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var messageTable: UITableView!
    @IBOutlet weak var messageTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBAction func sendAction(sender: UIButton) {
        
        if messageText.text != ""{
            let date = NSDate().timeIntervalSince1970
            let dateInt = Int(date)
            let dateS = NSDate()
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            let timeString = formatter.stringFromDate(dateS)
            
            let messageArray = ["time": timeString, "message": messageText.text!, "sender": nickName]
            fbase.childByAppendingPath("\(dateInt)").setValue(messageArray)
            messageText.text = ""
        }
        messageText.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification){
        var info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(0.1) { 
            self.messageTextConstraint.constant = keyboardFrame.size.height + 2
            self.sendButtonConstraint.constant = keyboardFrame.size.height + 2
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        _ = notification.userInfo!
        UIView.animateWithDuration(0.1) {
            self.messageTextConstraint.constant = 5
            self.sendButtonConstraint.constant = 5
            //self.tableConstraint.constant = 44
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.myActivityIndicator.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        childAddedHanhler = fbase.observeEventType(.Value) { (snapshot:FDataSnapshot!) -> Void in
            self.myActivityIndicator.startAnimating()
            self.firebaseUpdate(snapshot)
        }
        childAddedHanhler = fbase.observeEventType(.ChildChanged) { (snapshot:FDataSnapshot!) -> Void in
            self.myActivityIndicator.startAnimating()
            self.firebaseUpdate(snapshot)
        }
        
        //藍芽通訊
        peripheralArray[0].discoverServices([CBUUID(string: serviceUUIDString)])
        
    }
    func firebaseUpdate(snapshot:FDataSnapshot){
        if let messages = snapshot.value as? NSDictionary{
            for message in messages{
                let key = message.key as! String
                let isMessageExist = (self.messageList[key] != nil)
                if !isMessageExist{
                    self.messageList.setValue(message.value, forKey: key)
                    arrayOfKey = messageList.allKeys as! Array<String>
                    arrayOfKey = arrayOfKey.sort(<)
                    //print(arrayOfKey)
                }
            }
        }
        dispatch_async(dispatch_get_main_queue()){[unowned self] in
            self.messageTable.reloadData()
            if self.messageTable.contentSize.height > self.messageTable.frame.size.height{
                let bottomOffset = CGPointMake(0, self.messageTable.contentSize.height - self.messageTable.bounds.size.height)
                self.messageTable.setContentOffset(bottomOffset, animated: true)
            }
            self.myActivityIndicator.stopAnimating()
        }
    }
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messageList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let messageLabel = cell.contentView.subviews[0] as! UILabel
        let timeLabel = cell.contentView.subviews[1] as! UILabel
        
        let key = arrayOfKey[indexPath.row]
        let value = messageList[key] as! NSDictionary
        
        let sender = value["sender"] as! String
        let message = value["message"] as! String
        
        messageLabel.text = sender + "：" + message
        timeLabel.text = value["time"] as? String

        return cell
    }
    
    //以下藍芽傳輸
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Found Service \(peripheral.services!)")
        for service in peripheral.services!{
            peripheral.discoverCharacteristics([CBUUID(string: characteristicUUIDString)], forService: service as CBService)
            //print("Found Characteristics + \(characteristicUUIDString)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("Found Characteristic of \(service)")
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
