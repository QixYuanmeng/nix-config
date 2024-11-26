{ stdenv, fetchFromGitHub ,lib}:

stdenv.mkDerivation {
  pname = "custom-win10-fonts";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "QixYuanmeng";
    repo = "ttf-ms-win10";
    rev = "60742666ee375df71a77c57db4bbf0713f34e44a";  # 替换为你的仓库的特定 commit hash 或 tag
    sha256 = "1kp85ih34svjyxms2qkvvxr6qra5kqisj4gjzmknv1vv2mpc5fyb";  # 替换为你的仓库的 sha256 校验和
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp -r $src/*.ttf $out/share/fonts/truetype/
  '';

  meta = with lib; {
    description = "Custom Windows 10 fonts";
    homepage = "https://github.com/QixYuanmeng/ttf-ms-win10";
    license = licenses.unfree;  # 根据你的字体许可证进行调整
    platforms = platforms.all;
    maintainers = with maintainers; [ QixYuanmeng ];  # 替换为你的 GitHub 用户名
  };
}