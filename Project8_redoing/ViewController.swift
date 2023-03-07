//
//  ViewController.swift
//  Project8_redoing
//
//  Created by Almas Aitken on 16.01.2023.
//

import UIKit

class ViewController: UIViewController {
    var scoreLabel: UILabel!
    var clueLabel: UILabel!
    var answerLabel: UILabel!
    var currentAnswer: UITextField!
    var letterButtons = [UIButton]()
    var wordsGuessed = 0
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: \(score)"
        view.addSubview(scoreLabel)
        
        clueLabel = UILabel()
        clueLabel.translatesAutoresizingMaskIntoConstraints = false
        clueLabel.text = "CLUES"
        clueLabel.font = UIFont.systemFont(ofSize: 24)
        clueLabel.numberOfLines = 0
        clueLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(clueLabel)
        
        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.text = "ANSWERS"
        answerLabel.textAlignment = .right
        answerLabel.font = UIFont.systemFont(ofSize: 24)
        answerLabel.numberOfLines = 0
        answerLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answerLabel)

        currentAnswer = UITextField()
        currentAnswer.placeholder = "TAP LETTERS TO GUESS"
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let clearButton = UIButton(type: .system)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("CLEAR", for: .normal)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clearButton)
        
        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("SUBMIT", for: .normal)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.layer.borderWidth = 1
        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(buttonsView)
        
        let buttonHeight = 80
        let buttonWidth = 150
        
        for row in 0..<4 {
            for column in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                let frame = CGRect(x: column*buttonWidth, y: row*buttonHeight, width: buttonWidth, height: buttonHeight)
                letterButton.frame = frame
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            clueLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10),
            clueLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            clueLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            answerLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answerLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answerLabel.heightAnchor.constraint(equalTo: clueLabel.heightAnchor),
            answerLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            
            currentAnswer.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            currentAnswer.topAnchor.constraint(equalTo: clueLabel.bottomAnchor, constant: 10),
            currentAnswer.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            
            submitButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 10),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clearButton.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
            clearButton.heightAnchor.constraint(equalTo: submitButton.heightAnchor),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.global(qos: .default).async {
            [weak self] in
            self?.loadLevel()
        }
    }

    @objc func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        for button in activatedButtons {
            button.isHidden = false
        }
        activatedButtons.removeAll()
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        guard let answerText = currentAnswer.text else { return }
        
        if let index = solutions.firstIndex(of: answerText) {
            activatedButtons.removeAll()
            var answerLines = answerLabel.text?.components(separatedBy: "\n")
            answerLines?[index] = solutions[index]
            answerLabel.text = answerLines?.joined(separator: "\n")
            
            score += 1
            wordsGuessed += 1
            currentAnswer.text = ""
            
            if wordsGuessed % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Go to next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        } else {
            score -= 1
            let ac = UIAlertController(title: "Error!", message: "There is no such word", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) {
                [weak self] _ in
                if let actBtns = self?.activatedButtons {
                    for btn in actBtns {
                        btn.isHidden = false
                    }
                }
                self?.activatedButtons.removeAll()
                self?.currentAnswer.text = ""
            })
            present(ac, animated: true)
        }
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        sender.isHidden = true
    }
    
    @objc func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let fileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let fileContent = try? String(contentsOf: fileURL) {
                var lines = fileContent.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index+1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
                
                DispatchQueue.main.async {
                    [weak self] in
                    self?.clueLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
                    self?.answerLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    letterBits.shuffle()
                    
                    if let letterButtons = self?.letterButtons {
                        if letterBits.count == letterButtons.count {
                            for i in 0..<letterButtons.count {
                                letterButtons[i].setTitle(letterBits[i], for: .normal)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        loadLevel()
        for btn in letterButtons {
            btn.isHidden = false
        }
    }

}

