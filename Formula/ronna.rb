class Ronna < Formula
  desc "Client for Ronna coding sessions and native runners"
  homepage "https://github.com/kristalalfred/homebrew-tap#ronna"
  license :cannot_represent

  depends_on "kristalalfred/tap/exo"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.2/ronna-aarch64-apple-darwin.tar.gz"
      sha256 "3669544cd5d35a1b83422427037b0ef52986fb9556bdc1110b2c4384aa9c06ee"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.2/ronna-x86_64-apple-darwin.tar.gz"
      version "0.1.2"
      sha256 "f42dc896117bafc5344da9f191a6d43f240eaf73c8332d00b4c003bda6733223"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.2/ronna-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f64e46bb680df88b41a8078ea166bb8c5b68abaa8b4575e4bc3af00cb4b07d83"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.2/ronna-x86_64-unknown-linux-gnu.tar.gz"
      version "0.1.2"
      sha256 "559fd7a8bc045a945e8c40933a36266055fa92be7bc2b3f7de10f25eed4f6b22"
    end
  end

  def install
    bin.install "bin/ronna"
    pkgshare.install "release.json"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ronna --version")
  end
end
