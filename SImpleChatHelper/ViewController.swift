//
//  ViewController.swift
//  SImpleChatHelper
//
//  Created by Aakaash kapoor on 1/20/20.
//  Copyright © 2020 Aakaash kapoor. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ViewController: MessagesViewController {
    
    // declaring the arrays to store the messages
    var messages: [Message] = []
    var member: Member!
    var chatService: ChatService!
    var easyDict:Dictionary<String, String> = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        member = Member(name: .randomName, color: .random)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        easyDict = getDictionary()
        
        chatService = ChatService(member: member, onRecievedMessage: {
          [weak self] message in
          self?.messages.append(message)
          self?.messagesCollectionView.reloadData()
          self?.messagesCollectionView.scrollToBottom(animated: true)
        })

        chatService.connect()
    }
    

    func getDictionary() -> Dictionary<String, String> {
        
        // reading the file
        if let filepath = Bundle.main.path(forResource: "words", ofType: "txt") {
            
            // if everything reads perfectly
            do {
                // read the contents and seperate by line
                let contents = try String(contentsOfFile: filepath)
                var listOfWords = contents.components(separatedBy: "\n")
                listOfWords.removeLast()
                
                // the new dictionary to return back
                var toReturn = Dictionary<String, String>()
                
                // go through and create it serating by comma
                for word in listOfWords {
                    let eachSection = word.components(separatedBy: ",")
                    
                    for(index, part) in eachSection[0].components(separatedBy: "|").enumerated() {
                        
                        toReturn[part] = eachSection[1].components(separatedBy: "|")[index]
                    }
    //                toReturn[word.components(separatedBy: ",")[0]] = word.components(separatedBy: ",")[1]
                }
                
                return toReturn
                
            } catch {
                // contents could not be loaded
                return Dictionary<String, String>()
            }
        } else {
            // example.txt not found!
            return Dictionary<String, String>()
        }
    }

    func makeEasy(message: String) -> String {
        
        
        var new_message = message
        
        
        // going through and subsituting phrases
        for key in easyDict.keys
        {
            if(key.contains(" "))
            {
                new_message = new_message.replacingOccurrences(of: key, with: String(easyDict[key] ?? " "), options: .caseInsensitive)
            }
        }
        
        // going through and subsituting words
        for key in easyDict.keys
        {
            if(key.contains(" ") == false)
            {
                new_message = new_message.replacingOccurrences(of: key, with: String(easyDict[key] ?? " "), options: .caseInsensitive)
            }
        }
        
        
        
//        // splitting the text by space
//        var words = new_message.components(separatedBy: CharacterSet([" ", "\n", ",", "."]))
//
//
//    //    print(easyDict)
//
//        // going through and trying to see if anything matches
//        for(index, word) in words.enumerated() {
//
//            // if the word exists in the dictionary then do a word substu
//            if(easyDict[word.lowercased()] != nil){
//                words[index] = String(easyDict[word] ?? " ")
//            }
//        }
//
//        // joining them back
//        let changedMessage = words.joined(separator: " ")
        
        return new_message
    }
    
}

extension ViewController: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> SenderType {
        return Sender(senderId: member.name, displayName: member.name)
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        var message = makeEasy(message: messages[indexPath.section].text)
        
        if(message == messages[indexPath.section].text)
        {
            message = " "
        }
        return NSAttributedString(
            string: message,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
    
}


extension ViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}

extension ViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section]
        let color = message.member.color
        avatarView.backgroundColor = color
    }
}


extension ViewController: InputBarAccessoryViewDelegate {
    func inputBar(
        _ inputBar: InputBarAccessoryView,
        didPressSendButtonWith text: String) {
        
        chatService.sendMessage(text)
        inputBar.inputTextView.text = ""
        
    }
}
