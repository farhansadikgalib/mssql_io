cmake_minimum_required(VERSION 3.10)
project(mssql_io VERSION 0.0.3 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)

# Check if FreeTDS is available
set(USE_FREETDS ON)

# Try to find FreeTDS first
if(NOT ANDROID)
    find_path(FREETDS_CHECK sybdb.h
        PATHS /usr/include /usr/local/include /opt/homebrew/include /opt/local/include
    )
    if(NOT FREETDS_CHECK)
        set(USE_FREETDS OFF)
        message(WARNING "FreeTDS not found. Building stub implementation. Install FreeTDS for production use.")
    else()
        message(STATUS "Found FreeTDS headers at: ${FREETDS_CHECK}")
    endif()
endif()

# Source files
set(HEADERS mssql_native.h)

if(USE_FREETDS)
    set(SOURCES mssql_native.cpp)
else()
    set(SOURCES mssql_native_stub.cpp)
endif()

# Create library (shared for desktop, static for iOS/Android)
if(APPLE AND CMAKE_SYSTEM_NAME STREQUAL "iOS")
    add_library(mssql_io STATIC ${SOURCES} ${HEADERS})
elseif(ANDROID)
    add_library(mssql_io SHARED ${SOURCES} ${HEADERS})
else()
    add_library(mssql_io SHARED ${SOURCES} ${HEADERS})
endif()

# Link FreeTDS if available
if(USE_FREETDS)
    if(ANDROID)
        # Android: Use provided paths from Gradle or try to find in standard locations
        if(DEFINED FREETDS_INCLUDE_DIR AND DEFINED FREETDS_LIBRARY_DIR)
            message(STATUS "Using Android FreeTDS from: ${FREETDS_LIBRARY_DIR}")
            target_include_directories(mssql_io PRIVATE ${FREETDS_INCLUDE_DIR})
            target_link_directories(mssql_io PRIVATE ${FREETDS_LIBRARY_DIR})
            target_link_libraries(mssql_io PRIVATE sybdb)
        else()
            # Try to find FreeTDS in Android project structure
            find_path(FREETDS_INCLUDE_DIR sybdb.h
                PATHS
                ${CMAKE_CURRENT_SOURCE_DIR}/../android/src/main/cpp/freetds/include
                ${CMAKE_CURRENT_SOURCE_DIR}/../../android/src/main/cpp/freetds/include
                NO_DEFAULT_PATH
            )
            
            if(FREETDS_INCLUDE_DIR AND ANDROID_ABI)
                # Find library for current ABI
                find_library(FREETDS_LIBRARY
                    NAMES sybdb
                    PATHS
                    ${CMAKE_CURRENT_SOURCE_DIR}/../android/src/main/jniLibs/${ANDROID_ABI}
                    ${CMAKE_CURRENT_SOURCE_DIR}/../../android/src/main/jniLibs/${ANDROID_ABI}
                    NO_DEFAULT_PATH
                )
                
                if(FREETDS_LIBRARY)
                    message(STATUS "Found Android FreeTDS: ${FREETDS_LIBRARY}")
                    target_include_directories(mssql_io PRIVATE ${FREETDS_INCLUDE_DIR})
                    target_link_libraries(mssql_io PRIVATE ${FREETDS_LIBRARY})
                else()
                    message(WARNING "FreeTDS library not found for ${ANDROID_ABI}. Run android/build_freetds.sh first.")
                    set(USE_FREETDS OFF)
                endif()
            else()
                message(WARNING "FreeTDS not found for Android. Run android/build_freetds.sh first.")
                set(USE_FREETDS OFF)
            endif()
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
            message(WARNING "FreeTDS not found. Using stub implementation.")
            set(USE_FREETDS OFF)
        endif()
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

