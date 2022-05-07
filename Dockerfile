# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y make cmake ccache ninja-build clang git


WORKDIR /checkedc-clang
ADD . /checkedc-clang/src

WORKDIR /checkedc-clang/src/llvm/projects/checkedc-wrapper
RUN git clone https://github.com/Microsoft/checkedc


WORKDIR /checkedc-clang/build
RUN cmake -G Ninja -DLLVM_ENABLE_PROJECTS=clang   // Required to enable Clang build \
    -DCMAKE_INSTALL_PREFIX=/checkedc-clang/install     // Directory where the compiler will be \
    // installed when "ninja install" is executed.  \
    -DCMAKE_BUILD_TYPE=Release                    // Alternate values: Debug, RelWithDebInfo, \
    // MinSizeRel. \
    -DLLVM_ENABLE_ASSERTIONS=ON                   // Alternate value: OFF. \
    -DLLVM_CCACHE_BUILD=ON                        // OPTIONAL. If this definition exists, ccache \
    // will be used to speed up builds. \
    -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON              // OPTIONAL. This definition is required to \
    // build a package for installation on other \
    // machines. \
    -DLLVM_TARGETS_TO_BUILD="X86"                 // By default, CMake will produce a build \
    // system that builds code generators for all \
    // LLVM-supported architectures. Specify \
    // architecture to decrease build/link times. \
    -DLLVM_LIT_ARGS=-v                            // Arguments to pass to the test framework \
    /checkedc-clang/src/llvm 

RUN ninja clang


FROM --platform=linux/amd64 ubuntu:20.04 

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y binutils gcc-multilib

COPY --from=builder /checkedc-clang/build/bin/clang .
