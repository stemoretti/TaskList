cmake_minimum_required(VERSION 3.19)

project(TaskList VERSION 0.1 LANGUAGES CXX)

include(GNUInstallDirs)

find_package(Qt6 COMPONENTS Core Gui Qml Quick QuickControls2 LinguistTools REQUIRED)

add_subdirectory(external/BaseUI)
add_subdirectory(external/objectlistmodel)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

qt_add_executable(tasklist
    src/main.cpp
    src/sortfiltermodel.cpp
    src/sortfiltermodel.h
    src/uniqueid.cpp
    src/uniqueid.h
)

if(ANDROID)
    set_property(TARGET tasklist APPEND PROPERTY
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    )
    set_property(TARGET tasklist APPEND PROPERTY
        QT_ANDROID_VERSION_CODE "${VERSION_CODE}"
    )
    set_property(TARGET tasklist APPEND PROPERTY
        QT_ANDROID_VERSION_NAME "${VERSION_NAME}"
    )
endif()

target_include_directories(tasklist PRIVATE "${CMAKE_SOURCE_DIR}/src")

target_compile_definitions(tasklist
    PRIVATE
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_compile_options(tasklist
    PRIVATE
        $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:GNU>>:
            -Wall
            -Wextra
            -Wpedantic
        >

        $<$<CXX_COMPILER_ID:MSVC>:
            /W4
        >
)

target_link_libraries(tasklist
    PRIVATE
        Qt::Core
        Qt::Gui
        Qt::Qml
        Qt::Quick
        Qt::QuickControls2
        objectlistmodel
        baseui
)

set(qml_files
    qml/DateTimeDialog.qml
    qml/InfoPage.qml
    qml/ListManagementPage.qml
    qml/ListPage.qml
    qml/main.qml
    qml/PopupConfirm.qml
    qml/ReorderDelegate.qml
    qml/ReorderListView.qml
    qml/SelectItemsBar.qml
    qml/SettingsContinentsPage.qml
    qml/SettingsCountriesPage.qml
    qml/SettingsPage.qml
    qml/Snackbar.qml
    qml/SortedListView.qml
    qml/TaskDetailsPage.qml
    qml/TextInputBar.qml
)

qt_add_translations(tasklist
    TS_FILES
        translations/tasklist_en.ts
        translations/tasklist_it.ts
    SOURCES
        ${qml_files}
    LUPDATE_OPTIONS
        -no-obsolete
)

qt_add_qml_module(tasklist
    URI TaskList
    VERSION 1.0
    QML_FILES
        ${qml_files}
    SOURCES
        src/appdata.cpp
        src/appdata.h
        src/list.cpp
        src/list.h
        src/settings.cpp
        src/settings.h
        src/system.cpp
        src/system.h
        src/task.cpp
        src/task.h
    RESOURCES
        qml/languages.js
    NO_RESOURCE_TARGET_PATH
)

set(QML_IMPORT_PATH "${CMAKE_SOURCE_DIR}/external/BaseUI/qml"
    CACHE STRING "Qt Creator extra qml import paths" FORCE
)

install(TARGETS tasklist
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    BUNDLE DESTINATION "."
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)
