#include "window_to_front_plugin.h"

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace window_to_front {

void WindowToFrontPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "window_to_front",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WindowToFrontPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WindowToFrontPlugin::WindowToFrontPlugin(
    flutter::PluginRegistrarWindows *registrar)
    : registrar_(registrar) {}

WindowToFrontPlugin::~WindowToFrontPlugin() {}

void WindowToFrontPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("activate") == 0) {
    HWND window = registrar_->GetView()->GetNativeWindow();
    HWND foreground_window = ::GetForegroundWindow();
    DWORD current_thread_id = ::GetCurrentThreadId();
    DWORD foreground_thread_id =
        ::GetWindowThreadProcessId(foreground_window, NULL);

    ::AttachThreadInput(foreground_thread_id, current_thread_id, TRUE);
    ::SetWindowPos(window, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
    ::SetWindowPos(window, HWND_NOTOPMOST, 0, 0, 0, 0,
                   SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
    ::SetForegroundWindow(window);
    ::SetFocus(window);
    ::SetActiveWindow(window);
    ::AttachThreadInput(foreground_thread_id, current_thread_id, FALSE);
    result->Success();
  } else {
    result->NotImplemented();
  }
}

}  // namespace window_to_front
