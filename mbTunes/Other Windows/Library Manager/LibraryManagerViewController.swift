//
//  LibraryManagerViewController.swift
//  mbTunes
//
//  Created by John Moody on 2/13/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Cocoa
import DiskArbitration
import IOKit

class TrackNotFound: NSObject {
    var path: String?
    let track: Track
    var trackDescription: String
    init(path: String?, track: Track) {
        self.path = path
        self.track = track
        self.trackDescription = "\(String(describing: track.artist?.name)) - \(String(describing: track.album?.name)) - \(String(describing: track.name))"
    }
}

class NewMediaURL: NSObject {
    let url: URL
    var toImport: Bool
    init(url: URL) {
        self.url = url
        self.toImport = true
    }
}

class LibraryManagerViewController: NSViewController, NSTableViewDelegate, NSTabViewDelegate {
    
    @IBOutlet weak var tabView: NSTabView!
    var fileManager = FileManager.default
    var databaseManager = DatabaseManager()
    var locationManager = (NSApplication.shared.delegate as! AppDelegate).locationManager!
    var library: Library?
    var missingTracks: [Track]?
    var newMediaURLs: [URL]?
    var delegate: AppDelegate?
    @objc var watchFolders = [URL]()
    var advancedOrganizationOptionsWindowController: AdvancedOrganizationOptionsWindowController?
    var missingFilesViewController: MissingFilesViewController?

    @IBOutlet weak var findNewMediaTabItem: NSTabViewItem!
    @IBOutlet weak var locationManagerTabItem: NSTabViewItem!
    
    //data controllers
    @IBOutlet var tracksNotFoundArrayController: NSArrayController!
    @IBOutlet var newTracksArrayController: NSArrayController!
    @IBOutlet var watchFoldersArrayController: NSArrayController!
    
    //source information elements
    @IBOutlet weak var watchFolderTableView: NSTableView!
    @IBOutlet weak var sourceNameField: NSTextField!
    @IBOutlet weak var sourceMonitorStatusImageView: NSImageView!
    @IBOutlet weak var sourceMonitorStatusTextField: NSTextField!
    @IBOutlet weak var sourceLocationField: JMPathControl!
    @IBOutlet weak var doesOrganizeCheck: NSButton!
    @IBOutlet weak var moveRadio: NSButton!
    @IBOutlet weak var copyRadio: NSButton!
    @IBOutlet weak var changeLocationButton: NSButton!
    @IBOutlet weak var addWatchFolderButton: NSButton!
    @IBOutlet weak var removeWatchFolderButton: NSButton!
    @IBOutlet weak var mediaAddBehaviorLabel: NSTextField!
    @IBOutlet weak var consolidateLibraryButton: NSButton!
    @IBOutlet weak var watchFoldersLabel: NSTextField!
    @IBOutlet weak var fileMonitorDescriptionLabel: NSTextField!
    
    @IBOutlet weak var automaticallyAddFilesCheck: NSButton!
    @IBOutlet weak var enableDirectoryMonitoringCheck: NSButton!
    
    @IBAction func enableMonitoringCheckAction(_ sender: Any) {
        if enableDirectoryMonitoringCheck.state == NSControl.StateValue.on {
            library?.keeps_track_of_files = true as NSNumber
            sourceMonitorStatusImageView.image = NSImage(named: NSImage.statusAvailableName)
            sourceMonitorStatusTextField.stringValue = "Directory monitoring is enabled."
        } else {
            library?.keeps_track_of_files = false as NSNumber
            sourceMonitorStatusImageView.image = NSImage(named: NSImage.statusUnavailableName)
            sourceMonitorStatusTextField.stringValue = "Directory monitoring inactive."
        }
        initializeForLibrary(library: library!)
        self.locationManager.reinitializeEventStream()
        
    }
    @IBAction func automaticallyAddCheckAction(_ sender: Any) {
        library!.monitors_directories_for_new = automaticallyAddFilesCheck.state == NSControl.StateValue.on ? true as NSNumber : false as NSNumber
        if automaticallyAddFilesCheck.state == NSControl.StateValue.on {
            self.watchFolderTableView.isEnabled = true
            self.addWatchFolderButton.isEnabled = true
            self.removeWatchFolderButton.isEnabled = true
            self.watchFolderTableView.tableColumns[0].isHidden = false
            if let watchDirs = library?.watch_dirs as? NSArray {
                self.watchFolders = watchDirs as! [URL]
                self.watchFoldersArrayController.content = self.watchFolders
            }
        } else {
            self.watchFolderTableView.isEnabled = false
            self.addWatchFolderButton.isEnabled = false
            self.removeWatchFolderButton.isEnabled = false
            self.watchFolderTableView.tableColumns[0].isHidden = true
        }
        locationManager.reinitializeEventStream()
    }
    
    @IBAction func sourceNameWasEdited(_ sender: Any) {
        if let textField = sender as? NSTextField, textField.stringValue != "" {
            library?.name = textField.stringValue
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
            initializeForLibrary(library: library!)
        }
    }
    
    @IBAction func changeSourceCentralMediaFolderButtonPressed(_ sender: Any) {
        let parent = self.view.window?.windowController as! PreferencesWindowController
        parent.changeFolderSheet = ChangePrimaryFolderSheetController(windowNibName: "ChangePrimaryFolderSheetController")
        parent.changeFolderSheet?.libraryManager = self
        parent.window?.beginSheet(parent.changeFolderSheet!.window!, completionHandler: nil)
        
    }
    
    @IBAction func changeSourceLocationButtonPressed(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        let response = openPanel.runModal()
        if response.rawValue == NSFileHandlingPanelOKButton {
            let newURL = openPanel.urls[0]
            library?.changeCentralFolderLocation(newURL: newURL)
            locationManager.reinitializeEventStream()
            initializeForLibrary(library: self.library!)
        }
    }
    @IBAction func advancedOrganizationPressed(_ sender: Any) {
        self.advancedOrganizationOptionsWindowController = AdvancedOrganizationOptionsWindowController(windowNibName: "AdvancedOrganizationOptionsWindowController")
        self.view.window?.addChildWindow(self.advancedOrganizationOptionsWindowController!.window!, ordered: .above)
    }
    
    @IBAction func orgBehaviorChecked(_ sender: Any) {
        if doesOrganizeCheck.state == NSControl.StateValue.off {
            library?.organization_type = NO_ORGANIZATION_TYPE as NSNumber
            moveRadio.isEnabled = false
            copyRadio.isEnabled = false
            changeLocationButton.isEnabled = false
        } else {
            moveRadio.isEnabled = true
            copyRadio.isEnabled = true
            changeLocationButton.isEnabled = true
            sourceLocationField.url = library?.getCentralMediaFolder()
            orgBehaviorRadioAction(self)
        }
    }
    @IBAction func orgBehaviorRadioAction(_ sender: Any) {
        if moveRadio.state == NSControl.StateValue.on {
            library?.organization_type = MOVE_ORGANIZATION_TYPE as NSNumber
        } else {
            library?.organization_type = COPY_ORGANIZATION_TYPE as NSNumber
        }
    }
    
    @IBAction func addWatchFolderPressed(_ sender: Any) {
        let parent = self.view.window?.windowController as! PreferencesWindowController
        parent.watchFolderSheet = AddWatchFolderSheetController(windowNibName: "AddWatchFolderSheetController")
        parent.watchFolderSheet?.libraryManager = self
        parent.window?.beginSheet(parent.watchFolderSheet!.window!, completionHandler: nil)
    }
    
    func addWatchFolder(_ watchFolder: URL) {
        watchFoldersArrayController.addObject(watchFolder)
        var currentLibraryWatchDirs = self.library?.watch_dirs as? [URL] ?? [URL]()
        currentLibraryWatchDirs.append(watchFolder)
        self.library?.watch_dirs = currentLibraryWatchDirs as NSArray
        self.locationManager.reinitializeEventStream()
    }
    
    @IBAction func removeWatchFolderPressed(_ sender: Any) {
        guard watchFoldersArrayController.selectedObjects.count > 0 else {return}
        let watchFolder = watchFoldersArrayController.selectedObjects[0] as! URL
        self.removeWatchFolder(watchFolder)
    }
    
    func removeWatchFolder(_ watchFolder: URL) {
        watchFoldersArrayController.removeObject(watchFolder)
        var currentLibraryWatchDirs = self.library?.watch_dirs as? [URL] ?? [URL]()
        currentLibraryWatchDirs.remove(at: currentLibraryWatchDirs.firstIndex(of: watchFolder)!)
        self.library?.watch_dirs = currentLibraryWatchDirs as NSObject
        self.locationManager.reinitializeEventStream()
    }
    
    @IBAction func consolidateLibraryPressed(_ sender: Any) {
        let parent = self.view.window?.windowController as! PreferencesWindowController
        parent.someOtherSheet = GenericProgressBarSheetController(windowNibName: "GenericProgressBarSheetController")
        parent.window?.beginSheet(parent.someOtherSheet!.window!, completionHandler: nil)
        let subContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        subContext.parent = managedContext
        subContext.perform {
            let things = determineTemplateLocations(context: subContext, visualUpdateHandler: parent.someOtherSheet)
            DispatchQueue.main.async {
                //parent.someOtherSheet?.finish()
                parent.consolidateSheet = ConsolidateLibrarySheetController(windowNibName: "ConsolidateLibrarySheetController")
                parent.consolidateSheet?.things = things
                subContext.perform {
                    parent.consolidateSheet?.initialize(context: subContext, visualUpdateHandler: parent.someOtherSheet)
                    DispatchQueue.main.async {
                        parent.someOtherSheet?.finish()
                        parent.window?.beginSheet(parent.consolidateSheet!.window!, completionHandler: nil)
                        parent.consolidateSheet?.libraryManager = self
                    }
                }
            }
        }
    }
    
    func initializeForLibrary(library: Library) {
        print("init for \(String(describing: library.name))")
        self.library = library
        sourceNameField.stringValue = library.name!
        if let centralMediaFolderURL = library.getCentralMediaFolder() {
            sourceLocationField.url = centralMediaFolderURL
        }
        if library.organization_type != nil && library.organization_type != 0 {
            copyRadio.isEnabled = true
            moveRadio.isEnabled = true
            changeLocationButton.isEnabled = true
            doesOrganizeCheck.state = NSControl.StateValue.on
            if library.organization_type?.intValue == MOVE_ORGANIZATION_TYPE {
                moveRadio.state = NSControl.StateValue.on
            } else if library.organization_type?.intValue == COPY_ORGANIZATION_TYPE {
                copyRadio.state = NSControl.StateValue.on
            }
        } else {
            doesOrganizeCheck.state = NSControl.StateValue.off
            copyRadio.isEnabled = false
            moveRadio.isEnabled = false
            changeLocationButton.isEnabled = false
        }
        if library.monitors_directories_for_new == true {
            automaticallyAddFilesCheck.state = NSControl.StateValue.on
            if let watchDirs = library.watch_dirs as? [URL] {
                self.watchFolders = watchDirs
                self.watchFoldersArrayController.content = self.watchFolders
            }
            addWatchFolderButton.isEnabled = true
            removeWatchFolderButton.isEnabled = true
        } else {
            automaticallyAddFilesCheck.state = NSControl.StateValue.off
            self.watchFolders = [URL]()
            addWatchFolderButton.isEnabled = false
            removeWatchFolderButton.isEnabled = false
        }
        if library.keeps_track_of_files == true {
            enableDirectoryMonitoringCheck.state = NSControl.StateValue.on
            sourceMonitorStatusImageView.image = NSImage(named: NSImage.statusAvailableName)
            sourceMonitorStatusTextField.stringValue = "Directory monitoring is active."
        } else {
            enableDirectoryMonitoringCheck.state = NSControl.StateValue.off
            sourceMonitorStatusImageView.image = NSImage(named: NSImage.statusUnavailableName)
            sourceMonitorStatusTextField.stringValue = "Directory monitoring inactive."
        }
    }
    
    //location manager
    @IBOutlet weak var locationManagerView: NSView!
    @IBOutlet weak var trackLocationStatusText: NSTextField!
    @IBOutlet weak var verifyLocationsButton: NSButton!
    @IBOutlet weak var libraryLocationStatusImageView: NSImageView!
    
    @IBAction func verifyLocationsPressed(_ sender: Any) {
        let parent = self.view.window?.windowController as! PreferencesWindowController
        parent.verifyLocationsSheet = LocationVerifierSheetController(windowNibName: "LocationVerifierSheetController")
        parent.window?.beginSheet(parent.verifyLocationsSheet!.window!, completionHandler: verifyLocationsModalComplete)
        let subContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        subContext.parent = managedContext
        subContext.perform {
            let library = subContext.object(with: self.library!.objectID) as! Library
            self.missingTracks = self.databaseManager.verifyTrackLocations(visualUpdateHandler: parent.verifyLocationsSheet, library: library, context: subContext)
            DispatchQueue.main.async {
                self.missingTracks = self.missingTracks?.map({ return managedContext.object(with: $0.objectID) as! Track })
                self.verifyLocationsModalComplete(response: NSApplication.ModalResponse(rawValue: 1))
            }
        }
    }
    
    func displayMissingFilesViewController(for tracks: inout [Track]) {
        self.missingFilesViewController = MissingFilesViewController(nibName: "MissingFilesViewController", bundle: nil, tracks: &tracks)
        self.missingFilesViewController?.libraryManager = self
        self.locationManagerView.addSubview(self.missingFilesViewController!.view)
        self.missingFilesViewController!.view.topAnchor.constraint(equalTo: self.locationManagerView.topAnchor).isActive = true
        self.missingFilesViewController!.view.leftAnchor.constraint(equalTo: self.locationManagerView.leftAnchor).isActive = true
        self.missingFilesViewController!.view.bottomAnchor.constraint(equalTo: self.locationManagerView.bottomAnchor).isActive = true
        self.missingFilesViewController!.view.rightAnchor.constraint(equalTo: self.locationManagerView.rightAnchor).isActive = true
    }
    
    func verifyLocationsModalComplete(response: NSApplication.ModalResponse) {
        guard response != NSApplication.ModalResponse.cancel else {return}
        if self.missingTracks!.count > 0 {
            displayMissingFilesViewController(for: &self.missingTracks!)
            let trackNotFoundArray = self.missingTracks!.map({(track: Track) -> TrackNotFound in
                if let location = track.location {
                    if let url = URL(string: location) {
                        return TrackNotFound(path: url.path, track: track)
                    } else {
                        return TrackNotFound(path: location, track: track)
                    }
                } else {
                    return TrackNotFound(path: nil, track: track)
                }
            })
            self.libraryLocationStatusImageView.image = NSImage(named: "NSStatusPartiallyAvailable")
            self.trackLocationStatusText.stringValue = "\(self.missingTracks!.count) tracks not found."
            tracksNotFoundArrayController.content = trackNotFoundArray
        } else {
            self.libraryLocationStatusImageView.image = NSImage(named: "NSStatusAvailable")
            self.trackLocationStatusText.stringValue = "All tracks located."
        }
    }
    
    func updateMissingTracks(count: Int) {
        if count > 0 {
            self.libraryLocationStatusImageView.image = NSImage(named: "NSStatusPartiallyAvailable")
            self.trackLocationStatusText.stringValue = "\(count) tracks not found."
        } else {
            self.libraryLocationStatusImageView.image = NSImage(named: "NSStatusAvailable")
            self.trackLocationStatusText.stringValue = "All tracks located."
        }
    }
    
    //dir scanner
    @IBOutlet weak var newMediaTableView: NSTableView!
    @IBOutlet weak var dirScanStatusTextField: NSTextField!
    @IBOutlet weak var directoryPicker: NSPopUpButton!
    
    @IBAction func scanSourceButtonPressed(_ sender: Any) {
        let parent = self.view.window?.windowController as! PreferencesWindowController
        parent.mediaScannerSheet = MediaScannerSheet(windowNibName: "MediaScannerSheet")
        parent.window?.beginSheet(parent.mediaScannerSheet!.window!, completionHandler: scanMediaModalComplete)
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.newMediaURLs = self.databaseManager.scanForNewMedia(visualUpdateHandler: parent.mediaScannerSheet, library: self.library!)
            DispatchQueue.main.async {
                self.scanMediaModalComplete(response: NSApplication.ModalResponse(rawValue: 1))
            }
        }
    }
    
    func scanMediaModalComplete(response: NSApplication.ModalResponse) {
        if self.newMediaURLs!.count > 0{
            newTracksArrayController.content = self.newMediaURLs!.map({return NewMediaURL(url: $0)})
            
            dirScanStatusTextField.stringValue = "\(self.newMediaURLs!.count) new media files found."
            newMediaTableView.reloadData()
        } else {
            dirScanStatusTextField.stringValue = "No new media found."
        }
    }
    
    @IBAction func importSelectedPressed(_ sender: Any) {
        let mediaURLsToAdd = (newTracksArrayController.arrangedObjects as! [NewMediaURL]).filter({return $0.toImport == true}).map({return $0.url})
        let errors = databaseManager.addTracksFromURLs(mediaURLsToAdd, to: self.library!, context: managedContext, visualUpdateHandler: nil, callback: nil)
        for url in mediaURLsToAdd {
            newMediaURLs!.remove(at: newMediaURLs!.firstIndex(of: url)!)
        }
        newTracksArrayController.content = self.newMediaURLs!.map({return NewMediaURL(url: $0)})
        newMediaTableView.reloadData()
    }
    
    @IBAction func selectAllPressed(_ sender: Any) {
        for trackContainer in (newTracksArrayController.arrangedObjects as! [NewMediaURL]) {
            trackContainer.toImport = true
        }
        newMediaTableView.reloadData()
    }
    
    @IBAction func selectNonePressed(_ sender: Any) {
        for trackContainer in (newTracksArrayController.arrangedObjects as! [NewMediaURL]) {
            trackContainer.toImport = false
        }
        newMediaTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
