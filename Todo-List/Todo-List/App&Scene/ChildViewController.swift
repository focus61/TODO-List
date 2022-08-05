//
//  ChildViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 04.08.2022.
//

import UIKit

class ChildViewController: UIViewController {
    let button = UIButton()
    var displayMode: DisplayMode = .lightMode

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(button)
        button.setTitle("+", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        button.backgroundColor = CustomColor(displayMode: displayMode).blue

    }
    @objc func addTask() {
        let vc = CurrentTaskViewController()
//        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
//        navigationController?.present(vc, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
        button.frame.size = CGSize(width: 50, height: 50)
        button.layer.cornerRadius = 25
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
