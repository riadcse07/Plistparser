//
//  helper.swift
//  PlistReport
//
//  Created by Mahmud Riad on 2/14/18.
//  Copyright © 2018 Mahmud Hasan Riad. All rights reserved.
//

import Foundation
class Helper{

    var propertyDict: NSDictionary?
    
    var TestSummPlistDict: NSDictionary?
    var plistDict: NSDictionary?
    var projectDirPath : String?
    var derivedDataPath : String?
    var TestSummPlistFileName : String?
    var parseData = Array<AnyObject>()
    var Duration:Int = 0
    
    var timeStamp:String = ""
    
    func setInfoPlist() -> Void {
        
        //print("Hello, World! i am from helper")
        
        let fileManager = FileManager.default
        var pathStr:String = fileManager.currentDirectoryPath
        
        pathStr = pathStr.components(separatedBy: "/Build")[0]
        plistDict = NSDictionary(contentsOfFile: pathStr+"/"+Constant.PROJECT_INFO_PLIST_FILE)
        projectDirPath = plistDict?["WorkspacePath"] as? String
        
        pathStr = pathStr.components(separatedBy: "DerivedData")[0]
        
        derivedDataPath = pathStr+"DerivedData"
        
        var tmpString:String = ""
        var strArr = projectDirPath?.components(separatedBy: "/")
        
        for i in 2..<(strArr?.count)! {
            tmpString += "/"+(strArr?[i-1])!
        }
        
        projectDirPath = tmpString
        self.createFolder(name: Constant.FOLDER_OUTPUT)
        self.setCurrentTimeStamp()
        
    }
    
    func createFolder(name:String) -> Void {
        let directory: String = projectDirPath!
        let dataPath = directory.appending("/"+name)
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    func setCurrentTimeStamp() -> Void{
        
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        //formatter.timeZone = NSTimeZone(forSecondsFromGMT: 6)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        
        self.timeStamp = formatter.string(from: date as Date)
        
    }
    
    func setDuration(duration: NSNumber) -> Void {
        let du = Float((duration).description)!
        
        self.Duration = Int(du)
        //print((helper.Duration).description+" ===== ")
    }
    
    func writeToFile(text:String,whichFile:String)  {
        var tmpFilePath:String = ""
        if(whichFile.isEqual(Constant.HTML)){
            tmpFilePath = projectDirPath!+"/"+Constant.FOLDER_OUTPUT+"/"+Constant.REPORT_HTML_FILE
        } else if(whichFile.isEqual("MailBody")){
            tmpFilePath = projectDirPath!+"/"+Constant.FOLDER_OUTPUT+"/mailBody.txt"
        }else{
            tmpFilePath = projectDirPath!+"/"+Constant.FOLDER_OUTPUT+"/"+Constant.REPORT_DATA_TXT_FILE
        }
        
        self.deleteFile(filePath: tmpFilePath)
        self.createFile(filePath: tmpFilePath)
        if let fileHandle = FileHandle(forWritingAtPath: tmpFilePath) {
            //Append to file
            fileHandle.seekToEndOfFile()
            fileHandle.write(text.data(using: String.Encoding.utf8)!)
        }
        
    }
    
    //create file if not exist
    func createFile(filePath:String) {
        
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: filePath) { //Check if file exists
            do{
                _ = try? fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
            }catch{
                /* error handling here */
            }
        }
    }
    
    //delete file
    func deleteFile(filePath:String)  {
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: in file deleting \(error)")
            }
        }
    }
    
    //search folder
    func searchFolder(folderPath:String, keyWord:String) ->String{
        
        var element:String = "default"
        let fileManager = FileManager.default
        let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: folderPath)!
        
        while let searchElement = enumerator.nextObject() as? String {
            if searchElement.hasPrefix(keyWord) {
                element = searchElement
                break
            }
            if searchElement.hasSuffix(keyWord) {
                element = searchElement
                break
            }
        }
        
        return element
        
    }//func ends here
    
    func populateMailBody() {
        var parseData = self.parseData
        
        var body:String = ""
        
        var tmpStr:String = ""
        
        var categoryName:String = ""
        var passedTC:String = ""
        var failedTC:String = ""
        var skipedTC:String = ""
        
        var totalPassed:Int = 0
        var totalFailed:Int = 0
        var totalSkiped:Int = 0
        
        for i in 0..<parseData.count{
            categoryName = (parseData[i]["CategoryName"] as! String).description
            
            passedTC = (parseData[i]["PassedTC"] as! String).description
            failedTC = (parseData[i]["FailedTC"] as! String).description
            skipedTC = (parseData[i]["SkipedTC"] as! String).description
            
            tmpStr += "\(categoryName) : Passed-\(passedTC), Failed-\(failedTC), Skiped-\(skipedTC)\r"
            totalPassed += Int(passedTC)!
            totalFailed += Int(failedTC)!
            totalSkiped += Int(skipedTC)!
            
        }
        body = "System generated mail\r\rTotal Pass - \(totalPassed)\rTotal Fail - \(totalFailed)\rTotal Skip - \(totalSkiped)\r\(tmpStr)"
        
        let mailBodyFilePath:String = self.projectDirPath!+"/"+Constant.FOLDER_OUTPUT+"/mailBody.txt"
        
        self.cleanUp(filePath: mailBodyFilePath)
        self.writeToFile(text: body, whichFile: "MailBody")
        
    }
    
    //read from projectInfo.plist file [for mail]
    func setPropertyInfoFile() -> Void {
        
        var dictionary:NSDictionary!
        
        let data:NSData =  FileManager.default.contents(atPath: helper.projectDirPath!+"/"+Constant.FOLDER_ASSETS+"/"+Constant.PROPERTIES_INFO_PLIST_FILE)! as NSData
        
        do{
            dictionary = try PropertyListSerialization.propertyList(from: data as Data, options: PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil) as! NSDictionary
        }catch{
            print("Error occured while reading from property info plist file")
        }
        
        self.propertyDict = dictionary
        
    }//func ends here
    
    func getValueFromDictionary(dictionary:NSDictionary,keyWord:String) -> String {
        var keyValue:String = ""
        
        for (key, value) in dictionary{
            
            if((key as AnyObject).isEqual(keyWord)){
                
                keyValue = value as! String
                break
            }
        }
        
        return keyValue
    }
    
    func cleanUp(filePath:String) -> Void {
        self.deleteFile(filePath: filePath)
        self.createFile(filePath: filePath)
    }
    
}

