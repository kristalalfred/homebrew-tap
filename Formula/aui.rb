class Aui < Formula
  desc "Lua-customizable terminal client for Ronna"
  homepage "https://github.com/kristalalfred/homebrew-tap#aui"
  license :cannot_represent

  depends_on "kristalalfred/tap/ronna"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.0/aui-aarch64-apple-darwin.tar.gz"
      sha256 "2c2f37dbdea286a3c32c8da40ddfd050cc802efe6f355b78210100b1a7b8f03e"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.0/aui-x86_64-apple-darwin.tar.gz"
      version "0.1.0"
      sha256 "40c7e2ff83e7e294e57cf864f9e735f7ac3f8aeb322574cd03b90bd5e3d28ee1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.0/aui-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "4a1e99e119b7876a653eebd3fd5634c94de6790f0283de8064c966fd2e25f868"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/aui-v0.1.0/aui-x86_64-unknown-linux-gnu.tar.gz"
      version "0.1.0"
      sha256 "b21a0e4dac7ea656ec6ee323c9e40e0803707c1ac67a0c421dac3a55e086bbd2"
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
