prefix=/dat/sys
CC=arm-apple-darwin9-gcc
LD=$(CC) 
FRAMEWORKS=-framework CoreFoundation -framework Foundation -framework UIKit -framework CoreAudio -framework OpenAL -framework CoreGraphics -framework OpenGLES -framework AudioToolbox -framework QuartzCore
LDFLAGS=-L"${prefix}/usr/lib" -F"${prefix}/System/Library/Frameworks" -bind_at_load -lobjc -lstdc++ $(FRAMEWORKS)
CFLAGS=-std=c99 -fobjc-exceptions -O2 -I. -IParsers -IUtil -IGameObjects -IEngine -IEngine/Protocols -IEngine/Objects -IEngine/ThemeSupport -IEngine/Transitions -IRenderers -IRenderers/UIElements -I"${prefix}/usr/include"
OBJS=Engine/Transitions/BasicTransition.o Engine/Objects/Texture2D.o Engine/Objects/TMObjectWithPriority.o \
	Engine/Objects/TMFramedTexture.o Engine/Objects/TMAnimatable.o Engine/Objects/TMResource.o \
	Engine/TapMania.o Engine/InputEngine.o Engine/TMRunLoop.o Engine/SoundEffectsHolder.o \
	Engine/JoyPad.o Engine/SongsDirectoryCache.o Engine/TapManiaAppDelegate.o Engine/TexturesHolder.o Engine/EAGLView.o \
	Engine/ThemeSupport/ResourcesLoader.o Engine/ThemeSupport/ThemeMetrics.o Engine/ThemeSupport/ThemeManager.o \
	Renderers/AbstractRenderer.o Renderers/MainMenuRenderer.o Renderers/UIElements/LifeBar.o \
	Renderers/UIElements/MenuItem.o Renderers/UIElements/SongPickerMenuItem.o Renderers/UIElements/SongPickerMenuSelectedItem.o \
	Renderers/SongPlayRenderer.o Renderers/SongPickerMenuRenderer.o Renderers/SongResultsRenderer.o \
	Renderers/CreditsRenderer.o Renderers/OptionsMenuRenderer.o Renderers/SongsCacheLoaderRenderer.o \
	Renderers/UIElements/TogglerItem.o Renderers/UIElements/TapNote.o Renderers/UIElements/HoldNote.o Renderers/UIElements/Receptor.o \
	Renderers/UIElements/Judgement.o Renderers/UIElements/HoldJudgement.o \
	Renderers/UIElements/ReceptorRow.o GameObjects/TMSong.o GameObjects/TMSteps.o \
	GameObjects/TMSongOptions.o GameObjects/TMNote.o GameObjects/TMTrack.o GameObjects/TMChangeSegment.o \
	Engine/SoundEngine.o Parsers/DWIParser.o Util/TimingUtil.o Util/PhysicsUtil.o Util/BenchmarkUtil.o

all: app tar deploy 

deploy:
	scp tm.tar mobile@192.168.0.101:

tar:
	tar cf tm.tar TapMania.app


app: tapmania bin 

bin:
	$(LD) $(LDFLAGS) -v -o TapMania $(OBJS) main.o
	rm -rf TapMania.app
	mkdir TapMania.app
	cp Default.png TapMania.app/
	cp -R Data/* TapMania.app/
	cp *.plist TapMania.app/
	cp TapMania TapMania.app/

tapmania: $(OBJS) main.o 

%.o: %.m soundengine
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

soundengine:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) Engine/SoundEngine.cpp -o Engine/SoundEngine.o

clean:
	rm -f $(OBJS) main.o TapMania
	rm -rf TapMania.app
