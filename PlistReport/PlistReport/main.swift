//
//  main.swift
//  PlistReport
//
//  Created by Mahmud Riad on 2/14/18.
//  Copyright © 2018 Mahmud Hasan Riad. All rights reserved.
//

import Foundation

print("Execution Start")

let helper = Helper()
helper.setInfoPlist()

let parsePlist = PlistParser()
let htmlReport = Report()
var subSetAllBundle = [NSDictionary]()

parsePlist.getTestSummaryPlistData(helper: helper)

var testSummaries = parsePlist.getDictionaryFromPlist(keyName: Constant.PLIST_KEY_TABLE_SUMMARIES, data: helper.TestSummPlistDict!)
var parseData = Array<AnyObject>()

for i in 0..<testSummaries.count{
    
    var items = parsePlist.getDictionaryFromPlist(keyName: Constant.PLIST_KEY_TESTS, data: testSummaries[i])
    
    var tests = parsePlist.getDictionaryFromPlist(keyName: Constant.PLIST_KEY_SUB_TESTS, data: items[0])
    let subSetAllBundle = parsePlist.getDictionaryFromPlistSubtests(keyName: Constant.PLIST_KEY_SUB_TESTS, data: tests[0])
}

parseData = parsePlist.parseData(testSummary: parsePlist.dictArrays)
helper.parseData = parseData
helper.writeToFile(text: parseData.description, whichFile: Constant.TXT)


let htmlStr = htmlReport.getReportAsHTML(arrData : parseData)
var strContent:String = parsePlist.getFileContent(helper:helper)
let fullNameArr = strContent.components(separatedBy: Constant.SPLITTER)
let htmlReportStr = fullNameArr[0]+htmlStr+fullNameArr[1]


helper.writeToFile(text: htmlReportStr, whichFile: Constant.HTML)
helper.populateMailBody()

print("Report is genereted on output directory")
