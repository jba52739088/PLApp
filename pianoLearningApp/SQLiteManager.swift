//
//  SQLiteManager.swift
//  pianoLearningApp
//
//  Created by Vincent_Huang on 2019/3/10.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import Foundation
import SQLite

class SQLiteManager {
    
    static private var _shared: SQLiteManager?
    
    static var shared: SQLiteManager! {
        if _shared == nil {
            _shared = SQLiteManager()
        }
        return _shared
    }
    
    private let db: Connection?
    private let databaseFileName = "pianoLearning.db"
    private let bookTable = Table("Book")
    private let sheetTable = Table("Sheet")
    
    private let book_name = Expression<String>("BookName")
    private let book_level = Expression<String>("Book_Level")
    private let book_downloaded = Expression<Bool>("BookDownloaded")
    private let book_completion = Expression<Int>("BookCompletion")
    private let book_sheetCount = Expression<Int>("BookSheetCount")
    
    private let sheet_name = Expression<String>("SheetName")
    private let sheet_level = Expression<String>("SheetLevel")
    private let sheet_book = Expression<String>("Sheet_Book")
    private let sheet_downloaded = Expression<Bool>("SheetDownloaded")
    private let sheet_recorded = Expression<String>("SheetRecorded")
    private let sheet_completion = Expression<Int>("SheetCompletion")

    private init() {
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        do {
            db = try Connection(documentsDirectory.appending("/\(databaseFileName)"))
            print ("open database succeed")
        } catch {
            db = nil
            print ("Unable to open database")
        }
    }
    
    func createDatebase() -> Bool {
        print("db version = \(db?.userVersion ?? 0)")
        if db?.userVersion == 0 {
            if createBookTable() && createSheetTable() {
                db?.userVersion = 1
                return true
            }else{
                return false
            }
        }else if  db?.userVersion == 1 {
            return true
        }
        return false
    }
    
    func createBookTable() -> Bool {
        var createSucceed = false
        do{
            try db!.run(bookTable.create(ifNotExists: true) { table in
                table.column(book_name, primaryKey: true)
                table.column(book_level, defaultValue: "")
                table.column(book_downloaded, defaultValue: false)
                table.column(book_completion, defaultValue: 0)
                table.column(book_sheetCount, defaultValue: 0)
            })
            //            print("create user Table succeed")
            createSucceed = true
        }catch{
            print("Unable to create BookTable")
            print(error.localizedDescription)
        }
        return createSucceed
    }
    
    func createSheetTable() -> Bool {
        var createSucceed = false
        do{
            try db!.run(sheetTable.create(ifNotExists: true) { table in
                table.column(sheet_name, primaryKey: true)
                table.column(sheet_level, defaultValue: "")
                table.column(sheet_book, defaultValue: "")
                table.column(sheet_downloaded, defaultValue: false)
                table.column(sheet_recorded, defaultValue: "")
                table.column(book_completion, defaultValue: 0)
            })
            //            print("create user Table succeed")
            createSucceed = true
        }catch{
            print("Unable to create sheetTable")
            print(error.localizedDescription)
        } 
        return createSucceed
    }
    
    func insertBookInfo(_ book: Book) -> Bool {
        do {
            let insert = bookTable.insert(book_name <- book.name,
                                          book_level <- book.level,
                                          book_downloaded <- book.isDownloaded,
                                          book_completion <- book.completion,
                                          book_sheetCount <- book.sheetCount)
            if try db!.run(insert) > 0 {
                return true
            }
        } catch {
            print("Insert Book error: \(error.localizedDescription)")
        }
        return false
    }
    
    func insertSheetInfo(_ sheet: Sheet) -> Bool {
        do {
            let insert = sheetTable.insert(sheet_name <- sheet.name,
                                          sheet_level <- sheet.level,
                                          sheet_book <- sheet.book,
                                          sheet_downloaded <- sheet.isDownloaded,
                                          sheet_completion <- sheet.completion,
                                          sheet_recorded <- sheet.recorded)
            if try db!.run(insert) > 0 {
                return true
            }
        } catch {
            print("Insert Book error: \(error.localizedDescription)")
        }
        return false
    }
    
    func loadSheets(level: String, book: String, completionHandler: (_ sheets: [Sheet]) -> Void) {
        let select = sheetTable.filter(sheet_level == level && sheet_book == book)
        var allSheets = [Sheet]()
        do {
            for aSheet in try db!.prepare(select) {
                let sheet = Sheet(name: aSheet[sheet_name],
                                  level: aSheet[sheet_level],
                                  book: aSheet[sheet_book],
                                  isDownloaded: aSheet[sheet_downloaded],
                                  completion: aSheet[sheet_completion],
                                  recorded: aSheet[sheet_recorded])
                allSheets.append(sheet)
            }
            
        }catch {
            print("loadFavoriteInfo failed")
        }
        completionHandler(allSheets)
    }
    
    
}


extension Connection {
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}
