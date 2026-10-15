class Ronna < Formula
  desc "Client for Ronna coding sessions and native runners"
  homepage "https://github.com/kristalalfred/homebrew-tap#ronna"
  license :cannot_represent

  depends_on "kristalalfred/tap/exo"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.3/ronna-aarch64-apple-darwin.tar.gz"
      sha256 "2f6c583d7790657a1d5f9ed9b09be343d570c27d3ab68cce82025dec4685b197"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.3/ronna-x86_64-apple-darwin.tar.gz"
      version "0.1.3"
      sha256 "73b0809efed2e97b63adb4214fce620dcb3991e02befab37aa1bad6fb53556e1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.3/ronna-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "dabf854cdb606d92683617c14bf33909b162499c264475cc5953f667272f2427"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.3/ronna-x86_64-unknown-linux-gnu.tar.gz"
      version "0.1.3"
      sha256 "7532bc68f573e2b6da342510735ad14f8c33741857a8e2b988d4f868e684e31b"
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
