class Aui < Formula
  desc "Lua-customizable terminal client for Ronna"
  homepage "https://github.com/kristalalfred/homebrew-tap#aui"
  license :cannot_represent

  depends_on "kristalalfred/tap/ronna"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.1/aui-aarch64-apple-darwin.tar.gz"
      sha256 "36e07c51a7c434d7ecf2393ec19895cd5d78cb6b03a32ac4b89dfad6d97af50e"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.1/aui-x86_64-apple-darwin.tar.gz"
      version "0.1.1"
      sha256 "37b5bfd5569c1b68fb70dc6d1c15c6ebd9368dd663a5370786d975f2104b9bc8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.1/aui-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "168445a35667efedceaba74f042f99d4d887f1ab40e776386ea5213a3af5bb08"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.1/aui-x86_64-unknown-linux-gnu.tar.gz"
      version "0.1.1"
      sha256 "d34930309d2c21da8cf0f45449cb358bdf604dd713a8090877f5a8ceb936c6b8"
    end
  end

  def install
    bin.install "bin/aui"
    pkgshare.install "release.json"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aui --version")
  end
end
