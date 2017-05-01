//
//  PDFGenerator.swift
//  Print2PDF
//
//  Created by Meghan Judge on 4/30/17.
//  Copyright © 2017 Appcoda. All rights reserved.
//

import UIKit

class PDFGenerator: NSObject {
    
    let pathToSummaryTemplate = Bundle.main.path(forResource:"summary", ofType: "html")
    let pathToSummarySectionTemplate = Bundle.main.path(forResource:"summary_section", ofType: "html")
    
    var pdfFilename: String!
    
    let name = "Patient Name"
    let exportDate = "04/30/2017"
    
    override init() {
        super.init()
    }
    
    func exportHTMLContentToPDF(HTMLContent: String) {
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        pdfFilename = "\(AppDelegate.getDelegate().getDocDir())/LilySummary.pdf"
        pdfData?.write(toFile: pdfFilename, atomically: true)
        
        print(pdfFilename)
    }
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        
        
        
        for i in 0...printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }
    
    // pass in the five subsections array
    func renderExportableSummary(symptoms: [String], meds: [String], diet: [String],
                                 body: [String], mind:[String]) -> String {
        
        var subsections: [String] = []
        let HTMLContent = renderHeaderAndFooter()
        
        // create symptoms subsection + all symptoms sub-subsections
        if (symptoms.count > 0){
            subsections.append(renderSubsection(name: "Symptoms", icon: "symptoms.png", subsectionArr: symptoms))
        }
        
        // create meds subsection + all meds sub-subsections
        if (meds.count > 0) {
            subsections.append(renderSubsection(name: "Medications", icon: "medications.png", subsectionArr: meds))
        }
        
        // create diet subsection + all diet sub-subsections
        if (diet.count > 0) {
            subsections.append(renderSubsection(name: "Diet", icon: "diet.png", subsectionArr: diet))
        }
        
        // create body subsection + all body sub-subsections
        if (body.count > 0) {
            subsections.append(renderSubsection(name: "Body", icon: "body.png", subsectionArr: body))
        }
        
        // create mind subsection + all mind sub-subsections
        if (mind.count > 0) {
            subsections.append(renderSubsection(name: "Mind", icon: "mind.png", subsectionArr: mind))
        }
        
        return concatenateSubsections(HTMLContent: HTMLContent, subsections: subsections, id: "#SUMMARY_SECTIONS#")
    }
    
    // renders the header and returns the summary template w/ the header filled in
    func renderHeaderAndFooter() -> String {
        do {
            var HTMLContent = try String(contentsOfFile: pathToSummaryTemplate!)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#REPORT_DATE#", with: "05/02/2017")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PATIENT_NAME#", with: "Tom Reinhart")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PATIENT_DOB#", with: "07/02/1994")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#REPORT_RANGE#", with: "04/20/2017-05/02/2017")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LILY_LOGO#", with: "lily.png")
            
            return HTMLContent
        } catch {
            print("Unable to open and use HTML files. Quit at header")
        }
        
        return ""
    }
    
    func renderSubsection(name: String, icon: String, subsectionArr: [String]) -> String {
        let html = renderSubsectionHTML(icon: icon, name: name)
        
        var subsToConcat : [String] = []
        if (html != "") {
            for subsection in subsectionArr {
                let pathToTemplate = Bundle.main.path(forResource: subsection, ofType: "html")
                
                switch subsection {
                case "personal_medications":
                    subsToConcat.append(renderPersonalMedications(pathToTemplate: pathToTemplate!))
                case "vitamins":
                    subsToConcat.append(renderVitamins(pathToTemplate: pathToTemplate!))
                case "vomiting":
                    subsToConcat.append(renderVomiting(pathToTemplate: pathToTemplate!))
                case "cramping":
                    subsToConcat.append(renderCramping(pathToTemplate: pathToTemplate!))
                case "swelling":
                    subsToConcat.append(renderSwelling(pathToTemplate: pathToTemplate!))
                case "head_pain":
                    subsToConcat.append(renderHeadPain(pathToTemplate: pathToTemplate!))
                case "vaginal_and_urinary":
                    subsToConcat.append(renderVaginalAndUrinary(pathToTemplate: pathToTemplate!))
                case "diet_composition":
                    subsToConcat.append(renderDietComposition(pathToTemplate: pathToTemplate!))
                case "water":
                    subsToConcat.append(renderWater(pathToTemplate: pathToTemplate!))
                case "heart_rate":
                    subsToConcat.append(renderHeartRate(pathToTemplate: pathToTemplate!))
                case "physical_activity":
                    subsToConcat.append(renderPhysicalActivity(pathToTemplate: pathToTemplate!))
                case "sleep":
                    subsToConcat.append(renderSleep(pathToTemplate: pathToTemplate!))
                case "mind_summary":
                    subsToConcat.append(renderMindSummary(pathToTemplate: pathToTemplate!))
                case "edinburgh_postpartum_depression":
                    subsToConcat.append(renderPostpartumDepressionSurvey(pathToTemplate: pathToTemplate!))
                default:
                    continue
                }
            }
        }
        
        return concatenateSubsections(HTMLContent: html, subsections: subsToConcat, id: "#SUB_SECTIONS#")
    }
    
    // functionality not available to support
    func renderPersonalMedications(pathToTemplate: String) -> String {
        return ""
    }
    
    // functionality not available to support
    func renderVitamins(pathToTemplate: String) -> String {
        return ""
    }
    
    // functionality not available to support
    func renderVomiting(pathToTemplate: String) -> String {
        return ""
    }
    
    // functionality not available to support
    func renderCramping(pathToTemplate: String) -> String {
        return ""
    }
    
    // functionality not available to support
    func renderSwelling(pathToTemplate: String) -> String {
        return ""
    }
    
    // functionality not available to support
    func renderHeadPain(pathToTemplate: String) -> String {
        return ""
    }
    
    // functionality not available to support
    func renderVaginalAndUrinary(pathToTemplate: String) -> String {
        return ""
    }
    
    // functionality not available to support
    func renderDietComposition(pathToTemplate: String) -> String {
        return ""
    }
    
    func renderWater(pathToTemplate: String) -> String {
        do {
            var html = try String(contentsOfFile: pathToTemplate)
            
            let avgWater = "6" // pull data from fitbit
            let avgCaffeine = "3" // calculate using information logged via voice.
            
            html = html.replacingOccurrences(of: "#AVG_WATER_PER_DAY#", with: avgWater)
            html = html.replacingOccurrences(of: "#AVG_CAFFEINE_PER_DAY#", with: avgCaffeine)
            
            return html
            
        } catch {
            print("Unable to open and use HTML files. Quit at water sub-subsection")
        }
        return ""
    }
    
    func renderPhysicalActivity(pathToTemplate: String) -> String {
        do {
            var html = try String(contentsOfFile: pathToTemplate)
            
            let avgTimeSedentary = "6:01:00" // calc w/ fitbit
            let avgTimeLightlyActive = "2:40:00" //calc w/ fitbit
            let avgTimeFairlyActive = "1:00:00" //calc w/ fitbit
            let avgTimeVeryActive = "0:30:00" // calc w/ fitbit
            
            html = html.replacingOccurrences(of: "#SEDENTARY#", with: avgTimeSedentary)
            html = html.replacingOccurrences(of: "#LIGHTLY_ACTIVE#", with: avgTimeLightlyActive)
            html = html.replacingOccurrences(of: "#FAIRLY_ACTIVE#", with: avgTimeFairlyActive)
            html = html.replacingOccurrences(of: "#VERY_ACTIVE#", with: avgTimeVeryActive)
            
            return html
            
        } catch {
            print("Unable to open and use HTML files. Quit at physical activity sub-subsection")
        }
        return ""
    }
    
    func renderSleep(pathToTemplate: String) -> String {
        do {
            var html = try String(contentsOfFile: pathToTemplate)
            
            let avgSleep = "6:40:00" //calc w/ fitbit
            let avgRestless = "2:04:00" //calc w/ fitbit
            let avgEfficiency = "80%" // calc w/ fitbit
            
            html = html.replacingOccurrences(of: "#AVG_SLEEP#", with: avgSleep)
            html = html.replacingOccurrences(of: "#AVG_RESTLESS#", with: avgRestless)
            html = html.replacingOccurrences(of: "#AVG_EFFICIENCY#", with: avgEfficiency)
            
            return html
            
        } catch {
            print("Unable to open and use HTML files. Quit at sleep sub-subsection")
        }
        return ""
    }
    
    func renderHeartRate(pathToTemplate: String) -> String {
        do {
            var html = try String(contentsOfFile: pathToTemplate)
            
            let avgResting = "6:40:00" //calc w/ fitbit
            let bpmThreshold = "2:04:00" // pull from goals
            let numAbove = "25:00:00" // calc w/ fitbit
            
            html = html.replacingOccurrences(of: "#AVG_RESTING_HEART_RATE#", with: avgResting)
            html = html.replacingOccurrences(of: "#BPM_THRESHOLD#", with: bpmThreshold)
            html = html.replacingOccurrences(of: "#TOTAL_ABOVE_HEART_THRESH#", with: numAbove)
            
            return html
            
        } catch {
            print("Unable to open and use HTML files. Quit at water sub-subsection")
        }
        return ""
    }
    
    func renderMindSummary(pathToTemplate: String) -> String {
        do {
            var html = try String(contentsOfFile: pathToTemplate)
            let numLogged = "12" // calc w/ logging
            let pctAnger = "25%" // calc w/ logging
            let pctSadness = "40%" // calc w/ logging
            let pctHappiness = "20%" // calc w/ logging
            let pctAnxiety = "15%" // calc w/ logging
            
            html = html.replacingOccurrences(of: "#NUM_LOGGED#", with: numLogged)
            html = html.replacingOccurrences(of: "#PCT_ANGER#", with: pctAnger)
            html = html.replacingOccurrences(of: "#PCT_SADNESS#", with: pctSadness)
            html = html.replacingOccurrences(of: "#PCT_HAPPINESS#", with: pctHappiness)
            html = html.replacingOccurrences(of: "#PCT_ANXIETY#", with: pctAnxiety)
            
            return html
            
        } catch {
            print("Unable to open and use HTML files. Quit at water sub-subsection")
        }
        return ""
    }
    
    func renderPostpartumDepressionSurvey(pathToTemplate: String) -> String {
        do {
            var html = try String(contentsOfFile: pathToTemplate)
            let hasLaughed = "Yes" // calc w/ logging
            let hasBeenExcited = "Yes" // calc w/ logging
            let hasBeenAnxious = "Yes" // calc w/ logging
            let hasBeenScared = "No" // calc w/ logging
            let hasFeltOverwhelmed = "Yes" // calc w/ logging
            let hasProblemsSleeping = "Yes" // calc w/ logging
            let hasFeltMiserable = "No" // calc w/ logging
            let hasReportedCrying = "Yes" //calc w/ logging
            
            html = html.replacingOccurrences(of: "#EDIN_1#", with: hasLaughed)
            html = html.replacingOccurrences(of: "#EDIN_2#", with: hasBeenExcited)
            html = html.replacingOccurrences(of: "#EDIN_3#", with: hasBeenAnxious)
            html = html.replacingOccurrences(of: "#EDIN_4#", with: hasBeenScared)
            html = html.replacingOccurrences(of: "#EDIN_5#", with: hasFeltOverwhelmed)
            html = html.replacingOccurrences(of: "#EDIN_6#", with: hasProblemsSleeping)
            html = html.replacingOccurrences(of: "#EDIN_7#", with: hasFeltMiserable)
            html = html.replacingOccurrences(of: "#EDIN_8#", with: hasReportedCrying)
            
            return html
            
        } catch {
            print("Unable to open and use HTML files. Quit at water sub-subsection")
        }
        return ""
    }
    
    func renderSubsectionHTML(icon: String, name: String) -> String {
        do {
            var subsectionHTML = try String(contentsOfFile: pathToSummarySectionTemplate!)
            subsectionHTML = subsectionHTML.replacingOccurrences(of: "#SECTION_NAME#", with: name)
            subsectionHTML = subsectionHTML.replacingOccurrences(of: "#SECTION_ICON#", with: icon)
            
            return subsectionHTML
            
        } catch {
            print("Unable to open and use HTML files. Quit at symptoms subsection")
        }
        
        return ""
    }
    
    func concatenateSubsections(HTMLContent: String, subsections : [String], id: String) -> String{
        
        let mutableHTML = HTMLContent
        
        // 1. concatenate them all together
        var summarySubsections = ""
        for subsection in subsections {
            summarySubsections += " " + subsection
        }
        // 2. replace occurrence
        return mutableHTML.replacingOccurrences(of: id, with: summarySubsections)
        
    }
    
}
