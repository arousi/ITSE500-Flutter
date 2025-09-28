#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <string>

#include "flutter_window.h"
#include "utils.h"
// For deep link dispatch to running instance
#include <protocol_handler_windows/protocol_handler_windows_plugin_c_api.h>

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Ensure we can load plugin DLLs from a dedicated subdirectory (plugins/) to keep
  // the root cleaner. We add that directory to the DLL search path before Flutter
  // initializes and registers plugins.
  {
    const wchar_t kPluginDir[] = L"plugins";
    // Prepare secure default DLL directory search behavior when available.
    HMODULE kernel32 = ::GetModuleHandleW(L"kernel32.dll");
    using SetDefaultDllDirectoriesFn = BOOL (WINAPI *)(DWORD);
    using AddDllDirectoryFn = DLL_DIRECTORY_COOKIE (WINAPI *)(PCWSTR);
    auto set_default = reinterpret_cast<SetDefaultDllDirectoriesFn>(
        ::GetProcAddress(kernel32, "SetDefaultDllDirectories"));
    auto add_dir = reinterpret_cast<AddDllDirectoryFn>(
        ::GetProcAddress(kernel32, "AddDllDirectory"));
    // LOAD_LIBRARY_SEARCH_DEFAULT_DIRS (0x00001000) | LOAD_LIBRARY_SEARCH_USER_DIRS (0x00000400)
    const DWORD kSecureFlags = 0x00001000 | 0x00000400;
    if (set_default) {
      set_default(kSecureFlags);
    }
    if (add_dir) {
      if (!add_dir(kPluginDir)) {
        // Fallback: prepend plugins to PATH if AddDllDirectory fails.
        wchar_t existing[32768];
        DWORD len = ::GetEnvironmentVariableW(L"PATH", existing, 32768);
        if (len > 0 && len < 32760) {
          std::wstring new_path = kPluginDir; // relative directory
          new_path.append(L";").append(existing);
          ::SetEnvironmentVariableW(L"PATH", new_path.c_str());
        }
      }
    } else {
      // Legacy OS: modify PATH directly.
      wchar_t existing[32768];
      DWORD len = ::GetEnvironmentVariableW(L"PATH", existing, 32768);
      if (len > 0 && len < 32760) {
        std::wstring new_path = kPluginDir; // relative directory
        new_path.append(L";").append(existing);
        ::SetEnvironmentVariableW(L"PATH", new_path.c_str());
      }
    }
  }
  // If an instance is already running, dispatch to it and exit.
  HWND existing = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"flutter_app_itse500");
  if (existing != NULL) {
    DispatchToProtocolHandler(existing);
    ::ShowWindow(existing, SW_NORMAL);
    ::SetForegroundWindow(existing);
    return EXIT_FAILURE;
  }
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"flutter_app_itse500", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
