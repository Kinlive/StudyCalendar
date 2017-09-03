//
//  CloudDataManager.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/8/24.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class CloudDataManager: NSObject {
static let sharedInstance = CloudDataManager()
    
    //MARK: -Check icloud exist
    func isICloudExist() -> Bool {
        let identityToken = FileManager.default.ubiquityIdentityToken
        if let identityToken = identityToken {
            print("iCloud access Exist , identityToken : \(identityToken.description)")
            return true
        }else{
            print("No iCloud access")
            return false
        }
    }
    
    func getCloudURL() -> URL?{//Never use
        
        let cloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        if let cloudURL = cloudURL{
            
            print("iCloud access at \(cloudURL.appendingPathComponent("Documents"))")
            return cloudURL.appendingPathComponent("Documents")
        }else {
            print("No iCloud access")
            return nil
        }
    }
    
    
    func deleteFilesInDirectory(url: URL?) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url!.path)
        while let file = enumerator?.nextObject() as? String {
            do {
                try fileManager.removeItem(at: url!.appendingPathComponent(file))
                print("Files deleted::\(file)")
            } catch let error as NSError {
                print("Failed deleting files : \(error)")
            }
        }
    }
    typealias  DownloadCompletion = (_ success: Bool) -> ()
    func copyFileToLocal(completion : DownloadCompletion) {
        guard let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else{return }
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {return }
        print("\(iCloudDocumentsURL)")
        deleteFilesInDirectory(url: localDocumentsURL)
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: iCloudDocumentsURL.path)
        
        while let file = enumerator?.nextObject() as? String {
            
            do {
                try fileManager.copyItem(at: iCloudDocumentsURL.appendingPathComponent(file),
                                                           to: localDocumentsURL.appendingPathComponent(file))
                
                print("Moved to local dir")
            } catch let error as NSError {
                print("Failed to move file to local dir : \(error)")
                completion(false)
            }
        }
        completion(true)
        
    }
    
    func moveFileToCloud() {
        guard let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else{return }
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {return }
        deleteFilesInDirectory(url: iCloudDocumentsURL)
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: localDocumentsURL.path)
        while let file = enumerator?.nextObject() as? String {
            do {
                try fileManager.copyItem(at: localDocumentsURL.appendingPathComponent(file),
                                         to: iCloudDocumentsURL.appendingPathComponent(file))
                print("Moved to iCloud")
                print("and url is :::::: \(file)")
            } catch let error as NSError {
                print("Failed to move file to Cloud : \(error)")
            }
        }
        
    }
    
    //MARK: - GetDocumentContent
    func checkLocalDocumentContentIsEmpty() -> Bool{
        
        guard let documentsURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return  false}
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            for url in directoryContents{
                print("Test URL ::: \(url)")
            }
            //Check contens is empty?
            if directoryContents.count < 5{
                print("The dir is empty...\(directoryContents.count)")
//                copyFileToLocal()
                return true
            }
        }catch{
            print("Catch fail \(error.localizedDescription)")
        }
        
        print("The dir has some data ")
        return false
    }
    

    
    
}
