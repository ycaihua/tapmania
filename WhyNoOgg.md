# OGG format is not supported

# Why not? #

I spent one night and one full day hacking around with OGG vorbis libs.
Sure I was hoping to get OGG up and running and I did so. However it seems impossible to get OGG working as fast as MP3. The reason for that is clear: iPhone OS lacks built-in, lowlevel, hardware based support for OGG and thus I had to add that support my self. However decoding OGG to RAW data which can be played by the Sound libraries of iPhone is VERY costly.. and the worse news is really that this decoding is forced to happen on the CPU instead of specific hardware (like for mp3).
So basically there will be no OGG support till Apple adds it to their libs. Once they add this support - we will be able to play OGG without changes to TapMania code.. it will just start working!

# How to deal with this for now #

The only thing you can really do is simply convert your .ogg songs to .mp3 songs.
Try downloading a converter (there are many in existence) and just give it a try.
When you finished converting a song you probably get something like this:
**SongName.ogg** becomes **SongName.mp3**. So you just replace the files on the device and you should be good to go.

Happy tapping!
Alex