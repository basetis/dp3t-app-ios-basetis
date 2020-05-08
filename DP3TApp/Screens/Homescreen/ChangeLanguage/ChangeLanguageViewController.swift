///

import Foundation
import UIKit

class ChangeLanguageViewController: NSViewController {
    // MARK: - Views

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)
    private let symptomView = NSWhatToDoSymptomView()

    private let titleElement = UIAccessibilityElement(accessibilityContainer: self)
    private var titleContentStackView = UIStackView()
    private var subtitleLabel: NSLabel!
    private var titleLabel: NSLabel!

    // MARK: - Init

    override init() {
        super.init()
        
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ns_backgroundSecondary

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didPressClose))
        
        setupStackScrollView()
        setupLayout()

        setupAccessibility()
    }

    // MARK: - Setup

    private func setupStackScrollView() {
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupLayout() {
        titleContentStackView.axis = .vertical
        stackScrollView.addSpacerView(NSPadding.large)

        // Title & subtitle
//        subtitleLabel = NSLabel(.textLight, textAlignment: .center)
//        subtitleLabel.text = "symptom_detail_subtitle".ub_localized

        titleLabel = NSLabel(.title, textAlignment: .center)
        titleLabel.text = "change_language".ub_localized

        titleContentStackView.addArrangedView(titleLabel)
        titleContentStackView.addSpacerView(3.0)

        stackScrollView.addArrangedView(titleContentStackView)

        stackScrollView.addSpacerView(NSPadding.large)
                
        let languages = [Language.spanish, Language.catalan, Language.english]
        
        for lang in languages {
            
            let isSelected = Language.currentLocaleLanguage() == lang
            
            let view = NSSimpleModuleWithActionBaseView(title: lang.name, isSelected: isSelected, touchUpCallback: {
                self.didSelectLanguage(lang)
            })
            stackScrollView.addArrangedView(view)
            stackScrollView.addSpacerView(NSPadding.large)
        }

    }
    
    private func updateLayout() {
        
        titleLabel.text = "change_language".ub_localized
        
        for view in self.stackScrollView.stackView.arrangedSubviews {
            if let baseView = view as? NSSimpleModuleWithActionBaseView {
                baseView.setSelected(Language.currentLocaleLanguage().name == baseView.title)
            }
        }
        
        view.setNeedsLayout()
        view.setNeedsDisplay()
        view.layoutIfNeeded()
    }
    
    private func didSelectLanguage(_ lang: Language) {
        
        LanguageManager.setLanguage(language: lang)
        updateLayout()
    }

    private func setupAccessibility() {
        titleContentStackView.isAccessibilityElement = true
//        titleContentStackView.accessibilityLabel = (subtitleLabel.text?.deleteSuffix("...") ?? "") + (titleLabel.text ?? "")
        accessibilityElements = [titleContentStackView, symptomView]
    }

    // MARK: - Detail

    private func presentCoronaCheck() {
        if let url =
            URL(string: "symptom_detail_corona_check_url".ub_localized) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Navigation

    @objc private func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
}

