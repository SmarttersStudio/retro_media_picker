#import "RetroMediaPickerPlugin.h"
#if __has_include(<retro_media_picker/retro_media_picker-Swift.h>)
#import <retro_media_picker/retro_media_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "retro_media_picker-Swift.h"
#endif

@implementation RetroMediaPickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRetroMediaPickerPlugin registerWithRegistrar:registrar];
}
@end
