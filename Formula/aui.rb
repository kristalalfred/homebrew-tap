class Aui < Formula
  desc "Lua-customizable terminal client for Ronna"
  homepage "https://github.com/kristalalfred/homebrew-tap#aui"
  license :cannot_represent

  depends_on "kristalalfred/tap/ronna"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.2/aui-aarch64-apple-darwin.tar.gz"
      sha256 "c8c219b7dafc91fdd0a6b5dc494bda807c8d1b30c600e1d9fda11bceb8b38069"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.2/aui-x86_64-apple-darwin.tar.gz"
      version "0.1.2"
      sha256 "0e07123033f33fc995738a36de69ada5e1468eb6e6f82e3a4e0db059c02f6cec"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.2/aui-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "6837ef4e7ba18521a0abeeadca5802b6db7958289716aeb54a983f581d704886"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.2/aui-x86_64-unknown-linux-gnu.tar.gz"
      version "0.1.2"
      sha256 "04efaa5a0efa708d28ce88fbb2ed7ce64b9f5228dce72dc29e3edcf89e63a7cd"
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
