Watson Speech To Text for Adobe AIR
=======================

Adobe AIR is a handy tool for prototyping. This is a simple example of how to use Speech To Text with Adobe AIR. There are two examples for each of the two kinds of STT Watson / Bluemix offers. Streaming continuous speech to text and a REST service. This works well on mobile iOS, Android, and Desktop Windows and Mac.

Streaming Version
-----

In this version (AIR Watson STT Stream) the microphone is activated and on sample events it sends chunks of 16 bit encoded pcm data to the service via websocket. This method is preferred as it gives immediate JSON feedback and gives users the most modern feel. This version includes a version much like https://speech-to-text-demo.mybluemix.net/

REST Version
-----

In this version (AIR Watson STT REST) the microphone is activated and when complete is encodes the data into a audio/wav format and then uploads to the service for analysis sending back JSON of the audio transcribed.

Notes
-----

Confidence: In these demos you can set the minimum confidence so as not to allow words that are not likely to be correct to show.

Flash: I've started to put together a version of this that runs with the Flash plugin but honestly it's not really needed.

