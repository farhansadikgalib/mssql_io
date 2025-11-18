cmake_minimum_required(VERSION 3.10)
project(mssql_io VERSION 3.0.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)

# Source files
set(SOURCES
    mssql_native.cpp
)

set(HEADERS
    mssql_native.h
)

# Create shared library
add_library(mssql_io SHARED ${SOURCES} ${HEADERS})

# Find FreeTDS
if(ANDROID)
    # Android: Use provided paths from Gradle
    if(DEFINED FREETDS_INCLUDE_DIR AND DEFINED FREETDS_LIBRARY_DIR)
        message(STATUS "Using Android FreeTDS from: ${FREETDS_LIBRARY_DIR}")
        target_include_directories(mssql_io PRIVATE ${FREETDS_INCLUDE_DIR})
        target_link_directories(mssql_io PRIVATE ${FREETDS_LIBRARY_DIR})
        target_link_libraries(mssql_io PRIVATE sybdb)
    else()
        message(WARNING "FreeTDS paths not provided for Android. Run android/build_freetds.sh first")
    endif()
else()
    # Desktop platforms: Find system FreeTDS
    find_path(FREETDS_INCLUDE_DIR sybdb.h
        PATHS
        /usr/include
        /usr/local/include
        /opt/homebrew/include
        /opt/local/include
        $ENV{FREETDS_HOME}/include
    )

    find_library(FREETDS_LIBRARY
        NAMES sybdb libsybdb
        PATHS
        /usr/lib
        /usr/local/lib
        /opt/homebrew/lib
        /opt/local/lib
        $ENV{FREETDS_HOME}/lib
    )

    if(FREETDS_INCLUDE_DIR AND FREETDS_LIBRARY)
        message(STATUS "Found FreeTDS: ${FREETDS_LIBRARY}")
        target_include_directories(mssql_io PRIVATE ${FREETDS_INCLUDE_DIR})
        target_link_libraries(mssql_io PRIVATE ${FREETDS_LIBRARY})
    else()
        message(WARNING "FreeTDS not found. Please install FreeTDS or set FREETDS_HOME environment variable")
    endif()
endif()

# Platform-specific settings
if(WIN32)
    target_compile_definitions(mssql_io PRIVATE WIN32_LEAN_AND_MEAN)
    target_link_libraries(mssql_io PRIVATE ws2_32)
elseif(APPLE)
    set_target_properties(mssql_io PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        MACOSX_FRAMEWORK_IDENTIFIER com.mssql.io
        VERSION ${PROJECT_VERSION}
        SOVERSION 3
        PUBLIC_HEADER "${HEADERS}"
    )
elseif(UNIX)
    target_link_libraries(mssql_io PRIVATE pthread dl)
endif()

# Export symbols
set_target_properties(mssql_io PROPERTIES
    C_VISIBILITY_PRESET hidden
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
)

# Install targets
install(TARGETS mssql_io
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    FRAMEWORK DESTINATION lib
    PUBLIC_HEADER DESTINATION include
)

