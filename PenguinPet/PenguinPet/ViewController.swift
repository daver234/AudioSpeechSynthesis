//
//  ViewController.swift
//  PenguinPet
//
//  Created by Michael Briscoe on 1/13/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
// 
//  Modified by Dave Rothschild May 25, 2016

import UIKit
import AVFoundation

class ViewController: UIViewController {

  @IBOutlet weak var penguin: UIImageView!
  @IBOutlet weak var playButton: UIButton!
  
  var audioStatus: AudioStatus = AudioStatus.Stopped
  var updateTimer: CADisplayLink!
  
  var speechTimer: CFTimeInterval = 0.0
  
  let synthesizer = AVSpeechSynthesizer()

  // MARK: - Setup
  override func viewDidLoad() {
    super.viewDidLoad()
    synthesizer.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "optionsSeque" {
      let optionsVC = segue.destinationViewController as! OptionsViewController
      optionsVC.vc = self
    }
  }
  
  // MARK: - Controls
  @IBAction func onPlay(sender: UIButton) {
    switch audioStatus {
    case .Stopped:
      play()
    case .Playing:
      pausePlayback()
    case .Paused:
        continuePlayback()
    }
  }

  func setPlayButtonOn(flag: Bool) {
    if flag == true {
      playButton.setBackgroundImage(UIImage(named: "button-play1"), forState: UIControlState.Normal)
    } else {
      playButton.setBackgroundImage(UIImage(named: "button-play"), forState: UIControlState.Normal)
    }
  }
  
  // MARK: - Update Loop
  func startUpdateLoop() {
    if updateTimer != nil {
      updateTimer.invalidate()
    }
    updateTimer = CADisplayLink(target: self, selector: #selector(ViewController.updateLoop))
    updateTimer.frameInterval = 1
    updateTimer.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
  }
  
  func stopUpdateLoop() {
    if updateTimer != nil {
      updateTimer.invalidate()
      updateTimer = nil
    }
    // Update UI
    animateMouth(1)
  }
  
  func updateLoop() {
    if audioStatus == .Playing {
      if CFAbsoluteTimeGetCurrent() - speechTimer > 0.1 {
        animateMouth(1 + randomInt(5))
        speechTimer = CFAbsoluteTimeGetCurrent()
      }
    }
  }
  
  func animateMouth(frame: Int) {
    let frameName = "penguin_0\(frame)"
    let frame = UIImage(named: frameName)
    penguin.image = frame
  }
    
    func pausePlayback() {
        synthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Word)
    }
    
    func continuePlayback() {
        synthesizer.continueSpeaking()
    }

}

// MARK: - AVFoundation Methods
extension ViewController: AVSpeechSynthesizerDelegate {
  
  // MARK: Playback
  func  play() {
    let defaults = NSUserDefaults.standardUserDefaults()
    let utterance = AVSpeechUtterance(string: defaults.stringForKey("Message")!)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
    utterance.rate = AVSpeechUtteranceMaximumSpeechRate * defaults.floatForKey("Rate")
    utterance.pitchMultiplier = defaults.floatForKey("Pitch")
    synthesizer.speakUtterance(utterance)
  }
  
  func stopPlayback() {
    synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
    stopUpdateLoop()
    setPlayButtonOn(false)
    audioStatus = .Stopped
  }
  
  // MARK: Delegates
  func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
    setPlayButtonOn(true)
    startUpdateLoop()
    audioStatus = .Playing
  }
  
  func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
    stopUpdateLoop()
    setPlayButtonOn(false)
    audioStatus = .Stopped
  }
  
  func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
    
    let speakingString = utterance.speechString as NSString
    let word = speakingString.substringWithRange(characterRange)
    print(word)
  }
  
  // MARK: - Helpers
  func randomInt(n: Int) -> Int {
    return Int(arc4random_uniform(UInt32(n)))
  }
}


