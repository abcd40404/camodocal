# Ceres Solver - A fast non-linear least squares minimizer
# Copyright 2015 Google Inc. All rights reserved.
# http://ceres-solver.org/
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Google Inc. nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Author: alexs.mac@gmail.com (Alex Stewart)
#

# FindGflags.cmake - Find Google gflags logging library.
#
# This module will attempt to find gflags, either via an exported CMake
# configuration (generated by gflags >= 2.1 which are built with CMake), or
# by performing a standard search for all gflags components.  The order of
# precedence for these two methods of finding gflags is controlled by:
# GFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION.
#
# This module defines the following variables:
#
# GFLAGS_FOUND: TRUE iff gflags is found.
# GFLAGS_INCLUDE_DIRS: Include directories for gflags.
# GFLAGS_LIBRARIES: Libraries required to link gflags.
# GFLAGS_NAMESPACE: The namespace in which gflags is defined.  In versions of
#                   gflags < 2.1, this was google, for versions >= 2.1 it is
#                   by default gflags, although can be configured when building
#                   gflags to be something else (i.e. google for legacy
#                   compatibility).
# FOUND_INSTALLED_GFLAGS_CMAKE_CONFIGURATION: True iff the version of gflags
#                                             found was built & installed /
#                                             exported as a CMake package.
#
# The following variables control the behaviour of this module when an exported
# gflags CMake configuration is not found.
#
# GFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION: TRUE/FALSE, iff TRUE then
#                           then prefer using an exported CMake configuration
#                           generated by gflags >= 2.1 over searching for the
#                           gflags components manually.  Otherwise (FALSE)
#                           ignore any exported gflags CMake configurations and
#                           always perform a manual search for the components.
#                           Default: TRUE iff user does not define this variable
#                           before we are called, and does NOT specify either
#                           GFLAGS_INCLUDE_DIR_HINTS or GFLAGS_LIBRARY_DIR_HINTS
#                           otherwise FALSE.
# GFLAGS_INCLUDE_DIR_HINTS: List of additional directories in which to
#                           search for gflags includes, e.g: /timbuktu/include.
# GFLAGS_LIBRARY_DIR_HINTS: List of additional directories in which to
#                           search for gflags libraries, e.g: /timbuktu/lib.
#
# The following variables are also defined by this module, but in line with
# CMake recommended FindPackage() module style should NOT be referenced directly
# by callers (use the plural variables detailed above instead).  These variables
# do however affect the behaviour of the module via FIND_[PATH/LIBRARY]() which
# are NOT re-called (i.e. search for library is not repeated) if these variables
# are set with valid values _in the CMake cache_. This means that if these
# variables are set directly in the cache, either by the user in the CMake GUI,
# or by the user passing -DVAR=VALUE directives to CMake when called (which
# explicitly defines a cache variable), then they will be used verbatim,
# bypassing the HINTS variables and other hard-coded search locations.
#
# GFLAGS_INCLUDE_DIR: Include directory for gflags, not including the
#                     include directory of any dependencies.
# GFLAGS_LIBRARY: gflags library, not including the libraries of any
#                 dependencies.

# Reset CALLERS_CMAKE_FIND_LIBRARY_PREFIXES to its value when FindGflags was
# invoked, necessary for MSVC.
macro(GFLAGS_RESET_FIND_LIBRARY_PREFIX)
  if (MSVC AND CALLERS_CMAKE_FIND_LIBRARY_PREFIXES)
    set(CMAKE_FIND_LIBRARY_PREFIXES "${CALLERS_CMAKE_FIND_LIBRARY_PREFIXES}")
  endif()
endmacro(GFLAGS_RESET_FIND_LIBRARY_PREFIX)

# Called if we failed to find gflags or any of it's required dependencies,
# unsets all public (designed to be used externally) variables and reports
# error message at priority depending upon [REQUIRED/QUIET/<NONE>] argument.
macro(GFLAGS_REPORT_NOT_FOUND REASON_MSG)
  unset(GFLAGS_FOUND)
  unset(GFLAGS_INCLUDE_DIRS)
  unset(GFLAGS_LIBRARIES)
  # Do not use unset, as we want to keep GFLAGS_NAMESPACE in the cache,
  # but simply clear its value.
  set(GFLAGS_NAMESPACE "" CACHE STRING
    "gflags namespace (google or gflags)" FORCE)

  # Make results of search visible in the CMake GUI if gflags has not
  # been found so that user does not have to toggle to advanced view.
  mark_as_advanced(CLEAR GFLAGS_INCLUDE_DIR
                         GFLAGS_LIBRARY
                         GFLAGS_NAMESPACE)

  gflags_reset_find_library_prefix()

  # Note <package>_FIND_[REQUIRED/QUIETLY] variables defined by FindPackage()
  # use the camelcase library name, not uppercase.
  if (Gflags_FIND_QUIETLY)
    message(STATUS "Failed to find gflags - " ${REASON_MSG} ${ARGN})
  elseif (Gflags_FIND_REQUIRED)
    message(FATAL_ERROR "Failed to find gflags - " ${REASON_MSG} ${ARGN})
  else()
    # Neither QUIETLY nor REQUIRED, use no priority which emits a message
    # but continues configuration and allows generation.
    message("-- Failed to find gflags - " ${REASON_MSG} ${ARGN})
  endif ()
  return()
endmacro(GFLAGS_REPORT_NOT_FOUND)

# Verify that all variable names passed as arguments are defined (can be empty
# but must be defined) or raise a fatal error.
macro(GFLAGS_CHECK_VARS_DEFINED)
  foreach(CHECK_VAR ${ARGN})
    if (NOT DEFINED ${CHECK_VAR})
      message(FATAL_ERROR "Ceres Bug: ${CHECK_VAR} is not defined.")
    endif()
  endforeach()
endmacro(GFLAGS_CHECK_VARS_DEFINED)

# Use check_cxx_source_compiles() to compile trivial test programs to determine
# the gflags namespace.  This works on all OSs except Windows.  If using Visual
# Studio, it fails because msbuild forces check_cxx_source_compiles() to use
# CMAKE_BUILD_TYPE=Debug for the test project, which usually breaks detection
# because MSVC requires that the test project use the same build type as gflags,
# which would normally be built in Release.
#
# Defines: GFLAGS_NAMESPACE in the caller's scope with the detected namespace,
#          which is blank (empty string, will test FALSE is CMake conditionals)
#          if detection failed.
function(GFLAGS_CHECK_GFLAGS_NAMESPACE_USING_TRY_COMPILE)
  # Verify that all required variables are defined.
  gflags_check_vars_defined(
    GFLAGS_INCLUDE_DIR GFLAGS_LIBRARY)
  # Ensure that GFLAGS_NAMESPACE is always unset on completion unless
  # we explicitly set if after having the correct namespace.
  set(GFLAGS_NAMESPACE "" PARENT_SCOPE)

  include(CheckCXXSourceCompiles)
  # Setup include path & link library for gflags for CHECK_CXX_SOURCE_COMPILES.
  set(CMAKE_REQUIRED_INCLUDES ${GFLAGS_INCLUDE_DIR})
  set(CMAKE_REQUIRED_LIBRARIES ${GFLAGS_LIBRARY} ${GFLAGS_LINK_LIBRARIES})
  # First try the (older) google namespace.  Note that the output variable
  # MUST be unique to the build type as otherwise the test is not repeated as
  # it is assumed to have already been performed.
  check_cxx_source_compiles(
    "#include <gflags/gflags.h>
     int main(int argc, char * argv[]) {
       google::ParseCommandLineFlags(&argc, &argv, true);
       return 0;
     }"
     GFLAGS_IN_GOOGLE_NAMESPACE)
  if (GFLAGS_IN_GOOGLE_NAMESPACE)
    set(GFLAGS_NAMESPACE google PARENT_SCOPE)
    return()
  endif()

  # Try (newer) gflags namespace instead.  Note that the output variable
  # MUST be unique to the build type as otherwise the test is not repeated as
  # it is assumed to have already been performed.
  set(CMAKE_REQUIRED_INCLUDES ${GFLAGS_INCLUDE_DIR})
  set(CMAKE_REQUIRED_LIBRARIES ${GFLAGS_LIBRARY} ${GFLAGS_LINK_LIBRARIES})
  check_cxx_source_compiles(
    "#include <gflags/gflags.h>
     int main(int argc, char * argv[]) {
        gflags::ParseCommandLineFlags(&argc, &argv, true);
        return 0;
     }"
     GFLAGS_IN_GFLAGS_NAMESPACE)
  if (GFLAGS_IN_GFLAGS_NAMESPACE)
    set(GFLAGS_NAMESPACE gflags PARENT_SCOPE)
    return()
  endif (GFLAGS_IN_GFLAGS_NAMESPACE)
endfunction(GFLAGS_CHECK_GFLAGS_NAMESPACE_USING_TRY_COMPILE)

# Use regex on the gflags headers to attempt to determine the gflags namespace.
# Checks both gflags.h (contained namespace on versions < 2.1.2) and
# gflags_declare.h, which contains the namespace on versions >= 2.1.2.
# In general, this method should only be used when
# GFLAGS_CHECK_GFLAGS_NAMESPACE_USING_TRY_COMPILE() cannot be used, or has
# failed.
#
# Defines: GFLAGS_NAMESPACE in the caller's scope with the detected namespace,
#          which is blank (empty string, will test FALSE is CMake conditionals)
#          if detection failed.
function(GFLAGS_CHECK_GFLAGS_NAMESPACE_USING_REGEX)
  # Verify that all required variables are defined.
  gflags_check_vars_defined(GFLAGS_INCLUDE_DIR)
  # Ensure that GFLAGS_NAMESPACE is always undefined on completion unless
  # we explicitly set if after having the correct namespace.
  set(GFLAGS_NAMESPACE "" PARENT_SCOPE)

  # Scan gflags.h to identify what namespace gflags was built with.  On
  # versions of gflags < 2.1.2, gflags.h was configured with the namespace
  # directly, on >= 2.1.2, gflags.h uses the GFLAGS_NAMESPACE #define which
  # is defined in gflags_declare.h, we try each location in turn.
  set(GFLAGS_HEADER_FILE ${GFLAGS_INCLUDE_DIR}/gflags/gflags.h)
  if (NOT EXISTS ${GFLAGS_HEADER_FILE})
    gflags_report_not_found(
      "Could not find file: ${GFLAGS_HEADER_FILE} "
      "containing namespace information in gflags install located at: "
      "${GFLAGS_INCLUDE_DIR}.")
  endif()
  file(READ ${GFLAGS_HEADER_FILE} GFLAGS_HEADER_FILE_CONTENTS)

  string(REGEX MATCH "namespace [A-Za-z]+"
    GFLAGS_NAMESPACE "${GFLAGS_HEADER_FILE_CONTENTS}")
  string(REGEX REPLACE "namespace ([A-Za-z]+)" "\\1"
    GFLAGS_NAMESPACE "${GFLAGS_NAMESPACE}")

  if (NOT GFLAGS_NAMESPACE)
    gflags_report_not_found(
      "Failed to extract gflags namespace from header file: "
      "${GFLAGS_HEADER_FILE}.")
  endif (NOT GFLAGS_NAMESPACE)

  if (GFLAGS_NAMESPACE STREQUAL "google" OR
      GFLAGS_NAMESPACE STREQUAL "gflags")
    # Found valid gflags namespace from gflags.h.
    set(GFLAGS_NAMESPACE "${GFLAGS_NAMESPACE}" PARENT_SCOPE)
    return()
  endif()

  # Failed to find gflags namespace from gflags.h, gflags is likely a new
  # version, check gflags_declare.h, which in newer versions (>= 2.1.2) contains
  # the GFLAGS_NAMESPACE #define, which is then referenced in gflags.h.
  set(GFLAGS_DECLARE_FILE ${GFLAGS_INCLUDE_DIR}/gflags/gflags_declare.h)
  if (NOT EXISTS ${GFLAGS_DECLARE_FILE})
    gflags_report_not_found(
      "Could not find file: ${GFLAGS_DECLARE_FILE} "
      "containing namespace information in gflags install located at: "
      "${GFLAGS_INCLUDE_DIR}.")
  endif()
  file(READ ${GFLAGS_DECLARE_FILE} GFLAGS_DECLARE_FILE_CONTENTS)

  string(REGEX MATCH "#define GFLAGS_NAMESPACE [A-Za-z]+"
    GFLAGS_NAMESPACE "${GFLAGS_DECLARE_FILE_CONTENTS}")
  string(REGEX REPLACE "#define GFLAGS_NAMESPACE ([A-Za-z]+)" "\\1"
    GFLAGS_NAMESPACE "${GFLAGS_NAMESPACE}")

  if (NOT GFLAGS_NAMESPACE)
    gflags_report_not_found(
      "Failed to extract gflags namespace from declare file: "
      "${GFLAGS_DECLARE_FILE}.")
  endif (NOT GFLAGS_NAMESPACE)

  if (GFLAGS_NAMESPACE STREQUAL "google" OR
      GFLAGS_NAMESPACE STREQUAL "gflags")
    # Found valid gflags namespace from gflags.h.
    set(GFLAGS_NAMESPACE "${GFLAGS_NAMESPACE}" PARENT_SCOPE)
    return()
  endif()
endfunction(GFLAGS_CHECK_GFLAGS_NAMESPACE_USING_REGEX)

# Protect against any alternative find_package scripts for this library having
# been called previously (in a client project) which set GFLAGS_FOUND, but not
# the other variables we require / set here which could cause the search logic
# here to fail.
unset(GFLAGS_FOUND)

# -----------------------------------------------------------------
# By default, if the user has expressed no preference for using an exported
# gflags CMake configuration over performing a search for the installed
# components, and has not specified any hints for the search locations, then
# prefer a gflags exported configuration if available.
if (NOT DEFINED GFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION
    AND NOT GFLAGS_INCLUDE_DIR_HINTS
    AND NOT GFLAGS_LIBRARY_DIR_HINTS)
  message(STATUS "No preference for use of exported gflags CMake configuration "
    "set, and no hints for include/library directories provided. "
    "Defaulting to preferring an installed/exported gflags CMake configuration "
    "if available.")
  set(GFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION TRUE)
endif()

if (GFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION)
  message(STATUS "IF2")
  # Try to find an exported CMake configuration for gflags, as generated by
  # gflags versions >= 2.1.
  #
  # We search twice, s/t we can invert the ordering of precedence used by
  # find_package() for exported package build directories, and installed
  # packages (found via CMAKE_SYSTEM_PREFIX_PATH), listed as items 6) and 7)
  # respectively in [1].
  #
  # By default, exported build directories are (in theory) detected first, and
  # this is usually the case on Windows.  However, on OS X & Linux, the install
  # path (/usr/local) is typically present in the PATH environment variable
  # which is checked in item 4) in [1] (i.e. before both of the above, unless
  # NO_SYSTEM_ENVIRONMENT_PATH is passed).  As such on those OSs installed
  # packages are usually detected in preference to exported package build
  # directories.
  #
  # To ensure a more consistent response across all OSs, and as users usually
  # want to prefer an installed version of a package over a locally built one
  # where both exist (esp. as the exported build directory might be removed
  # after installation), we first search with NO_CMAKE_PACKAGE_REGISTRY which
  # means any build directories exported by the user are ignored, and thus
  # installed directories are preferred.  If this fails to find the package
  # we then research again, but without NO_CMAKE_PACKAGE_REGISTRY, so any
  # exported build directories will now be detected.
  #
  # To prevent confusion on Windows, we also pass NO_CMAKE_BUILDS_PATH (which
  # is item 5) in [1]), to not preferentially use projects that were built
  # recently with the CMake GUI to ensure that we always prefer an installed
  # version if available.
  #
  # [1] http://www.cmake.org/cmake/help/v2.8.11/cmake.html#command:find_package
  find_package(gflags QUIET
                      NO_MODULE
                      NO_CMAKE_PACKAGE_REGISTRY
                      NO_CMAKE_BUILDS_PATH)
  if (gflags_FOUND)
    message(STATUS "Found installed version of gflags: ${gflags_DIR}")
  else(gflags_FOUND)
    # Failed to find an installed version of gflags, repeat search allowing
    # exported build directories.
    message(STATUS "Failed to find installed gflags CMake configuration, "
      "searching for gflags build directories exported with CMake.")
    # Again pass NO_CMAKE_BUILDS_PATH, as we know that gflags is exported and
    # do not want to treat projects built with the CMake GUI preferentially.
    find_package(gflags QUIET
                        NO_MODULE
                        NO_CMAKE_BUILDS_PATH)
    if (gflags_FOUND)
      message(STATUS "Found exported gflags build directory: ${gflags_DIR}")
    endif(gflags_FOUND)
  endif(gflags_FOUND)

  set(FOUND_INSTALLED_GFLAGS_CMAKE_CONFIGURATION ${gflags_FOUND})

  # gflags v2.1 - 2.1.2 shipped with a bug in their gflags-config.cmake [1]
  # whereby gflags_LIBRARIES = "gflags", but there was no imported target
  # called "gflags", they were called: gflags[_nothreads]-[static/shared].
  # As this causes linker errors when gflags is not installed in a location
  # on the current library paths, detect if this problem is present and
  # fix it.
  #
  # [1] https://github.com/gflags/gflags/issues/110
  if (gflags_FOUND)
    # NOTE: This is not written as additional conditions in the outer
    #       if (gflags_FOUND) as the NOT TARGET "${gflags_LIBRARIES}"
    #       condition causes problems if gflags is not found.
    if (${gflags_VERSION} VERSION_LESS 2.1.3 AND
        NOT TARGET "${gflags_LIBRARIES}")
      message(STATUS "Detected broken gflags install in: ${gflags_DIR}, "
        "version: ${gflags_VERSION} <= 2.1.2 which defines gflags_LIBRARIES = "
        "${gflags_LIBRARIES} which is not an imported CMake target, see: "
        "https://github.com/gflags/gflags/issues/110.  Attempting to fix by "
        "detecting correct gflags target.")
      # Ordering here expresses preference for detection, specifically we do not
      # want to use the _nothreads variants if the full library is available.
      list(APPEND CHECK_GFLAGS_IMPORTED_TARGET_NAMES
        gflags-shared gflags-static
        gflags_nothreads-shared gflags_nothreads-static)
      foreach(CHECK_GFLAGS_TARGET ${CHECK_GFLAGS_IMPORTED_TARGET_NAMES})
        if (TARGET ${CHECK_GFLAGS_TARGET})
          message(STATUS "Found valid gflags target: ${CHECK_GFLAGS_TARGET}, "
            "updating gflags_LIBRARIES.")
          set(gflags_LIBRARIES ${CHECK_GFLAGS_TARGET})
          break()
        endif()
      endforeach()
      if (NOT TARGET ${gflags_LIBRARIES})
        message(STATUS "Failed to fix detected broken gflags install in: "
          "${gflags_DIR}, version: ${gflags_VERSION} <= 2.1.2, none of the "
          "imported targets for gflags: ${CHECK_GFLAGS_IMPORTED_TARGET_NAMES} "
          "are defined.  Will continue with a manual search for gflags "
          "components.  We recommend you build/install a version of gflags > "
          "2.1.2 (or master).")
        set(FOUND_INSTALLED_GFLAGS_CMAKE_CONFIGURATION FALSE)
      endif()
    endif()
  endif()

  if (FOUND_INSTALLED_GFLAGS_CMAKE_CONFIGURATION)
    message(STATUS "Detected gflags version: ${gflags_VERSION}")
    set(GFLAGS_FOUND ${gflags_FOUND})
    set(GFLAGS_INCLUDE_DIR ${gflags_INCLUDE_DIR})
    set(GFLAGS_LIBRARY ${gflags_LIBRARIES})

    # gflags does not export the namespace in their CMake configuration, so
    # use our function to determine what it should be, as it can be either
    # gflags or google dependent upon version & configuration.
    #
    # NOTE: We use the regex method to determine the namespace here, as
    #       check_cxx_source_compiles() will not use imported targets, which
    #       is what gflags will be in this case.
    gflags_check_gflags_namespace_using_regex()

    if (NOT GFLAGS_NAMESPACE)
      gflags_report_not_found(
        "Failed to determine gflags namespace using regex for gflags "
        "version: ${gflags_VERSION} exported here: ${gflags_DIR} using CMake.")
    endif (NOT GFLAGS_NAMESPACE)
  else (FOUND_INSTALLED_GFLAGS_CMAKE_CONFIGURATION)
    message(STATUS "Failed to find an installed/exported CMake configuration "
      "for gflags, will perform search for installed gflags components.")
  endif (FOUND_INSTALLED_GFLAGS_CMAKE_CONFIGURATION)
endif(GFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION)

if (NOT GFLAGS_FOUND)
  # Either failed to find an exported gflags CMake configuration, or user
  # told us not to use one.  Perform a manual search for all gflags components.

  # Handle possible presence of lib prefix for libraries on MSVC, see
  # also GFLAGS_RESET_FIND_LIBRARY_PREFIX().
  if (MSVC)
    # Preserve the caller's original values for CMAKE_FIND_LIBRARY_PREFIXES
    # s/t we can set it back before returning.
    set(CALLERS_CMAKE_FIND_LIBRARY_PREFIXES "${CMAKE_FIND_LIBRARY_PREFIXES}")
    # The empty string in this list is important, it represents the case when
    # the libraries have no prefix (shared libraries / DLLs).
    set(CMAKE_FIND_LIBRARY_PREFIXES "lib" "" "${CMAKE_FIND_LIBRARY_PREFIXES}")
  endif (MSVC)

  # Search user-installed locations first, so that we prefer user installs
  # to system installs where both exist.
  list(APPEND GFLAGS_CHECK_INCLUDE_DIRS
    /usr/local/include
    /usr/local/homebrew/include # Mac OS X
    /opt/local/var/macports/software # Mac OS X.
    /opt/local/include
    /usr/include)
  list(APPEND GFLAGS_CHECK_PATH_SUFFIXES
    gflags/include # Windows (for C:/Program Files prefix).
    gflags/Include ) # Windows (for C:/Program Files prefix).

  list(APPEND GFLAGS_CHECK_LIBRARY_DIRS
    /usr/local/lib
    /usr/local/homebrew/lib # Mac OS X.
    /opt/local/lib
    /usr/lib)
  list(APPEND GFLAGS_CHECK_LIBRARY_SUFFIXES
    gflags/lib # Windows (for C:/Program Files prefix).
    gflags/Lib ) # Windows (for C:/Program Files prefix).

  # Search supplied hint directories first if supplied.
  find_path(GFLAGS_INCLUDE_DIR
    NAMES gflags/gflags.h
    PATHS ${GFLAGS_INCLUDE_DIR_HINTS}
    ${GFLAGS_CHECK_INCLUDE_DIRS}
    PATH_SUFFIXES ${GFLAGS_CHECK_PATH_SUFFIXES})
  if (NOT GFLAGS_INCLUDE_DIR OR
      NOT EXISTS ${GFLAGS_INCLUDE_DIR})
    gflags_report_not_found(
      "Could not find gflags include directory, set GFLAGS_INCLUDE_DIR "
      "to directory containing gflags/gflags.h")
  endif (NOT GFLAGS_INCLUDE_DIR OR
    NOT EXISTS ${GFLAGS_INCLUDE_DIR})

  find_library(GFLAGS_LIBRARY NAMES gflags
    PATHS ${GFLAGS_LIBRARY_DIR_HINTS}
    ${GFLAGS_CHECK_LIBRARY_DIRS}
    PATH_SUFFIXES ${GFLAGS_CHECK_LIBRARY_SUFFIXES})
  if (NOT GFLAGS_LIBRARY OR
      NOT EXISTS ${GFLAGS_LIBRARY})
    gflags_report_not_found(
      "Could not find gflags library, set GFLAGS_LIBRARY "
      "to full path to libgflags.")
  endif (NOT GFLAGS_LIBRARY OR
    NOT EXISTS ${GFLAGS_LIBRARY})

  # gflags typically requires a threading library (which is OS dependent), note
  # that this defines the CMAKE_THREAD_LIBS_INIT variable.  If we are able to
  # detect threads, we assume that gflags requires it.
  find_package(Threads QUIET)
  set(GFLAGS_LINK_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
  # On Windows (including MinGW), the Shlwapi library is used by gflags if
  # available.
  if (WIN32)
    include(CheckIncludeFileCXX)
    check_include_file_cxx("shlwapi.h" HAVE_SHLWAPI)
    if (HAVE_SHLWAPI)
      list(APPEND GFLAGS_LINK_LIBRARIES shlwapi.lib)
    endif(HAVE_SHLWAPI)
  endif (WIN32)

  # Mark internally as found, then verify. GFLAGS_REPORT_NOT_FOUND() unsets
  # if called.
  set(GFLAGS_FOUND TRUE)

  # Identify what namespace gflags was built with.
  if (GFLAGS_INCLUDE_DIR AND NOT GFLAGS_NAMESPACE)
    # To handle Windows peculiarities / CMake bugs on MSVC we try two approaches
    # to detect the gflags namespace:
    #
    # 1) Try to use check_cxx_source_compiles() to compile a trivial program
    #    with the two choices for the gflags namespace.
    #
    # 2) [In the event 1) fails] Use regex on the gflags headers to try to
    #    determine the gflags namespace.  Whilst this is less robust than 1),
    #    it does avoid any interaction with msbuild.
    gflags_check_gflags_namespace_using_try_compile()

    if (NOT GFLAGS_NAMESPACE)
      # Failed to determine gflags namespace using check_cxx_source_compiles()
      # method, try and obtain it using regex on the gflags headers instead.
      message(STATUS "Failed to find gflags namespace using using "
        "check_cxx_source_compiles(), trying namespace regex instead, "
        "this is expected on Windows.")
      gflags_check_gflags_namespace_using_regex()

      if (NOT GFLAGS_NAMESPACE)
        gflags_report_not_found(
          "Failed to determine gflags namespace either by "
          "check_cxx_source_compiles(), or namespace regex.")
      endif (NOT GFLAGS_NAMESPACE)
    endif (NOT GFLAGS_NAMESPACE)
  endif (GFLAGS_INCLUDE_DIR AND NOT GFLAGS_NAMESPACE)

  # Make the GFLAGS_NAMESPACE a cache variable s/t the user can view it, and could
  # overwrite it in the CMake GUI.
  set(GFLAGS_NAMESPACE "${GFLAGS_NAMESPACE}" CACHE STRING
    "gflags namespace (google or gflags)" FORCE)

  # gflags does not seem to provide any record of the version in its
  # source tree, thus cannot extract version.

  # Catch case when caller has set GFLAGS_NAMESPACE in the cache / GUI
  # with an invalid value.
  if (GFLAGS_NAMESPACE AND
      NOT GFLAGS_NAMESPACE STREQUAL "google" AND
      NOT GFLAGS_NAMESPACE STREQUAL "gflags")
    gflags_report_not_found(
      "Caller defined GFLAGS_NAMESPACE:"
      " ${GFLAGS_NAMESPACE} is not valid, not google or gflags.")
  endif ()
  # Catch case when caller has set GFLAGS_INCLUDE_DIR in the cache / GUI and
  # thus FIND_[PATH/LIBRARY] are not called, but specified locations are
  # invalid, otherwise we would report the library as found.
  if (GFLAGS_INCLUDE_DIR AND
      NOT EXISTS ${GFLAGS_INCLUDE_DIR}/gflags/gflags.h)
    gflags_report_not_found(
      "Caller defined GFLAGS_INCLUDE_DIR:"
      " ${GFLAGS_INCLUDE_DIR} does not contain gflags/gflags.h header.")
  endif (GFLAGS_INCLUDE_DIR AND
    NOT EXISTS ${GFLAGS_INCLUDE_DIR}/gflags/gflags.h)
  # TODO: This regex for gflags library is pretty primitive, we use lowercase
  #       for comparison to handle Windows using CamelCase library names, could
  #       this check be better?
  string(TOLOWER "${GFLAGS_LIBRARY}" LOWERCASE_GFLAGS_LIBRARY)
  if (GFLAGS_LIBRARY AND
      NOT "${LOWERCASE_GFLAGS_LIBRARY}" MATCHES ".*gflags[^/]*")
    gflags_report_not_found(
      "Caller defined GFLAGS_LIBRARY: "
      "${GFLAGS_LIBRARY} does not match gflags.")
  endif (GFLAGS_LIBRARY AND
    NOT "${LOWERCASE_GFLAGS_LIBRARY}" MATCHES ".*gflags[^/]*")

  gflags_reset_find_library_prefix()

endif(NOT GFLAGS_FOUND)

# Set standard CMake FindPackage variables if found.
if (GFLAGS_FOUND)
  set(GFLAGS_INCLUDE_DIRS ${GFLAGS_INCLUDE_DIR})
  set(GFLAGS_LIBRARIES ${GFLAGS_LIBRARY} ${GFLAGS_LINK_LIBRARIES})
endif (GFLAGS_FOUND)

# Handle REQUIRED / QUIET optional arguments.
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Gflags DEFAULT_MSG
  GFLAGS_INCLUDE_DIRS GFLAGS_LIBRARIES GFLAGS_NAMESPACE)

# Only mark internal variables as advanced if we found gflags, otherwise
# leave them visible in the standard GUI for the user to set manually.
if (GFLAGS_FOUND)
  mark_as_advanced(FORCE GFLAGS_INCLUDE_DIR
    GFLAGS_LIBRARY
    GFLAGS_NAMESPACE
    gflags_DIR) # Autogenerated by find_package(gflags)
endif (GFLAGS_FOUND)