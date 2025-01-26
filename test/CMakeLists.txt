cmake_minimum_required(VERSION 3.25)
project(Marksman LANGUAGES CXX VERSION ${CONAN_VERSION})

set(HEADERS
)
set(SOURCE
  source/main.cc
)

add_executable(${PROJECT_NAME}
  ${HEADERS}
  ${SOURCE}
)

