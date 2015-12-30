//
//  CommentsDetailedViewController.swift
//  FileManager
//
//  Created by Vineeth Vijayan on 28/12/15.
//  Copyright © 2015 Vineeth Vijayan. All rights reserved.
//

import UIKit
import SwiftFilePath
import EZAudio

class CommentsDetailedViewController: UITableViewController, EZMicrophoneDelegate, EZRecorderDelegate, EZAudioPlayerDelegate {
    
    let mainDir = "fileMangerDir"
    let audioDir = "audioDir"
    
    var microphone: EZMicrophone!;
    var recorder: EZRecorder!
    
    var isRecording = false
    var isPlaying = false
    var fileUrl = NSURL!()
    
    let inspectionId = 100
    let sectionId = 100
    let questionId = 100
    
    var indexPathOfCommentsRow = NSIndexPath()
    var indexPathOfRecordRow = NSIndexPath()
    var cellOfRecordRow = RecordTableViewCell()
    var currentAudioPlayingCell = AudioPlayTableViewCell()
    
    
    var startTime = NSTimeInterval()
    var elapsedTime = NSTimeInterval()
    var startTimeDate = NSDate()
    var elapsedTimeDate = NSDate()
    var timer = NSTimer()
    
    @IBOutlet weak var btnRecord: UIButton!
    
    @IBAction func btnRecordTapped(sender: AnyObject) {
        
        let cell = self.cellOfRecordRow
        
        if isRecording == false {
            UIView.animateWithDuration(0.2, animations: {
                cell.imageViewRecord.alpha = 0.4
                cell.imageViewRecord.image = UIImage(named: "save")
                }, completion: {
                    (value: Bool) in
                    cell.imageViewRecord.alpha = 1
            })
            self.isRecording = true
            
            self.microphone.startFetchingAudio()
            cell.viewDisplayGraph.plotType = .Rolling
            
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTimeDate = NSDate()
            startTime = NSDate.timeIntervalSinceReferenceDate() + elapsedTime
            
        }
        else{
            UIView.animateWithDuration(0.2, animations: {
                cell.imageViewRecord.alpha = 0.4
                cell.imageViewRecord.image = UIImage(named: "record")
                }, completion: {
                    (value: Bool) in
                    cell.imageViewRecord.alpha = 1
            })
            self.isRecording = false
            
            self.microphone.stopFetchingAudio()
            if ((self.recorder) != nil)
            {
                self.recorder.closeAudioFile()
                let tempAudio = Path.documentsDir[mainDir][audioDir]["audioTemp.m4a"]
                let destAudio = Path.documentsDir[mainDir][audioDir]["audio1.m4a"]
                if destAudio.exists {
                    destAudio.remove()
                }
                tempAudio.copyTo(destAudio)
                cell.viewDisplayGraph.clear()
                
                self.fileUrl = NSURL(fileURLWithPath: Path.documentsDir[mainDir][audioDir]["audioTemp.m4a"].toString(), isDirectory: false)
                self.recorder = EZRecorder(URL: self.fileUrl,
                    clientFormat: self.microphone.audioStreamBasicDescription(),
                    fileType: EZRecorderFileType.M4A,
                    delegate: self)
                
                self.recorder.delegate = self
                
                let audioCellIndexPath = NSIndexPath(forRow: 0, inSection: 2)
                
                self.tableView.reloadRowsAtIndexPaths([audioCellIndexPath], withRowAnimation: UITableViewRowAnimation.None)
                
                timer.invalidate()
                elapsedTime = 0
            }
            

        }
    }
    
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        cellOfRecordRow.labelTimer.text = strMinutes+":"+strSeconds+":"+strFraction
        
    }
    
    func playButtonTapped(sender:UIButton){
        print("playButtonTapped")
        
        self.currentAudioPlayingCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as! AudioPlayTableViewCell
        
        self.microphone.stopFetchingAudio()
        
        let url = NSURL(fileURLWithPath: Path.documentsDir[mainDir][audioDir]["audio1.m4a"].toString(), isDirectory: false)
        let audioFile = EZAudioFile(URL: url)
        //        recorder.closeAudioFile()
        if EZAudioPlayer.sharedAudioPlayer() == nil {
            print("sdfsfsdf")
        }
        
        EZAudioPlayer.sharedAudioPlayer().delegate = self// = EZAudioPlayer(delegate: self)
        EZAudioPlayer.sharedAudioPlayer().audioFile = audioFile
        EZAudioPlayer.sharedAudioPlayer().volume = 10
        EZAudioPlayer.sharedAudioPlayer().play()
        currentAudioPlayingCell.imagePlay.image = UIImage(named: "pause")
    }
    
    func sliderValueChanged(sender: UISlider) {
        EZAudioPlayer.sharedAudioPlayer().seekToFrame(Int64(sender.value))
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if isRecording{
            self.recorder.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cellOfRecordRow.viewDisplayGraph?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        
        // Update any UI controls including sliders and labels
        // display current time/duration
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            
//            if (self.currentAudioPlayingCell.audioSlider.touchInside)
//            {
            self.currentAudioPlayingCell.audioSlider.setValue(Float(framePosition), animated: true)
//            }
            
            
            //self.lblTime.text = String(Int(framePosition)/36000)
            //            print((strHours)+":"+(strMinutes)+":"+(strSeconds))
            self.currentAudioPlayingCell.labelTimer.text = self.returnRemainingTimeOfPlayingAudio(self.currentAudioPlayingCell.totalFrames, framePosition: framePosition)
            
        })
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
        currentAudioPlayingCell.imagePlay.image = UIImage(named: "play")
    }
    
    func returnRemainingTimeOfPlayingAudio(totalFrames :Int64, framePosition: Int64)->String{
        
        let seconds = Int(((totalFrames-framePosition)/36000)) % 60
        let minutes = (Int(((totalFrames-framePosition)/36000)) / 60) % 60
        let hours = Int(((totalFrames-framePosition)/36000)) / 3600
        let strHours = hours > 9 ? String(hours) : "0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        return (strHours)+":"+(strMinutes)+":"+(strSeconds)
        
    }

    @IBAction func btnCloseTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dir = Path.documentsDir[mainDir][audioDir]
        dir.mkdir()
        
        self.microphone = EZMicrophone(delegate: self, startsImmediately: true);
        self.microphone.stopFetchingAudio()
        
        self.fileUrl = NSURL(fileURLWithPath: Path.documentsDir[mainDir][audioDir]["audioTemp.m4a"].toString(), isDirectory: false)
        self.recorder = EZRecorder(URL: self.fileUrl,
            clientFormat: self.microphone.audioStreamBasicDescription(),
            fileType: EZRecorderFileType.M4A,
            delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else{
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            indexPathOfCommentsRow = indexPath
            let cell = tableView.dequeueReusableCellWithIdentifier("commentTextBoxCell", forIndexPath: indexPath)
            
            return cell
        }
        else if indexPath.section == 1{
            indexPathOfRecordRow = indexPath
            let cell = tableView.dequeueReusableCellWithIdentifier("recorderCell", forIndexPath: indexPath) as! RecordTableViewCell
            
            cell.viewDisplayGraph.plotType = EZPlotType.Rolling
            cell.viewDisplayGraph?.shouldFill = true;
            cell.viewDisplayGraph?.shouldMirror = true;
            
            self.cellOfRecordRow = cell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("audioCell", forIndexPath: indexPath) as! AudioPlayTableViewCell
            cell.btnPlay.addTarget(self, action: "playButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.audioSlider.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let url = NSURL(fileURLWithPath: Path.documentsDir[mainDir][audioDir]["audio1.m4a"].toString(), isDirectory: false)
            let audioFile = EZAudioFile(URL: url)

            cell.audioSlider.maximumValue = Float(audioFile.totalFrames)
            cell.totalFrames = audioFile.totalFrames
            
            cell.labelTimer.text = returnRemainingTimeOfPlayingAudio(audioFile.totalFrames, framePosition: 0)
            
            return cell
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        return 44
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
//    
//    func updateTime() {
//        
//        var currentTime = NSDate.timeIntervalSinceReferenceDate()
//        
//        //Find the difference between current time and start time.
//        
//        var elapsedTime: NSTimeInterval = currentTime - startTime
//        
//        //calculate the minutes in elapsed time.
//        
//        let minutes = UInt8(elapsedTime / 60.0)
//        
//        elapsedTime -= (NSTimeInterval(minutes) * 60)
//        
//        //calculate the seconds in elapsed time.
//        
//        let seconds = UInt8(elapsedTime)
//        
//        elapsedTime -= NSTimeInterval(seconds)
//        
//        //find out the fraction of milliseconds to be displayed.
//        
//        let fraction = UInt8(elapsedTime * 100)
//        
//        //add the leading zero for minutes, seconds and millseconds and store them as string constants
//        
//        let strMinutes = String(format: "%02d", minutes)
//        let strSeconds = String(format: "%02d", seconds)
//        let strFraction = String(format: "%02d", fraction)
//        
//        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
//        
//        lblTime.text = strMinutes+":"+strSeconds+":"+strFraction
//        
//    }

}

class RecordTableViewCell: UITableViewCell{
    @IBOutlet weak var imageViewRecord: UIImageView!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var viewDisplayGraph: EZAudioPlot!
    @IBOutlet weak var labelTimer: UILabel!
    
    
}

class AudioPlayTableViewCell: UITableViewCell{
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imagePlay: UIImageView!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var labelTimer: UILabel!
    internal var totalFrames: Int64 = 0
    
}