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
    private let recentTable = Table("Recent")
    
    private let book_name = Expression<String>("BookName")
    private let book_level = Expression<Int>("Book_Level")
    private let book_no = Expression<Int>("book_no")
    private let book_id = Expression<Int>("book_id")
    private let book_downloaded = Expression<Bool>("BookDownloaded")
    private let book_completion = Expression<Int>("BookCompletion")
    private let book_sheetCount = Expression<Int>("BookSheetCount")
    
    private let sheet_name = Expression<String>("SheetName")
    private let sheet_level = Expression<String>("SheetLevel")
    private let sheet_book = Expression<String>("Sheet_Book")
    private let sheet_downloaded = Expression<Bool>("SheetDownloaded")
    private let sheet_recorded = Expression<String>("SheetRecorded")
    private let sheet_completion = Expression<Int>("SheetCompletion")
    
    private let recent_level = Expression<Int>("RecentLevel")
    private let recent_Date = Expression<String>("RecentDate")
    private let recent_Sheet = Expression<String>("RecentSheet")
    private let recent_Completion = Expression<Int>("RecentCompletion")
    

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
            if createBookTable() && createSheetTable() && createRecentTable() {
                db?.userVersion = 3
                return true
            }else{
                return false
            }
        }else if  db?.userVersion == 1 {
            do
            {
                try self.db?.run(bookTable.addColumn(book_id, defaultValue: -1))
                db?.userVersion = 2
                if createRecentTable() {
                    db?.userVersion = 3
                    return true
                }else {
                    return false
                }
            } catch {
                print("db?.userVersion == 1: \(error)")
                return false
            }
            
        }else if  db?.userVersion == 2{
            if createRecentTable() {
                db?.userVersion = 3
                return true
            }else {
                return false
            }
        }else if  db?.userVersion == 3{
            return true
        }
        return false
    }
    
    func createBookTable() -> Bool {
        var createSucceed = false
        do{
            try db!.run(bookTable.create(ifNotExists: true) { table in
                table.column(book_name, primaryKey: true)
                table.column(book_level, defaultValue: 0)
                table.column(book_no, defaultValue: 0)
                table.column(book_id, defaultValue: -1)
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
                table.column(sheet_completion, defaultValue: 0)
            })
            //            print("create user Table succeed")
            createSucceed = true
        }catch{
            print("Unable to create sheetTable")
            print(error.localizedDescription)
        } 
        return createSucceed
    }
    
    func createRecentTable() -> Bool {
        var createSucceed = false
        do{
            try db!.run(recentTable.create(ifNotExists: true) { table in
                table.column(recent_level, primaryKey: true)
                table.column(recent_Date, defaultValue: "")
                table.column(recent_Sheet, defaultValue: "")
                table.column(recent_Completion, defaultValue: 0)
            })
            //            print("create user Table succeed")
            createSucceed = true
        }catch{
            print("Unable to create recentTable")
            print(error.localizedDescription)
        }
        return createSucceed
    }
    
    func insertBookInfo(_ book: Book) -> Bool {
        do {
            let insert = bookTable.insert(book_name <- book.name,
                                          book_level <- book.level,
                                          book_no <- book.bookLevel,
                                          book_id <- book.bid,
                                          book_downloaded <- book.isImgDownloaded,
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
    
    func loadBooks(level: Int, completionHandler: (_ books: [Book]) -> Void) {
        let select = bookTable.filter(book_level == level)
        var allBooks = [Book]()
        do {
            for aBook in try db!.prepare(select) {
                let book = Book(name: aBook[book_name],
                                level: aBook[book_level],
                                bookLevel: aBook[book_no],
                                bid: aBook[book_id],
                                isImgDownloaded: aBook[book_downloaded],
                                completion: aBook[book_completion],
                                sheetCount: aBook[book_sheetCount])
                allBooks.append(book)
            }
            
        }catch {
            print("loadBooks failed")
        }
        completionHandler(allBooks)
    }
    
    func loadBookInfo(level: Int, bookNo: Int, completionHandler: (_ books: Book) -> Void) {
        let select = bookTable.filter(book_level == level && book_no == bookNo)
        do {
            for aBook in try db!.prepare(select) {
                let book = Book(name: aBook[book_name],
                                level: aBook[book_level],
                                bookLevel: aBook[book_no],
                                bid: aBook[book_id],
                                isImgDownloaded: aBook[book_downloaded],
                                completion: aBook[book_completion],
                                sheetCount: aBook[book_sheetCount])
                completionHandler(book)
            }
            
        }catch {
            print("loadBooks failed")
        }
    }
    
    func updateBookInfo(_ book: Book) -> Bool {
        do {
            let bookInTable = bookTable.filter(book_level == book.level && book_no == book.bookLevel)
            let update = bookInTable.update(book_name <- book.name,
                                          book_level <- book.level,
                                          book_id <- book.bid,
                                          book_downloaded <- book.isImgDownloaded)
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("update Book error: \(error.localizedDescription)")
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
    
    func loadSheets(level: String, completionHandler: (_ sheets: [Sheet]) -> Void) {
        let select = sheetTable.filter(sheet_level == level)
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
            print("loadSheets by level failed")
        }
        completionHandler(allSheets)
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
            print("loadSheets failed")
        }
        completionHandler(allSheets)
    }
    
    func updateSheetInfo(level: String, bookLevel: String, name: String, completion: Int, recorded: String) -> Bool {
        do {
            let sheetInTable = sheetTable.filter(sheet_level == level && sheet_book == bookLevel && sheet_name == name)
            let update = sheetInTable.update([sheet_completion <- completion,
                                           sheet_recorded <- recorded])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("update Sheet Info error: \(error.localizedDescription)")
        }
        return false
    }
    
    func insertRecentData(level: Int, date: String, sheetName: String, Completion: Int) -> Bool {
        do {
            let insert = recentTable.insert(recent_level <- level,
                                          recent_Date <- date,
                                          recent_Sheet <- sheetName,
                                          recent_Completion <- Completion)
            if try db!.run(insert) > 0 {
                return true
            }
        } catch {
            print("Insert recent error: \(error.localizedDescription)")
        }
        return false
    }
    
    func updateRecentData(level: Int, date: String, sheetName: String, Completion: Int) -> Bool {
        do {
            let recentInTable = recentTable.filter(recent_level == level)
            let update = recentInTable.update(recent_Date <- date,
                                            recent_Sheet <- sheetName,
                                            recent_Completion <- Completion)
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("update recent error: \(error.localizedDescription)")
        }
        return false
    }
    
    func loadRecent(level: Int, completionHandler: (_ date: String, _ sheet: String, _ completion: Int) -> Void) {
        let select = recentTable.filter(recent_level == level)
        do {
            for data in try db!.prepare(select) {
                completionHandler(data[recent_Date], data[recent_Sheet], data[recent_Completion])
                return
            }
            
        }catch {
            print("loadSheets failed")
        }
        completionHandler("", "", 0)
    }
}


extension Connection {
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}
