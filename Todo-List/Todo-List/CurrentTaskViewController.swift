//
//  ViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 30.07.2022.
//

import UIKit

class CurrentTaskViewController: UIViewController {
    private var displayMode: DisplayMode = .lightMode
    var cancelBarItem = UIBarButtonItem()
    var saveBarItem = UIBarButtonItem()
    private let maxHeight: CGFloat = 100
    let textView: UITextView = .init(frame: .zero)
    var textViewHeight: NSLayoutConstraint?
    var heightKeyboard: CGFloat = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func updateTextView(param: Notification) {
        guard let userInfo = param.userInfo,
              let getKeyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {return}
        let keyboardFrame = view.convert(getKeyboardRect, to: view.window)
        if param.name ==  UIResponder.keyboardWillShowNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
//            textView.scrollIndicatorInsets = textView.contentInset
        }
//        textView.scrollRangeToVisible(textView.selectedRange)
        print(getKeyboardRect, self.view.bounds.height)
        print(self.view.bounds.height - getKeyboardRect.size.height)
        self.heightKeyboard = getKeyboardRect.size.height
    }
    @objc func keyboardWillShow(_ notification:NSNotification) {
//        let d = notification.userInfo!
//        var r = (d[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        r = self.textView.convert(r, from:nil)
//        self.textView.contentInset.bottom = r.size.height
//        self.textView.verticalScrollIndicatorInsets.bottom = r.size.height
        print("Show")

    }

    @objc func keyboardWillHide(_ notification:NSNotification) {
        print("Hide")
//        let contentInsets = UIEdgeInsets.zero
//        self.textView.contentInset = contentInsets
//        self.textView.verticalScrollIndicatorInsets = contentInsets
    }
    private func configureView() {
        navigationItemConfigure()
        textViewConfigure()
    }
    
    private func textViewConfigure() {
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
        textView.contentSize.height = maxHeight
        textView.font = CustomFont.body
        textView.text = "Что надо сделать?"
        textView.layer.cornerRadius = 20
        textView.isScrollEnabled = false
        textView.delegate = self

        
    }

    
    private func navigationItemConfigure() {
        title = "Дело"
        
        cancelBarItem = UIBarButtonItem(title: "Отменить", style: .done, target: self, action: #selector(cancelTarget))
        navigationItem.leftBarButtonItem = cancelBarItem
        
        saveBarItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTask))
        navigationItem.rightBarButtonItem = saveBarItem
    }
    @objc func cancelTarget() {
        print("CANCEL")
//        self.dismiss(animated: true)
    }
    @objc func saveTask() {
        print("SAVE")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayMode = traitCollection.userInterfaceStyle == .dark ? .darkMode : .lightMode
        colorChangeSettings()

    }
    
    func colorChangeSettings() {
        cancelBarItem.tintColor = CustomColor(displayMode: displayMode).blue
        saveBarItem.tintColor = CustomColor(displayMode: displayMode).blue
        view.backgroundColor = CustomColor(displayMode: displayMode).backPrimary
        textView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        textView.textColor = CustomColor(displayMode: displayMode).labelTertiary
    }
}
extension CurrentTaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.contentSize.height >= maxHeight {
//            self.textView.sizeToFit()
        }
        if (self.view.bounds.height - textView.contentSize.height - view.safeAreaInsets.top - 50) <= self.heightKeyboard {
            print("SOME")
        }
    }
}
