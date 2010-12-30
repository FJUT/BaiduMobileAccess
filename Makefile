
IP=172.23.249.56
PROJECTNAME=BaiduMobileAccess
APPFOLDER=$(PROJECTNAME).app
MINIMUMVERSION:=3.0

CC = arm-apple-darwin9-gcc
CPP:=arm-apple-darwin9-g++
LD=$(CC)
SDK = /root/iphone/toolchain/sdks/iPhoneOS3.1.2.sdk

LDFLAGS = -arch arm -lobjc
LDFLAGS += -framework CoreFoundation 
LDFLAGS += -framework Foundation 
LDFLAGS += -framework UIKit 
LDFLAGS += -framework CoreGraphics
//LDFLAGS += -framework AddressBookUI
//LDFLAGS += -framework AddressBook
//LDFLAGS += -framework QuartzCore
//LDFLAGS += -framework GraphicsServices
//LDFLAGS += -framework CoreSurface
//LDFLAGS += -framework CoreAudio
//LDFLAGS += -framework Celestial
//LDFLAGS += -framework AudioToolbox
//LDFLAGS += -framework WebCore
//LDFLAGS += -framework WebKit
//LDFLAGS += -framework SystemConfiguration
LDFLAGS += -framework CFNetwork
//LDFLAGS += -framework MediaPlayer
//LDFLAGS += -framework OpenGLES
//LDFLAGS += -framework OpenAL
#LDFLAGS += -L"$(SDK)/usr/lib"
#LDFLAGS += -F"$(SDK)/System/Library/Frameworks"
#LDFLAGS += -F"$(SDK)/System/Library/PrivateFrameworks"
//LDFLAGS += -bind_at_load
//LDFLAGS += -multiply_defined suppress
LDFLAGS += -march=armv6
LDFLAGS += -mcpu=arm1176jzf-s 
//LDFLAGS += -mmacosx-version-min=10.5
//LDFLAGS += -dynamiclib
LDFLAGS += -licucore
LDFLAGS += -I./include
LDFLAGS += -L./lib 
LDFLAGS += -lssl -lcrypto -lcurl -lz

#LDFLAGS += -lcrypto
#LDFLAGS += -lz


//CFLAGS += -I"$(SDK)/usr/include" 
CFLAGS += -std=gnu99 -O0
CFLAGS += -Diphoneos_version_min=$(MINIMUMVERSION)
CFLAGS += -Wno-attributes -Wno-trigraphs -Wreturn-type -Wunused-variable

CPPFLAGS=$CFLAGS

SRCDIR=./Classes
RESDIR=./Resources
OBJS=$(patsubst %.m,%.o,$(wildcard $(SRCDIR)/*.m))
OBJS+=$(patsubst %.c,%.o,$(wildcard $(SRCDIR)/*.c))
OBJS+=$(patsubst %.mm,%.o,$(wildcard $(SRCDIR)/*.mm))
OBJS+=$(patsubst %.cpp,%.o,$(wildcard $(SRCDIR)/*.cpp))
OBJS+=$(patsubst %.m,%.o,$(wildcard ./*.m))

CFLAGS += $(addprefix -I,$(SRCDIR))

CPPFLAGS=$CFLAGS

all:	$(PROJECTNAME) bundle

$(PROJECTNAME):	$(OBJS) Makefile
	$(LD) $(LDFLAGS) $(filter %.o,$^) -o $@ 

%.o:	%.m %.h$(filter-out $(patsubst %.o,%.h,$(OBJS)), $(wildcard $(SRCDIR)/*.h))
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.m
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.c %.h
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.mm %.h $(filter-out $(patsubst %.o,%.h,$(OBJS)), $(wildcard $(SRCDIR)/*.h))
	$(CPP) -c $(CPPFLAGS) $< -o $@

%.o:	%.cpp %.h 
	$(CPP) -c $(CPPFLAGS) $< -o $@

clean:
	@rm -f *.o
	@rm -f $(SRCDIR)/*.o
	@rm -Rf $(APPFOLDER)
	@rm -Rf $(PROJECTNAME)

bundle: $(PROJECTNAME)
	@mkdir -p $(APPFOLDER)
	@cp $(PROJECTNAME) $(APPFOLDER)
	@cp ${RESDIR}/* $(APPFOLDER)
	@cp Info.plist $(APPFOLDER)
	@ldid -S $(APPFOLDER)/$(PROJECTNAME) &> /dev/null

install:
	@ssh root@$(IP) "cd /Applications/BaiduMobileAccess.app && rm -R * || echo 'not found' "
	@scp -rp $(APPFOLDER) root@$(IP):/Applications
	#@ssh root@192.168.1.10 "cd /Applications/BaiduMobileAccess.app ; ldid -S BaiduMobileAccess_; killall SpringBoard"

