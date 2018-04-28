//
//  Group.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation

class Group: NSObject, NSCoding {
    
    
    private static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    private static let ArchiveURL = DocumentsDirectory.appendingPathComponent("group")

    //MAKR: Properties
    var code: String;
    var name: String;
    
    struct PropertyKey {
        static let code = "code"
        static let name = "name"
    }

    
    init? (name: String, code: String){
        self.name = name;
        self.code = code;
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(code, forKey: PropertyKey.code);
        aCoder.encode(name, forKey: PropertyKey.name);
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let code = aDecoder.decodeObject(forKey: PropertyKey.code);
        let name = aDecoder.decodeObject(forKey: PropertyKey.name);
        if let code = code as? String, let name = name as? String {
            self.init(name: name, code: code);
        }
        else {
            return nil;
        }
        
    }
    
    
    //these methods return a single instance of Group that should be the users current group AT ALL TIMES
    public static func writeToDisk(group: Group)-> Bool {
        return NSKeyedArchiver.archiveRootObject(group, toFile: Group.ArchiveURL.path)
    }
    
    public static func getFromDisk()-> Group? {
        print(Group.ArchiveURL.path);
        return NSKeyedUnarchiver.unarchiveObject(withFile: Group.ArchiveURL.path) as? Group
    }
    
    public static func deleteData()->Bool {
        do {
            try FileManager.default.removeItem(atPath: Group.ArchiveURL.path)
            return true;
        } catch {
            return false;
        }
    }
    
}
