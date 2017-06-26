import UIKit

/// A closure of action to be handled when the user tap one of the buttons.
@available(iOS 9.0, *)
public typealias NotieAction = (Void) -> Void

/// Notie is a dropdown notification view that presents above the main view controller.
@available(iOS 9.0, *)
open class Notie : UIView {

    // MARK: Properties

    /// The view that the notification will be displayed at top of it.
    open var view: UIView

    /// The message of the notification. Default to `nil`
    open var message: String?
    
    // The keyboard type to use for input
    open var keyboardType: UIKeyboardType?

    /// The style of the notification. `.Confirm` style includes message view and two confirm buttons. `.Input` style adds an extra input text field. Default to `.Confirm`.
    open var style: NotieStyle = .confirm
    
    /// A block to call when the user taps on the left button.
    open var leftButtonAction: NotieAction?

    /// A block to call when the user taps on the right button.
    open var rightButtonAction: NotieAction?
    
    // Tap on notification action.
    open var tapAction: NotieAction?

    /// The title of the left button. Default to `OK`.
    open var leftButtonTitle: String = "OK"

    /// The title of the left button. Default to `Cancel`.
    open var rightButtonTitle: String = "Cancel"

    /// The placeholder of the input text field. Default to `nil`.
    open var placeholder: String?

    /// How long the slide down animation should last.
    open var animationDuration: TimeInterval = 0.4

    /// The background color of the message view.
    open var messageBackgroundColor = UIColor(red: 88.0 / 255.0, green: 135.0 / 255.0, blue: 207.0 / 255.0, alpha: 1.0)

    /// The text color of the message view. Default to white color.
    open var messageTextColor = UIColor.white

    /// The background color of the input text field. Default to white color.
    open var inputFieldBackgroundColor = UIColor.white

    /// The text color of the input text field. Default to dark gray.
    open var inputFieldTextColor = UIColor.darkGray

    /// The background color of the left button.
    open var leftButtonBackgroundColor = UIColor(red: 117.0 / 255.0, green: 183.0 / 255.0, blue: 96.0 / 255.0, alpha: 1.0)

    /// The text color of the left button. Default to white color.
    open var leftButtonTextColor = UIColor.white

    /// The background color of the right button.
    open var rightButtonBackgroundColor = UIColor(red: 210.0 / 255.0, green: 120.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0)

    /// The text color of the right button. Default to white color.
    open var rightButtonTextColor = UIColor.white
    
    /// Whether or not the banner should dismiss itself when the user taps. Defaults to `true`.
    open var dismissesOnTap = true
    
    /// Whether or not the banner should dismiss itself when the user swipes up. Defaults to `true`.
    open var dismissesOnSwipe = true
    
    /// Update text alignment of message label and input text field.
    open var textAlignment = NSTextAlignment.center
    
    /// Min height of message label. Set to nil in order to remove this constraint
    open var minMessageLabelHeight: CGFloat? = 50

    public enum buttons: Int{
        case standard = 2
        case single = 1
    }

    open var buttonCount: buttons? = buttons.standard
    // MARK: Private Properties


    fileprivate let backgroundView = UIStackView()

    fileprivate let statusBarView = UIView()

    fileprivate let contentView = UIStackView()

    fileprivate let leftButton = UIButton()

    fileprivate let rightButton = UIButton()

    fileprivate var topConstraint: NSLayoutConstraint?

    fileprivate var bottomConstraint: NSLayoutConstraint?

    fileprivate var inputField: UITextField?

    // MARK: Life Cycle

    /// A Notie with the optional `message` and provided `style`, ready to be presented with `show()`.
    ///
    /// - parameter view: The view that the notification will be displayed on top of it.
    /// - parameter message: The message of the notification. Default to `nil`
    /// - parameter style: The style of the notification. `.Confirm` style includes message view and two confirm buttons. `.Input` style adds an extra input text field. Default to `.Confirm`.
    public init(view: UIView, message: String?, style: NotieStyle) {
        self.view = view
        self.message = message
        self.style = style

        super.init(frame: CGRect.zero)
    }

    /// This is required for classes conform to NSCoding protocol. Just don't care about it.
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    open func getText() -> String{
        if self.style == .input {
            if inputField != nil {
                return (inputField?.text)!
            }
        }else{
            return ""
        }
        return ""
    }
    // MARK: Action

    /// Shows the notification.
    open func show() {
        self.view.addSubview(self)
        self.backgroundColor = self.messageBackgroundColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.topConstraint = self.topAnchor.constraint(equalTo: self.view.topAnchor)
        self.bottomConstraint = self.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        self.topConstraint?.isActive = false
        self.bottomConstraint?.isActive = true

        self.configureBackgroundView()
        self.forceUpdates()

        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.bottomConstraint?.isActive = false
            self.topConstraint?.isActive = true
            self.forceUpdates()
        })
    }

    /// Dismisses the notification.
    open func dismiss() {
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.topConstraint?.isActive = false
            self.bottomConstraint?.isActive = true
            self.forceUpdates()
            }, completion: { (_) -> Void in
                self.removeFromSuperview()
        })
    }
    
    internal func didTap(_ recognizer: UITapGestureRecognizer) {
        if dismissesOnTap {
            dismiss()
        }
        tapAction?()
    }
    
    internal func didSwipe(_ recognizer: UISwipeGestureRecognizer) {
        if dismissesOnSwipe {
            dismiss()
        }
    }

    // MARK: Helpers

    fileprivate func forceUpdates() {
        setNeedsLayout()
        setNeedsUpdateConstraints()
        layoutIfNeeded()
        updateConstraintsIfNeeded()
        superview?.layoutIfNeeded()
    }


    // MARK: Configure Subviews

    fileprivate func configureBackgroundView() {
        self.configureStatusBarView()
        self.configureContentView()
        self.addSubview(self.backgroundView)
        self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.alignment = .top
        self.backgroundView.axis = .vertical
        self.backgroundView.distribution = .fill
        self.backgroundView.spacing = 0
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Notie.didTap(_:))))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(Notie.didSwipe(_:)))
        swipe.direction = .up
        self.addGestureRecognizer(swipe)
    }

    fileprivate func configureStatusBarView() {
        self.backgroundView.addArrangedSubview(self.statusBarView)
        self.statusBarView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }

    fileprivate func configureContentView() {
        self.addMessageLabelPadding(paddingValue: 4)
        self.configureMesasgeView()
        self.addMessageLabelPadding(paddingValue: 10)
        if self.style == .input {
            self.addInputFieldPadding()
            self.configureInputField()
            self.addInputFieldPadding()
        }
        
        if self.style != .noButtons {
           self.configureButtons()
        }
        

        self.backgroundView.addArrangedSubview(self.contentView)
        self.contentView.widthAnchor.constraint(equalTo: self.backgroundView.widthAnchor).isActive = true
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.alignment = .top
        self.contentView.axis = .vertical
        self.contentView.distribution = .fill
        self.contentView.spacing = 0
    }

    fileprivate func addMessageLabelPadding(paddingValue: CGFloat) {
        let padding = UIView()
        self.contentView.addArrangedSubview(padding)
        padding.heightAnchor.constraint(equalToConstant: paddingValue).isActive = true
        padding.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
    }

    fileprivate func configureMesasgeView() {
        let messageStackView = UIStackView()
        self.contentView.addArrangedSubview(messageStackView)
        messageStackView.alignment = .leading
        messageStackView.axis = .horizontal
        messageStackView.distribution = .fill
        messageStackView.spacing = 0
        messageStackView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
        
        let messageLeftIndentView = UIView()
        messageStackView.addArrangedSubview(messageLeftIndentView)
        messageLeftIndentView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        messageLeftIndentView.heightAnchor.constraint(equalTo: messageStackView.heightAnchor).isActive = true
        
        let messageLabel = UILabel()
        messageStackView.addArrangedSubview(messageLabel)
        messageLabel.numberOfLines = 0
        messageLabel.text = self.message
        messageLabel.textAlignment = textAlignment
        messageLabel.textColor = self.messageTextColor
        
        if let minMessageLabelHeight = minMessageLabelHeight {
            let constraint = NSLayoutConstraint(item: messageLabel,
                                                attribute: .height,
                                                relatedBy: .greaterThanOrEqual,
                                                toItem: nil,
                                                attribute: NSLayoutAttribute.notAnAttribute,
                                                multiplier: 1.0,
                                                constant: minMessageLabelHeight)
            messageLabel.addConstraint(constraint)
        }
        
        messageLabel.heightAnchor.constraint(equalTo: messageStackView.heightAnchor).isActive = true
        
        let messageRightIndentView = UIView()
        messageStackView.addArrangedSubview(messageRightIndentView)
        messageRightIndentView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        messageRightIndentView.heightAnchor.constraint(equalTo: messageStackView.heightAnchor).isActive = true
    }

    fileprivate func addInputFieldPadding() {
        let padding = UIView()
        self.contentView.addArrangedSubview(padding)
        padding.backgroundColor = self.inputFieldBackgroundColor
        padding.heightAnchor.constraint(equalToConstant: 5).isActive = true
        padding.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
    }

    fileprivate func configureInputField() {
        let inputField = UITextField()
        self.contentView.addArrangedSubview(inputField)
        self.inputField = inputField
        inputField.backgroundColor = self.inputFieldBackgroundColor
        inputField.textColor = self.inputFieldTextColor
        inputField.textAlignment = textAlignment
        inputField.placeholder = self.placeholder
        inputField.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true

        if self.keyboardType != nil {
            inputField.keyboardType = self.keyboardType!

        }
        // Make the keyboard show
        inputField.becomeFirstResponder()
    }

    fileprivate func configureButtons() {
        let buttonStack = UIStackView()
        self.contentView.addArrangedSubview(buttonStack)
        buttonStack.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true

        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .center
        buttonStack.spacing = 0
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let leftButton = UIButton()
        leftButton.backgroundColor = self.leftButtonBackgroundColor
        leftButton.setTitleColor(self.leftButtonTextColor, for: UIControlState())
        leftButton.setTitle(self.leftButtonTitle, for: UIControlState())
        leftButton.addTarget(self, action: #selector(Notie.leftButtonDidTap), for: .touchUpInside)
        buttonStack.addArrangedSubview(leftButton)

        let rightButton = UIButton()
        rightButton.backgroundColor = self.rightButtonBackgroundColor
        leftButton.setTitleColor(self.rightButtonTextColor, for: UIControlState())
        rightButton.setTitle(self.rightButtonTitle, for: UIControlState())
        rightButton.addTarget(self, action: #selector(Notie.rightButtonDidTap), for: .touchUpInside)
        if self.buttonCount != buttons.single {
             buttonStack.addArrangedSubview(rightButton)
        }

    }


    // MARK: Button Handlers

    func leftButtonDidTap() {
        if dismissesOnTap {
            dismiss()
        }
        
        guard let action = self.leftButtonAction else { return }
        action()
    }

    func rightButtonDidTap() {
        if dismissesOnTap {
            dismiss()
        }
        
        guard let action = self.rightButtonAction else { return }
        action()
    }
}
