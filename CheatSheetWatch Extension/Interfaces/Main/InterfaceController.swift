//
//  InterfaceController.swift
//  CheatSheetWatch Extension
//
//  Created by Timur Shafigullin on 31/01/2019.
//  Copyright © 2019 Timur Shafigullin. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    // MARK: - Nested Types
    
    fileprivate enum Constants {
        
        // MARK: - Type Properties
        
        static let tableRowType = "CheatSheetRow"
    }
    
    // MARK: -
    
    fileprivate enum Controllers {
        
        // MARK: - Type Properties
        
        static let cheatSheetDetails = "CheatSheetDetails"
    }
    
    // MARK: - Instance Properties

    @IBOutlet fileprivate weak var table: WKInterfaceTable!
    @IBOutlet fileprivate weak var noDataLabel: WKInterfaceLabel!
    
    // MARK: -
    
    fileprivate var watchSession: WCSession?
    
    fileprivate var cheatSheets: [CheatSheet] = []
    
    // MARK: - Initializers
    
    deinit {
        self.unsubscribeFromDataSourceChangeEvents()
    }
    
    // MARK: - Instance Methods
    
    fileprivate func configure(cheatSheetRowController rowController: CheatSheetRowController, with cheatSheet: CheatSheet) {
        rowController.title = cheatSheet.title
    }
    
    // MARK: -
    
    fileprivate func subscribeToDataSourceChangeEvents() {
        self.unsubscribeFromDataSourceChangeEvents()
        
        WatchSessionManager.shared.dataSourceDidChangedEvent.connect(self, handler: { [weak self] dataSource in
            switch dataSource.item {
            case .cheatSheets(let cheatSheets):
                self?.apply(cheatsSheets: cheatSheets)
                
            case .unknown:
                Log.high("Receive unknown item", from: self)
            }
        })
    }
    
    fileprivate func unsubscribeFromDataSourceChangeEvents() {
        WatchSessionManager.shared.dataSourceDidChangedEvent.disconnect(self)
    }
    
    // MARK: -
    
    fileprivate func apply(cheatsSheets: [CheatSheet]) {
        Log.high("apply(cheatSheets: \(cheatsSheets.count))", from: self)
        
        self.cheatSheets = cheatsSheets
        
        self.noDataLabel.setHidden(!cheatsSheets.isEmpty)
        
        self.table.setNumberOfRows(cheatsSheets.count, withRowType: Constants.tableRowType)
        
        for (index, cheatSheet) in cheatsSheets.enumerated() {
            guard let rowController = self.table.rowController(at: index) as? CheatSheetRowController else {
                continue
            }
            
            self.configure(cheatSheetRowController: rowController, with: cheatSheet)
        }
    }
    
    // MARK: - WKInterfaceController
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.subscribeToDataSourceChangeEvents()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let cheatSheet = self.cheatSheets[rowIndex]
        
        self.presentController(withName: Controllers.cheatSheetDetails, context: cheatSheet)
    }
}
