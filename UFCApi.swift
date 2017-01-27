//
//  UFCApi.swift
//  UFC Pocket Companion
//
//  Created by Michael Kane on 1/20/17.
//  Copyright © 2017 Mike Kane. All rights reserved.
//

import UIKit
import SwiftyJSON

struct APIStrings {
    
    static  let newsURL = "http://ufc-data-api.ufc.com/api/v3/iphone/news"
    static  let mediaURL = "http://ufc-data-api.ufc.com/api/v3/iphone/media"
    static  let eventsURL = "http://ufc-data-api.ufc.com/api/v3/iphone/events"
    static  let fightersURL = "http://ufc-data-api.ufc.com/api/v3/iphone/fighters"
    static  let octagonGirlsURL = "http://ufc-data-api.ufc.com/api/v3/iphone/octagon_girls"
    static  let titleHoldersURL = "http://ufc-data-api.ufc.com/api/v3/iphone/fighters/title_holders"
    
    //newsURL will produce an ID to be input for article
    static func newsArticleURL(nID id: String) -> String {
        return "http://ufc-data-api.ufc.com/api/v3/iphone/news/\(id)"
    }
    
    static func mediaItemURL(mID id: String) -> String {
        return "http://ufc-data-api.ufc.com/api/v3/iphone/media/\(id)"
    }
    
    //Basically Different way to filter the fighters
    //Born Country can have an empty string to bring back all countries.
    static  let statsFilterKeyValueURL = "http://ufc-data-api.ufc.com/api/v3/iphone/fighters/stats_filter_key_values"
    
    static func fighterStats(wClass weightClass: String, bCountry bornCountry: String?) -> String {
        return "http://ufc-data-api.ufc.com/api/v3/iphone/fighters/stats/weight_class/:\(weightClass)/born_country/:\(bornCountry ?? "")"
    }
    
    //Pass in a fighters name ex: conor-mcgregor. Must have dash. Must end in .json
    static func detailedFighterStats(name: String) -> String {
        return "http://nlds230.cdnak.neulion.com/fs/ufc/common/fighter/json/\(name).json"
    }
    
    //Pass in the fighter id returned from the fightersURL. Returns news and and media URLs in that order
    static func fighterNewsAndMediaURL(fID id: String) -> (String,String) {
        return ("http://ufc-data-api.ufc.com/api/v3/iphone/fighters/:\(id)/news","http://ufc-data-api.ufc.com/api/v3/iphone/fighters/:\(id)/media")
    }
    
    //Pass in the Octagon id returned from the octagonGirlsURL
    static func octagonGirlURL(gID id: String) -> String {
        return "http://ufc-data-api.ufc.com/api/v3/iphone/octagon_girls/\(id)"
    }
    
    //Pass in the events id returned from the eventsURL
    //Returns URLs for the single event, fights in the event, media(gallery), highlights & tickets. In that order
    static func eventURL(eID id: String) -> (String,String,String,String,String) {
        return ("http://ufc-data-api.ufc.com/api/v3/iphone/events/\(id)","http://ufc-data-api.ufc.com/api/v3/iphone/events/:\(id)/fights", "http://ufc-data-api.ufc.com/api/v3/iphone/events/\(id)/media","http://ufc-data-api.ufc.com/api/v3/iphone/events/\(id)/highlights","http://ufc-data-api.ufc.com/api/v3/iphone/events/\(id)/tickets")
    }
}

class UFCApi: NSObject {
    
    /* This will load the main table. When a user selects fighters it will display a large ist of fighters. I can parse them into sections if I wish with search etc. But lets get the data first. Once this finishes and saves, I will parse the .json file. I can then iterate over the names and pull the detailed stats.
     */
    //Once fighters load DO I pull the additional data right away or load that when a user clicks a fighter. Seems like the overhead up frint is massive.
    //Display all fighters. Perform a cool animaion - grab the fighters ID and grab the news and media.
    
    var jsonArray: Array<JSON>?
    
    func getJSOnObjects() {
        
        var jsonString = ""
        var json : JSON?
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            //Put on BG queue but make this an ultra high priority. This is quick.
            do {
                jsonString = try String(contentsOf:NSURL(string: APIStrings.fightersURL)! as URL, encoding: String.Encoding.utf8)
            } catch {
                print("Error with URL")
            }
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let path = dir.appendingPathComponent("fighters.json")
                
                do {
                    try jsonString.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                }
                catch {/* error handling here */}
                
                do {
                    json = try JSON(data: Data(contentsOf: path))
                    let fighter = Fighter.init(first: json?[0]["first_name"].string, last: json?[0]["last_name"].string, fighterId:44)
                    let url = NSURL(string:APIStrings.detailedFighterStats(name:fighter.name!))
                    jsonString = try String(contentsOf:url! as URL, encoding: String.Encoding.utf8)
                    
                    //Might have to handle the writing manually not using swiftyJSON. use SwiftyJSON just for reading everythign.
                    //Need to assign dictionary and then put it back
                    
                    //                json[0]["detailed_stats"] = "hi"
                    self.jsonArray = (json?.array!)!
                      print("\(self.jsonArray?.count ?? 0)")
                }
                catch {NSLog("This is not working")}
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadFinished"), object: nil)
                print("Download finished: \(json![0])")
            }
        }
    }
}
