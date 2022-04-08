# Swifty Pusher

This is a GUI tool helps to test Apple Push Notifications to your physical device. 

*Donate or Buy me a Coffee would be much appreciate! 😄*

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2NYP5MX3HAFYQ)

<img width="256" alt="Screenshot 2022-04-08 at 9 17 46 PM" src="https://user-images.githubusercontent.com/9628305/162445205-f2923c05-5dad-4634-a594-07d48b7e1950.png">

# About

Push notifications testing on your device could be a pain. You might consider to set up a nofitication test server, which introduces a lot of works to get systems connected properly. But, sometimes, developer only needs to check if notification works on client apps. Apple recommended varies ways to test push notifications on either simulators or physical devices. Apple introduces sending push nottifications using command-line tool. But it is no easy-of-use for all users.

That's why I made this tool to user-friendly with GUI. This tool might be helpful to whom does not prefer command line tools or shell scripts. :)

So, this is inspired by Apple's document sending_push_notifications_using_command-line_tools
https://developer.apple.com/documentation/usernotifications/sending_push_notifications_using_command-line_tools

# Installation

You could install it from:
* [App Store](https://apps.apple.com/sg/app/swifty-pusher/id1618221326?mt=12)
* [Github Release](https://github.com/Lyle-Du/Swifty-Pusher/releases)

# How to Use

This is an Authentication-key based utility. APNs authentication key is required for APNs network communication. You might want to know [how notification requests works with APNs](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns/).

In addition to that, Apple account team ID, App bundle ID, APNs authentication key ID, and device token are required.
- Team ID - 10 Characters ID
- Bundle ID - e.g. com.example.app
- Key ID - 10 Characters authentication key ID
- Authentication Key - authentication key encoded in base64 formatted ASN.1 PKCS#8 file.
    
    * To obtain an authentication key, please check [here](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns "Establishing a Token-Based Connection to APNs").
    
- Device Token - It is a unique device token that APNs identifies which device is and push notifications to that device.
    
    * To obtain a device token, please check [here](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns "Registering Your App with APNs").
    
- Payload - You can edit your playload as you wish. But you do have to use valid payload in order for success APNs requests.

This tool remembers all the text input fields. But it doesn't remember authentication key content. So, with a new launch of it, it needs you to import the key manually.

<img width="300" alt="Screenshot 2022-04-08 at 9 17 46 PM" src="https://user-images.githubusercontent.com/9628305/162443880-1f54a390-c234-46c1-9748-0539b02d64ee.png">

# Donation

Donate or Buy me a Coffee would be much appreciate! 😄

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2NYP5MX3HAFYQ)

# Privacy Policy

https://www.freeprivacypolicy.com/live/62010e01-0d52-4cd7-8994-fdab8f3b4623
