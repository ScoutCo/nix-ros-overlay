
# Copyright 2025 Open Source Robotics Foundation
# Distributed under the terms of the BSD license

{ lib, buildRosPackage, fetchurl, ament-cmake, ament-cmake-gtest, ament-lint-auto, ament-lint-common, git, performance-test-fixture, rcpputils, writeText }:
let
  patch-cmake-content = ''
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 4f81148..3cbf55f 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -1,5 +1,5 @@
 
-cmake_minimum_required(VERSION 3.0)
+cmake_minimum_required(VERSION 3.9)
 project (yaml C)
 
 set (YAML_VERSION_MAJOR 0)
  '';
  patch-cmake-file = writeText "patch-cmake.patch" patch-cmake-content;
in
buildRosPackage{
  pname = "ros-humble-libyaml-vendor";
  version = "1.2.2-r2";

  src = fetchurl {
    url = "https://github.com/ros2-gbp/libyaml_vendor-release/archive/release/humble/libyaml_vendor/1.2.2-2.tar.gz";
    name = "1.2.2-2.tar.gz";
    sha256 = "88e26943a185155364dba8847dfa9130fe52e5ba9f55b942ff8473773e9523fd";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "PATCH_COMMAND" '
            PATCH_COMMAND 
              ''${CMAKE_COMMAND} -E chdir <SOURCE_DIR> git apply -p1 --ignore-space-change --whitespace=nowarn 
                ${patch-cmake-file}
              &&
          '
  '';


  buildType = "ament_cmake";
  buildInputs = [ ament-cmake git ];
  checkInputs = [ ament-cmake-gtest ament-lint-auto ament-lint-common performance-test-fixture rcpputils ];
  nativeBuildInputs = [ ament-cmake git ];

  meta = {
    description = "Vendored version of libyaml.";
    license = with lib.licenses; [ asl20 mit ];
  };
}
