cmake_minimum_required(VERSION 3.19)

project(ObjectListModel LANGUAGES CXX)

find_package(Qt6 COMPONENTS Core Qml REQUIRED)

set(CMAKE_AUTOMOC ON)

qt_add_library(objectlistmodel STATIC include/QQmlObjectListModel.h)

target_link_libraries(objectlistmodel PUBLIC Qt::Core Qt::Qml)

target_include_directories(objectlistmodel PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
)
