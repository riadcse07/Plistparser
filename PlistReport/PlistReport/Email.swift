//
//  Emailer.swift
//  PlistReport
//
//  Created by Mahmud Riad on 2/14/18.
//  Copyright © 2018 Mahmud Hasan Riad. All rights reserved.
//

import Foundation

class Email{
    
    func email(helper:Helper){
        helper.setPropertyInfoFile()
        let emailReceiver = helper.getValueFromDictionary(dictionary: helper.propertyDict!, keyWord: "email")
        print(emailReceiver+"=======")
        let mailBodyFilePath:String = helper.projectDirPath!+"/"+Constant.FOLDER_OUTPUT+"/mailBody.txt"
        //var timeStamp = helper.timeStamp
        let reportHTML = helper.projectDirPath!+"/"+Constant.FOLDER_OUTPUT+"/"+Constant.REPORT_HTML_FILE
        
        //var mailBodyStr = self.prepareMailBody(helper: helper)
        
        //helper.cleanUp(filePath: mailBodyFilePath)
        //helper.writeToFile(text: mailBodyStr, whichFile: "MailBody")
        
        
        self.runTerminalCommand(helper: helper, launchPath: "/bin/bash", args: "sendEmail.sh","\(mailBodyFilePath)","\(reportHTML)","\(emailReceiver)")
    }
    
    func prepareMailBody(helper:Helper) -> String{
        var parseData = helper.parseData
        
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
        
        return body
    }
    
    //helper.runTerminalCommand("/bin/bash", args: "sendEmail.sh","\(mailBody)","\(timeStamp)","\(emailReceiver)")
    //run terminal command
    func runTerminalCommand(helper:Helper, launchPath:String, args: String...) -> Int32 {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = args
        task.currentDirectoryPath = helper.projectDirPath!
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
}
}
