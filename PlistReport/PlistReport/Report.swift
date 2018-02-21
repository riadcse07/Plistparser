//
//  HtmlReport.swift
//  PlistReport
//
//  Created by Mahmud Riad on 2/14/18.
//  Copyright © 2018 Mahmud Hasan Riad. All rights reserved.
//

import Foundation

class Report{
    
    func getReportAsHTML(arrData:Array<AnyObject>) -> String {
        
        var html:String = ""
        
        let leftColumHeader:String = "<div class='col-sm-4 col-md-4 sidebar'>"
        var leftColumTotalRow:String = "<ul class='nav'>"
        var leftColum:String = "<ul class='nav nav-sidebar'>"
        var rightColum:String = "<div class='col-sm-8 col-md-8 main'>"
        
        var tmpStr:String = ""
        var str1:String = ""
        var str2:String = ""
        var str3:String = ""
        
        var passedTC:String = ""
        var failedTC:String = ""
        var skipedTC:String = ""
        
        var totalPassed:Int = 0
        var totalFailed:Int = 0
        var totalSkiped:Int = 0
        
        var status:String = "success"
        
        var strArr1 = Array<AnyObject>()
        
        for i in 0..<arrData.count{
            tmpStr = (arrData[i]["CategoryName"] as! String).description
            
            passedTC = (arrData[i]["PassedTC"] as! String).description
            failedTC = (arrData[i]["FailedTC"] as! String).description
            skipedTC = (arrData[i]["SkipedTC"] as! String).description
            
            totalPassed += Int(passedTC)!
            totalFailed += Int(failedTC)!
            totalSkiped += Int(skipedTC)!
            
            leftColum += "<li><a href='#\(tmpStr)'><span class='tclabel'>\(tmpStr)</span><span class='btn btn-warning btn-xs'>\(skipedTC) Skip</span><span class='btn btn-success btn-xs'>\(passedTC) Pass</span><span class='btn btn-danger btn-xs'>\(failedTC) Fail</span></a></li>"
            
            rightColum += "<div class='container_data' id='\(tmpStr)'><h1 class='page-header'>\(tmpStr)</h1><div class='table-responsive' id='\(tmpStr)'><table class='table table-striped'><thead><tr><th class='col-md-4'>Test Case</th><th class='passfailth'>Status</th><th>Message</th></tr></thead><tbody>"
            
            strArr1 = (arrData[i]["TC"] as AnyObject) as! Array<AnyObject>
            for j in 0..<strArr1.count{
                str1 = (strArr1[j]["TestName"] as! String).description
                str2 = (strArr1[j]["Status"] as! String).description
                str3 = (strArr1[j]["Message"] as! String).description
                
                status = (str2 == "Success" ? "success" : (str2 == "Skip" ? "warning" : "danger"))
                rightColum += "<tr><td>\(str1)</td><td><span class='btn btn-\(status) btn-xs'>\(str2)</span> </td><td>\(str3)</td></tr>"
            }
            rightColum += "</tbody></table></div></div>"
        }
        
        leftColumTotalRow += "<li><span class='btn btn-success btn-xs'>Total Pass: \(totalPassed)</span><span class='btn btn-danger btn-xs'>Total Fail: \(totalFailed)</span><span class='btn btn-warning btn-xs'>Total Skip: \(totalSkiped)</span><span class='tclabel'></span></li></ul>"
        leftColum += "</ul></div>"
        rightColum += "</div>"
        html += leftColumHeader+leftColumTotalRow+leftColum+rightColum
        
        return html
    }
}
