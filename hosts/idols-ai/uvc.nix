{ stdenv, kernel, lib, fetchFromGitHub }:

let
  src = fetchFromGitHub {
    owner = "QixYuanmeng";
    repo = "uvc";
    rev = "6e276de5a272501c48c802fb0dbdee5d01d64c36"; # 或者是 commit hash
    sha256 = "09s02ahagw3fqnw40fhigc2f0bxs3q5s0293ygyzr0nia7zpljc6"; # 这里应该是对应的 SHA256 校验和
    # 如果仓库有子模块，可以添加 fetchSubmodules = true;
  };
in stdenv.mkDerivation rec {
  name = "myuvcvideo-9.9.9";
  inherit src;

  buildInputs = [ kernel ];

   buildPhase = ''
    # 确保我们使用正确的内核构建目录
    export KERNEL_BUILD_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
    # 编译模块
    make -C $KERNEL_BUILD_DIR M=$(pwd) modules
  '';

  installPhase = ''
    # 将编译好的模块复制到 NixOS 内核模块目录
      mkdir -p $out/lib/modules/${kernel.modDirVersion}
      cp ./myuvcvideo.ko $out/lib/modules/${kernel.modDirVersion}
  '';

  # 设置 meta 数据
  meta =  {
    description = "UVC video kernel module for Quanta Computer, Inc. ACER HD User Facing";
    license = lib.licenses.gpl2;
    maintainers = [ "QixYuanmeng" ];
    platforms = lib.platforms.linux;
  };
}