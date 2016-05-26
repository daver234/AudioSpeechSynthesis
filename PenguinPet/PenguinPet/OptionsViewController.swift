//
//  OptionsViewController.swift
//  PenguinPet
//
//  Created by Michael Briscoe on 12/17/15.
//  Copyright © 2015 Razeware. All rights reserved.
//

import UIKit
import AVFoundation

class OptionsViewController: UIViewController {
  
  @IBOutlet weak var pitchSlider: UISlider!
  @IBOutlet weak var rateSlider: UISlider!
  @IBOutlet weak var textMessage: UITextView!
  
  let defaults = NSUserDefaults.standardUserDefaults()
  unowned var vc: ViewController = ViewController()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pitchSlider.value = defaults.floatForKey("Pitch")
    rateSlider.value = defaults.floatForKey("Rate")
    textMessage.text = defaults.stringForKey("Message")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  @IBAction func closeOptions(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func setPitch(sender: AnyObject) {
    defaults.setFloat(sender.value, forKey: "Pitch")
    defaults.synchronize()
  }
  
  func storeTextMessage() {
    defaults.setObject(textMessage.text, forKey: "Message")
    defaults.synchronize()
  }
  
  @IBAction func setRate(sender: AnyObject) {
    defaults.setFloat(sender.value, forKey: "Rate")
    defaults.synchronize()
  }
  
  @IBAction func previewAudio(sender: AnyObject) {
    storeTextMessage()
    
    if vc.synthesizer.speaking == true {
      vc.stopPlayback()
    } else {
      vc.play()
    }
  }
  
  @IBAction func reset(sender: AnyObject) {
    let pitchValue = Float(1.0)
    
    defaults.setFloat(pitchValue, forKey: "Pitch")
    defaults.setFloat(AVSpeechUtteranceDefaultSpeechRate, forKey: "Rate")
    defaults.setObject("Hello, my name is Perry Penguin. Whats yours?", forKey: "Message")
    defaults.synchronize()
    
    pitchSlider.value = pitchValue
    rateSlider.value = AVSpeechUtteranceDefaultSpeechRate
    textMessage.text = defaults.stringForKey("Message")
  }
}

extension OptionsViewController: UITextViewDelegate {
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      storeTextMessage()
      textView.resignFirstResponder()
      return false
    }
    return true
  }
}

