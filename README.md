# Waterfall: Fix Multiple Monitor Desktop-Switching Focus Behaviour
MacOS allows the use of keyboard shortcuts (by default ctrl-[1-9]) to switch between desktops, 
however when multiple monitors are connected the OS does not behave as expected. If a desktop
is already being displayed on a monitor but that desktop does not have focus, using the keyboard
shortcut will not switch focus to the desktop, but instead do nothing. This application has been
developed as a fix to the current behaviour. 

## Usage
Usage of the app is pretty self-explanatory. The app requires accessibilty in order to capture 
keyboard input for switching desktop, and in order to give focus to a window. To bring up the
menu bar icon after disabling it, simply attempt to re-launch the app from you Applications folder
(launching from spotlight search will not work).

## Known Issues
The app has a number of known issues, mostly due to limitations of Apples APIs. For the most part the
application behaves well, and only chokes up under relative uncommon circumstances (such as connecting
and disconnecting monitors). If you find any bugs not mentioned below, feel free to let us know.

* Inside a Virtual Box VM (and likely other VMs), the keyboard shortcuts will leak out of the VM and
  be captured by our application.
* Our application relies on a plist which is not always up-to-date. When the plist gets out of sync
  with the system state the app may stop working. The simplest way to force the plist to update is
  to enter mission control and move a desktop with your cursor (you can put it back in the same place).
  This issue tends to pop up when connecting and disconnecting monitors.
* Windows that are not fully contained within a desktop may not be able to recieve focus correctly. If
  a window is dragged across two monitors, or has its top left corner off screen, giving focus may not
  behave as expected.
* Switching monitors while the menu popover is displayed may cause glitchy or unexpected behaviour. Click
  outside of the popover or hit any key on your keyboard to close the popover.

## Blog
We plan to put up an extensive write-up on our experience developing this app, as for both of us it was our
first experience developing for mac/i/watch OS. I will add a link once the write-up is available. 
Feedback on anything we've done here would be very much appreciated.

## Licensing
This app was developed by Isabella Stephens and Tony Gong. It is licensed under the BSD 3-clause license.


