# Exports: ${EMBREE_INCLUDE_DIRS}
# Exports: ${EMBREE_LIB_DIR}
# Exports: ${EMBREE_LIBRARIES}

include(ExternalProject)


# select ISAs
if(APPLE)
    if(APPLE_AARCH64)
        # Turn off ISA optimizations for Apple ARM64 for now.
        set(ISA_ARGS -DEMBREE_ISA_AVX=OFF
                     -DEMBREE_ISA_AVX2=OFF
                     -DEMBREE_ISA_AVX512=OFF
                     -DEMBREE_ISA_SSE2=OFF
                     -DEMBREE_ISA_SSE42=OFF
        )
    ELSEIF(CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
        # With AppleClang we can select only 1 ISA.
         set(ISA_ARGS -DEMBREE_ISA_AVX=OFF
                     -DEMBREE_ISA_AVX2=OFF
                     -DEMBREE_ISA_AVX512=OFF
                     -DEMBREE_ISA_SSE2=OFF
                     -DEMBREE_ISA_SSE42=OFF
        )
    else()
        # With AppleClang we can select only 1 ISA.
        set(ISA_ARGS -DEMBREE_ISA_AVX=OFF
                     -DEMBREE_ISA_AVX2=OFF
                     -DEMBREE_ISA_AVX512=OFF
                     -DEMBREE_ISA_SSE2=OFF
                     -DEMBREE_ISA_SSE42=ON
        )
        set(ISA_LIBS embree_sse42)
        set(ISA_BUILD_BYPRODUCTS "<INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}embree_sse42${CMAKE_STATIC_LIBRARY_SUFFIX}" )
    endif()
elseif(LINUX_AARCH64)
    set(ISA_ARGS -DEMBREE_ISA_AVX=OFF
                 -DEMBREE_ISA_AVX2=OFF
                 -DEMBREE_ISA_AVX512=OFF
                 -DEMBREE_ISA_SSE2=OFF
                 -DEMBREE_ISA_SSE42=OFF
    )
    set(ISA_LIBS "")
    set(ISA_BUILD_BYPRODUCTS "")
else() # Linux(x86) and WIN32
    set(ISA_ARGS -DEMBREE_ISA_AVX=ON
                 -DEMBREE_ISA_AVX2=ON
                 -DEMBREE_ISA_AVX512=OFF
                 -DEMBREE_ISA_SSE2=OFF
                 -DEMBREE_ISA_SSE42=OFF
    )
    # order matters. link libs with increasing ISA order.
    set(ISA_LIBS embree_avx embree_avx2)
    set(ISA_BUILD_BYPRODUCTS "<INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}embree_avx${CMAKE_STATIC_LIBRARY_SUFFIX}"
                             "<INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}embree_avx2${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
endif()



if(WIN32)
    set(WIN_CMAKE_ARGS "-DCMAKE_CXX_FLAGS_DEBUG=$<IF:$<BOOL:${STATIC_WINDOWS_RUNTIME}>,/MTd,/MDd> ${CMAKE_CXX_FLAGS_DEBUG_INIT}"
                       "-DCMAKE_CXX_FLAGS_RELEASE=$<IF:$<BOOL:${STATIC_WINDOWS_RUNTIME}>,/MT,/MD> ${CMAKE_CXX_FLAGS_RELEASE_INIT}"
                       "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=$<IF:$<BOOL:${STATIC_WINDOWS_RUNTIME}>,/MT,/MD> ${CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT}"
                       "-DCMAKE_CXX_FLAGS_MINSIZEREL=$<IF:$<BOOL:${STATIC_WINDOWS_RUNTIME}>,/MT,/MD> ${CMAKE_CXX_FLAGS_MINSIZEREL_INIT}"
                       "-DCMAKE_C_FLAGS_DEBUG=$<IF:$<BOOL:${STATIC_WINDOWS_RUNTIME}>,/MTd,/MDd> ${CMAKE_C_FLAGS_DEBUG_INIT}"
                       "-DCMAKE_C_FLAGS_RELEASE=$<IF:$<BOOL:${STATIC_WINDOWS_RUNTIME}>,/MT,/MD> ${CMAKE_C_FLAGS_RELEASE_INIT}"
                       "-DCMAKE_C_FLAGS_RELWITHDEBINFO=$<IF:$<BOOL:${STATIC_WINDOWS_RUNTIME}>,/MT,/MD> ${CMAKE_C_FLAGS_RELWITHDEBINFO_INIT}"
                       "-DCMAKE_C_FLAGS_MINSIZEREL=$<IF:$<BOOL:${STATIC_WINDOWS_RUNTIME}>,/MT,/MD> ${CMAKE_C_FLAGS_MINSIZEREL_INIT}"
                       )
else()
    set(WIN_CMAKE_ARGS "")
endif()


ExternalProject_Add(
    ext_embree
    PREFIX embree
    URL https://github.com/embree/embree/archive/refs/tags/v3.13.3.tar.gz
    URL_HASH SHA256=74ec785afb8f14d28ea5e0773544572c8df2e899caccdfc88509f1bfff58716f
    DOWNLOAD_DIR "${OPEN3D_THIRD_PARTY_DOWNLOAD_DIR}/embree"
    UPDATE_COMMAND ""
    CMAKE_ARGS
        ${ExternalProject_CMAKE_ARGS_hidden}
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        ${ISA_ARGS}
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_LIB=ON
        -DEMBREE_GEOMETRY_CURVE=OFF
        -DEMBREE_GEOMETRY_GRID=OFF
        -DEMBREE_GEOMETRY_INSTANCE=OFF
        -DEMBREE_GEOMETRY_QUAD=OFF
        -DEMBREE_GEOMETRY_SUBDIVISION=OFF
        -DEMBREE_TASKING_SYSTEM=INTERNAL
        ${WIN_CMAKE_ARGS}
    BUILD_BYPRODUCTS
        <INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}embree3${CMAKE_STATIC_LIBRARY_SUFFIX}
        <INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}simd${CMAKE_STATIC_LIBRARY_SUFFIX}
        <INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}lexers${CMAKE_STATIC_LIBRARY_SUFFIX}
        <INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}sys${CMAKE_STATIC_LIBRARY_SUFFIX}
        <INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}math${CMAKE_STATIC_LIBRARY_SUFFIX}
        <INSTALL_DIR>/${Open3D_INSTALL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}tasking${CMAKE_STATIC_LIBRARY_SUFFIX}
        ${ISA_BUILD_BYPRODUCTS}
)

ExternalProject_Get_Property(ext_embree INSTALL_DIR)
set(EMBREE_INCLUDE_DIRS ${INSTALL_DIR}/include/ ${INSTALL_DIR}/src/ext_embree/) # "/" is critical.
set(EMBREE_LIB_DIR ${INSTALL_DIR}/${Open3D_INSTALL_LIB_DIR})
set(EMBREE_LIBRARIES embree3 ${ISA_LIBS} simd lexers sys math tasking)
