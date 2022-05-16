/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class ViewController: UIViewController {
  
  private let customCBServiceButton = UIButton()
  private let centralDeviceButton = UIButton()
  private let buttonStackView = UIStackView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    configStackView()
    initLayouts()
  }
  
  private func configStackView() {
    customCBServiceButton.setTitle("iPad", for: .normal)
    customCBServiceButton.setTitleColor(.black, for: .normal)
    customCBServiceButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
    customCBServiceButton.addTarget(self, action: #selector(customCBServiceButtonDidPress), for: .touchUpInside)
    
    centralDeviceButton.setTitle("iPhone", for: .normal)
    centralDeviceButton.setTitleColor(.black, for: .normal)
    centralDeviceButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
    centralDeviceButton.addTarget(self, action: #selector(centralDeviceButtonDidPress), for: .touchUpInside)
    
    buttonStackView.addArrangedSubview(customCBServiceButton)
    buttonStackView.addArrangedSubview(centralDeviceButton)
    buttonStackView.axis = .vertical
    buttonStackView.spacing = 10
  }
  
  private func initLayouts() {
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(buttonStackView)
    NSLayoutConstraint.activate([
      buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }
}

/// objc methods
extension ViewController {
  @objc func customCBServiceButtonDidPress() {
    let vc = CustomCBServiceViewController()
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc func centralDeviceButtonDidPress() {
    let vc = ReceiveiPadBatteryUpdateViewController()
    navigationController?.pushViewController(vc, animated: true)
  }
}
