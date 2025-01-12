# Copyright (c) 2016 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#FIXME:(gongwb) Move brpc's gtest dependency.
IF(WITH_TESTING OR (WITH_DISTRIBUTE AND NOT WITH_GRPC))
    IF(WITH_TESTING)
        ENABLE_TESTING()
    ENDIF(WITH_TESTING)

    INCLUDE(ExternalProject)

    SET(GTEST_SOURCES_DIR ${THIRD_PARTY_PATH}/gtest)
    SET(GTEST_INSTALL_DIR ${THIRD_PARTY_PATH}/install/gtest)
    SET(GTEST_INCLUDE_DIR "${GTEST_INSTALL_DIR}/include" CACHE PATH "gtest include directory." FORCE)

    INCLUDE_DIRECTORIES(${GTEST_INCLUDE_DIR})

    IF(WIN32)
        set(GTEST_LIBRARIES
            "${GTEST_INSTALL_DIR}/lib/gtest.lib" CACHE FILEPATH "gtest libraries." FORCE)
        set(GTEST_MAIN_LIBRARIES
            "${GTEST_INSTALL_DIR}/lib/gtest_main.lib" CACHE FILEPATH "gtest main libraries." FORCE)
    ELSE(WIN32)
        set(GTEST_LIBRARIES
            "${GTEST_INSTALL_DIR}/lib/libgtest.a" CACHE FILEPATH "gtest libraries." FORCE)
        set(GTEST_MAIN_LIBRARIES
            "${GTEST_INSTALL_DIR}/lib/libgtest_main.a" CACHE FILEPATH "gtest main libraries." FORCE)
    ENDIF(WIN32)

    IF(WITH_MKLML)
        # wait for mklml downloading completed
        SET(GTEST_DEPENDS   ${MKLML_PROJECT})
    ENDIF()

    SET(OPTIONAL_ARGS "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
        "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
        "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}"
        "-DCMAKE_CXX_FLAGS_RELEASE=${CMAKE_CXX_FLAGS_RELEASE}"
        "-DCMAKE_CXX_FLAGS_DEBUG=${CMAKE_CXX_FLAGS_DEBUG}"
        "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}"
        "-DCMAKE_C_FLAGS_DEBUG=${CMAKE_C_FLAGS_DEBUG}"
        "-DCMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}")

    ExternalProject_Add(
        extern_gtest
        ${EXTERNAL_PROJECT_LOG_ARGS}
        DEPENDS         ${GTEST_DEPENDS}
        GIT_REPOSITORY  "https://github.com/google/googletest.git"
        GIT_TAG         "release-1.8.0"
        PREFIX          ${GTEST_SOURCES_DIR}
        UPDATE_COMMAND  ""
        CMAKE_ARGS      ${CROSS_COMPILE_CMAKE_ARGS}
                        ${OPTIONAL_ARGS}
                        -DCMAKE_INSTALL_PREFIX=${GTEST_INSTALL_DIR}
                        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                        -DBUILD_GMOCK=ON
                        -Dgtest_disable_pthreads=ON
                        -Dgtest_force_shared_crt=ON
                        -DCMAKE_BUILD_TYPE=${THIRD_PARTY_BUILD_TYPE}
                        ${EXTERNAL_OPTIONAL_ARGS}
        CMAKE_CACHE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${GTEST_INSTALL_DIR}
                         -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
                         -DCMAKE_BUILD_TYPE:STRING=${THIRD_PARTY_BUILD_TYPE}
    )

    ADD_LIBRARY(gtest STATIC IMPORTED GLOBAL)
    SET_PROPERTY(TARGET gtest PROPERTY IMPORTED_LOCATION ${GTEST_LIBRARIES})
    ADD_DEPENDENCIES(gtest extern_gtest)

    ADD_LIBRARY(gtest_main STATIC IMPORTED GLOBAL)
    SET_PROPERTY(TARGET gtest_main PROPERTY IMPORTED_LOCATION ${GTEST_MAIN_LIBRARIES})
    ADD_DEPENDENCIES(gtest_main extern_gtest)

ENDIF(WITH_TESTING OR (WITH_DISTRIBUTE AND NOT WITH_GRPC))
