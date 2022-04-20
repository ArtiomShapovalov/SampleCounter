# SampleCounter

This project helps to reproduce the iOS guided access bug.

**Steps to reproduce the bug**

- go to 'Accessibility' -> 'Guided Access' and enable the guided access feature
- open SampleCounter app
- press the broadcast button at the bottom of SampleCounter screen, start the broadcast
  <img src="images/img1.png" width="250px" />
- open PUBG and go to the game main screen
- start guided access while on the main screen
- after a few seconds disable guided access
- return to the SampleCounter app and open logs, by pressing the logs button in the top right corner of the screen
- see the list of resolutions of the samples that the broadcast extension receives, it logs every time the resolution of the incoming samples changes. When the guided access is enabled the resolution drops.
  <img src="images/img2.png" width="250px" />
