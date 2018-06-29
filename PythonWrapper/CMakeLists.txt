CMAKE_MINIMUM_REQUIRED(VERSION 3.0)

project(cpd_python_wrapper)

string(REGEX REPLACE "\\\\" "/" CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX} CACHE FILEPATH "Path prefix of common installation.")

find_program(PYTHON_EXECUTABLE "python" HINTS "${CMAKE_INSTALL_PREFIX}/..")

find_package(Cpd REQUIRED)

if (PYTHON_EXECUTABLE)
    set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
    set(SETUP_PY_MID "${CMAKE_CURRENT_BINARY_DIR}/setup.py.mid")
    set(SETUP_PY    "${CMAKE_CURRENT_BINARY_DIR}/setup.py")
    set(DEPS        "${CMAKE_CURRENT_SOURCE_DIR}/module/__init__.py")
    set(OUTPUT      "${CMAKE_CURRENT_BINARY_DIR}/build/timestamp")

    # wrapper has same dependencies as geometry_common_cpd
    get_target_property(CPD_INCLUDE_DIRECTORIES NoClick::geometry_common_cpd INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(CPD_DEPS NoClick::geometry_common_cpd INTERFACE_LINK_LIBRARIES)

    set(CPD_DEPS ${CPD_DEPS} Cpd::Library-C++)

    # resolve targets vs. libraries 
    # todo: might be necessary to have that recursively
    foreach(TGT IN LISTS CPD_DEPS)
        if(TARGET ${TGT})
            set(TNAME "$<TARGET_LINKER_FILE:${TGT}>")
            #get_target_property(TNAME ${TGT} LOCATION)
            #get_target_property(TNAME ${TGT} IMPORT_LOCATION)

            get_target_property(TINC ${TGT} INTERFACE_INCLUDE_DIRECTORIES)
            get_target_property(TTYPE ${TGT} TYPE)
            message(STATUS "${TGT} ${TTYPE} ${TNAME} ${TINC}")
            IF(TNAME AND ${TTYPE} STREQUAL "SHARED_LIBRARY")
                LIST(APPEND CPD_LIBRARIES ${TNAME})
            ENDIF()
            IF(TINC)
                LIST(APPEND CPD_INCLUDE_DIRECTORIES ${TINC})
            ENDIF()
        ELSE()
            message(STATUS "${TGT}")
            LIST(APPEND CPD_LIBRARIES ${TGT})
        ENDIF()
    endforeach()

    list(REMOVE_DUPLICATES CPD_INCLUDE_DIRECTORIES)

    list(REMOVE_DUPLICATES CPD_LIBRARIES)

    # configure the intermediate setup.py.mid with 
    configure_file(${SETUP_PY_IN} ${SETUP_PY_MID})
    file(GENERATE OUTPUT ${SETUP_PY} INPUT ${SETUP_PY_MID}
        CONDITION $<CONFIG:RelWithDebInfo>)

    add_custom_command(OUTPUT ${OUTPUT}
                       COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} build_ext
                       COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}
                       DEPENDS ${DEPS})

    add_custom_target(PythonWrapper ALL DEPENDS ${OUTPUT})

    install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} install --single-version-externally-managed --record record.txt)")
endif()