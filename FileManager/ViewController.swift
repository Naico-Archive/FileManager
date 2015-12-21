//
//  ViewController.swift
//  FileManager
//
//  Created by Vineeth Vijayan on 17/12/15.
//  Copyright © 2015 Vineeth Vijayan. All rights reserved.
//

import UIKit
import SwiftFilePath
import EZAudio

class ViewController: UIViewController, EZMicrophoneDelegate, EZRecorderDelegate, EZAudioPlayerDelegate {

    let mainDir = "fileMangerDir"
    let audioDir = "audioDir"
    
    var microphone: EZMicrophone!;
    var recorder: EZRecorder!
//    var player: EZAudioPlayer!
    var isRecording = false
    var fileUrl = NSURL!()
    
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var logTextBox: UITextView!
    @IBOutlet weak var displayGraph: EZAudioPlot!
    @IBOutlet weak var lblLog: UILabel!
    
    @IBAction func btnCreateFileTapped(sender: AnyObject) {
        let dir = Path.documentsDir[mainDir]
        if dir.exists{
            let file = dir["file1.json"]
            if file.exists{
                file.writeString(file.readString()! + "Hello Swift")
                logTextBox.text = logTextBox.text + "File Data added "
            }
            else{
                file.touch()
                logTextBox.text = logTextBox.text + "File Created"
            }
        }
        else{
            dir.mkdir()
            logTextBox.text = logTextBox.text + "Directory Created"
        }
    }
    
    @IBAction func btnListFilesTapped(sender: AnyObject) {
        let dir = Path.documentsDir[mainDir][audioDir]
        if dir.exists {
            for content:Path in dir.contents! {
                logTextBox.text = logTextBox.text + " " + content.basename.description + " " + (content.attributes?.fileSize().description)!
            }
        }
        logTextBox.scrollsToBottom()
        
    }
    
    @IBAction func btnViewFileTapped(sender: AnyObject) {
    }
    
    @IBAction func btnDeleteFileTapped(sender: AnyObject) {
        logTextBox.text = ""
    }
    
    @IBAction func btnRecordTapped(sender: AnyObject) {
        if isRecording == false {
//            let tempAudio = Path.documentsDir[mainDir][audioDir]["audioTemp.m4a"]
//            if tempAudio.exists{
//                tempAudio.remove()
//            }
//            tempAudio.touch()
            self.microphone.startFetchingAudio()
            self.displayGraph.plotType = .Rolling
//            self.recorder.cl
            self.isRecording = true
            btnRecord.setTitle("Stop Recording", forState: UIControlState.Normal)
        }
        else{
            self.microphone.stopFetchingAudio()
            self.isRecording = false
            if ((self.recorder) != nil)
            {
                self.recorder.closeAudioFile()
                let tempAudio = Path.documentsDir[mainDir][audioDir]["audioTemp.m4a"]
                let destAudio = Path.documentsDir[mainDir][audioDir]["audio1.m4a"]
                if destAudio.exists {
                    destAudio.remove()
                }
                tempAudio.copyTo(destAudio)
	                displayGraph.clear()
                
                self.fileUrl = NSURL(fileURLWithPath: Path.documentsDir[mainDir][audioDir]["audioTemp.m4a"].toString(), isDirectory: false)
                self.recorder = EZRecorder(URL: self.fileUrl,
                    clientFormat: self.microphone.audioStreamBasicDescription(),
                    fileType: EZRecorderFileType.M4A,
                    delegate: self)
                
                self.recorder.delegate = self
            }
            btnRecord.setTitle("Record", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func btnPlayTapped(sender: AnyObject) {
        self.microphone.stopFetchingAudio()
        
        let url = NSURL(fileURLWithPath: Path.documentsDir[mainDir][audioDir]["audio1.m4a"].toString(), isDirectory: false)
        let audioFile = EZAudioFile(URL: url)
//        recorder.closeAudioFile()
        if EZAudioPlayer.sharedAudioPlayer() == nil {
            print("sdfsfsdf")
        }
        
        EZAudioPlayer.sharedAudioPlayer().delegate = self// = EZAudioPlayer(delegate: self)
        EZAudioPlayer.sharedAudioPlayer().audioFile = audioFile
        EZAudioPlayer.sharedAudioPlayer().volume = 1
        EZAudioPlayer.sharedAudioPlayer().play()
        self.displayGraph.plotType = .Buffer
    }
    
    //Mark Audio Functions
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if isRecording{
            self.recorder.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.displayGraph?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
        self.displayGraph.clear()
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
//        if isPause == true {
            self.displayGraph.updateBuffer(buffer[0], withBufferSize: bufferSize)
//        }
    }
    
    //End Mark
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        logTextBox.text = ""
        
        displayGraph.plotType = EZPlotType.Rolling
        displayGraph?.shouldFill = true;
        displayGraph?.shouldMirror = true;
        
        microphone = EZMicrophone(delegate: self, startsImmediately: true);
        self.microphone.stopFetchingAudio()
        
        let dir = Path.documentsDir[mainDir][audioDir]
        dir.mkdir()
        
        logTextBox.text = Path.documentsDir[mainDir][audioDir]["audioTemp.m4a"].toString()
        
        self.fileUrl = NSURL(fileURLWithPath: Path.documentsDir[mainDir][audioDir]["audioTemp.m4a"].toString(), isDirectory: false)
//        self.fileUrl = NSURL(fileURLWithPath: Path.documentsDir[mainDir][audioDir].description, isDirectory: false)
//        
//        // NSURL.fileURLWithPath(path! + "/EZAudioTest_"+session.description+".m4a")
//        
        self.recorder = EZRecorder(URL: self.fileUrl,
            clientFormat: self.microphone.audioStreamBasicDescription(),
            fileType: EZRecorderFileType.M4A,
            delegate: self)
        
//        self.player = EZAudioPlayer(delegate: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UITextView{
    func scrollsToBottom() {
        let range = NSMakeRange(self.text.characters.count - 1, 1);
        self.scrollRangeToVisible(range)
    }
}

