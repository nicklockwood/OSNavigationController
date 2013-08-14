Purpose
--------------

OSNavigationController is a open source re-implementation of UINavigationController. It currently features only a subset of the functionality of UINavigationController, but the long-term aim is to replicate 100% of the features.

OSNavigationController is not really intended to be used as-is. The idea is that you can fork it and then easily customize its appearance and behaviour to suit any special requirements that your app may have. Customizing OSNavigationController is much simpler than trying to customize UINavigationController due to the fact that the code is open and you don't need to worry about private methods, undocumented behavior, or implementation changes between versions.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 6.1 (Xcode 4.6, Apple LLVM compiler 4.2)
* Earliest supported deployment target - iOS 5.0
* Earliest compatible deployment target - iOS 5.0

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

OSNavigationController requires ARC. If you wish to use OSNavigationController in a non-ARC project, just add the -fobjc-arc compiler flag to the OSNavigationController.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click OSNavigationController.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in OSNavigationController.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including OSNavigationController.m) are checked.


Installation
--------------

To install OSNavigationController into your app, drag the OSNavigationController.h, .m and .xib files into your project and add the QuartzCore framework. Create and use the OSNavigationController exactly as you would a normal UINavigationController.