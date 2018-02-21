//
//  PlistParser.swift
//  PlistReport
//
//  Created by Mahmud Riad on 2/14/18.
//  Copyright © 2018 Mahmud Hasan Riad. All rights reserved.
//

import Foundation

class PlistParser{
    
    var myDict: NSDictionary?
    var array:NSArray?
    var dictArrays = [NSDictionary]()
    
    func getTestSummaryPlistData(helper:Helper) -> Void {
        
        var dictionary:NSDictionary!
        let data:NSData =  FileManager.default.contents(atPath: helper.projectDirPath!+"/"+Constant.FOLDER_OUTPUT+"/sample.plist")! as NSData
        
        do{
            dictionary = try PropertyListSerialization.propertyList(from: data as Data, options: PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil) as! NSDictionary
        }catch{
            print("Error occured while reading from the Test Summary plist file")
        }
        print(dictionary)
        helper.TestSummPlistDict = dictionary
        
    }
    
    //convertArrayToDictFromPlist
    func getDictionaryFromPlist(keyName:String, data:NSDictionary?) -> [NSDictionary] {
        
        var dictArray = [NSDictionary]()
        
        for (key, _) in data!{
            
            if((key as! String).isEqual(keyName)){
                array = data![keyName] as? NSArray
                for i in 0..<array!.count{
                    myDict = array![i] as! NSDictionary as NSDictionary!
                    dictArray.append(myDict!)
                }
                
                break
            }
        }
        return dictArray
    }
    
    //convertArrayToDictFromPlist
    func getDictionaryFromPlistSubtests(keyName:String, data:NSDictionary?) -> [NSDictionary] {
        
        //var dictArray = [NSDictionary]()
        
        for (key, _) in data!{
            
            if((key as! String).isEqual(keyName)){
                array = data![keyName] as? NSArray
                for i in 0..<array!.count{
                    myDict = array![i] as! NSDictionary as NSDictionary!
                    dictArrays.append(myDict!)
                }
                
                break
            }
        }
        return dictArrays
    }
    
    
    func parseData(testSummary:[NSDictionary]) -> Array<AnyObject> {
        
        var testInfoDict = Dictionary<String,String>()
        var strArr1 = Array<AnyObject>()
        
        var catInfoDict = Dictionary<String,AnyObject>()
        var strArr2 = Array<AnyObject>()
        
        var tmpStr:String = ""
        var str1:String = ""
        var str2:String = ""
        var str3:String = ""
        let errorMsgLenth:Int = 220
        var tmpArr = [String]()
        
        for i in 0..<testSummary.count{
            
            tmpStr = (testSummary[i]["TestName"] as! String).description
            
            var subTests = self.getDictionaryFromPlist(keyName: Constant.PLIST_KEY_SUB_TESTS, data: testSummary[i])
            
            var failTCID:String = ""
            var k = 0
            var pass = 0
            var fail = 0
            var skip = 0
            for j in 0..<subTests.count{
                str1 = (subTests[j]["TestName"] as! String).description
                
                str1 = self.purgeString(str: str1, of: "()", with: "")
                
                str2 = (subTests[j]["TestStatus"] as! String).description
                
                if(subTests[j]["FailureSummaries"] != nil){
                    var tt = (subTests[j]["FailureSummaries"] as! Array<NSDictionary>)
                    
                    str3 = (tt[0]["Message"] as! String).description
                    
                    let strCount = str3.characters.count
                    if(strCount > errorMsgLenth){
                        let index = str3.index(str3.startIndex, offsetBy: errorMsgLenth)
                        str3 = str3.substring(to: index)
                    }
                    
                } else {
                    str3 = "TestCase Passed"
                }
                if((str3).isEqual("TestCase Passed")){
                    tmpArr = str1.components(separatedBy: "_")
                    if(tmpArr.count > 1){
                        for p in 1..<tmpArr.count{
                            testInfoDict = ["TestName" : tmpArr[0]+"-"+tmpArr[p] as String, "Status" : str2 as String, "Message" : str3 as String]
                            strArr1.insert(testInfoDict as AnyObject, at: k)
                            if(p < tmpArr.count-1){
                                k += 1
                            }
                            pass += 1
                        }
                    }else{
                        testInfoDict = ["TestName" : tmpArr[0] as String, "Status" : str2 as String, "Message" : str3 as String]
                        strArr1.insert(testInfoDict as AnyObject, at: k)
                        pass += 1
                    }
                } else {
                    tmpArr = str1.components(separatedBy: "_")
                    var tmpStatus:String = "Skip"
                    var hasMatch:Bool = false
                    var otherError:Bool = false
                    
                    var tmpMsgArr = str3.components(separatedBy: ".-")
                    str3 = tmpMsgArr[0]
                    if(tmpMsgArr.count > 1){
                        failTCID = tmpMsgArr[1]
                    }else{
                        otherError = true
                    }
                    if(tmpArr.count > 1){
                        for p in 1..<tmpArr.count{
                            var msg:String = ""
                            if(tmpArr[p].contains(failTCID)){
                                hasMatch = true
                                tmpStatus = str2
                                msg = str3
                                fail += 1
                            } else if(hasMatch){
                                tmpStatus = "Skip"
                                msg = "TestCase Skiped"
                                skip += 1
                            } else if(otherError){
                                tmpStatus = str2
                                msg = str3
                                fail += 1
                            } else {
                                tmpStatus = "Success"
                                msg = "TestCase Passed"
                                pass += 1
                            }
                            
                            testInfoDict = ["TestName" : tmpArr[0]+"-"+tmpArr[p] as String, "Status" : tmpStatus as String, "Message" : msg as String]
                            strArr1.insert(testInfoDict as AnyObject, at: k)
                            if(p < tmpArr.count-1){
                                k += 1
                            }
                            
                        }
                    }else{
                        testInfoDict = ["TestName" : tmpArr[0] as String, "Status" : str2 as String, "Message" : str3 as String]
                        strArr1.insert(testInfoDict as AnyObject, at: k)
                        fail += 1
                    }
                }
                k += 1
            }
            catInfoDict = ["CategoryName" : tmpStr as AnyObject, "TC" : strArr1 as AnyObject, "PassedTC" : pass.description as AnyObject, "FailedTC" : fail.description as AnyObject, "SkipedTC" : skip.description as AnyObject]
            strArr1.removeAll()
            strArr2.insert(catInfoDict as AnyObject, at: i)
        }
        
        return strArr2
    }
    
    func purgeString(str:String, of:String, with:String) ->  String{
        var tmp = str
        if(str.contains(of)){
            tmp = str.replacingOccurrences(of: of, with: with)
        }
        return tmp
    }
    
    func getFileContent(helper:Helper) -> String {
        
        var strContent:String = ""
        let path = helper.projectDirPath!+"/"+Constant.FOLDER_ASSETS
        let plistPath = helper.searchFolder(folderPath: path, keyWord: Constant.HTML_REPORT_FORMAT_FILE)
        do{
            strContent = try String(contentsOfFile: path+"/"+plistPath)
        }catch{
            print("HTML file or file content error")
        }
        
        return strContent
    }

}
