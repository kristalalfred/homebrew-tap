class Exo < Formula
  desc "Agent runtime and command-line client"
  homepage "https://github.com/kristalalfred/homebrew-tap#exo"
  license "MIT"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/exo-v0.1.0/exo-aarch64-apple-darwin.tar.gz"
      sha256 "d5bd4d130b42b2c47e19541b9fa195ee0f9d8cf58163414567797bd89f16b19b"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/exo-v0.1.0/exo-x86_64-apple-darwin.tar.gz"
      version "0.1.0"
      sha256 "d230a107d79031632e8aba34019917adf42c9293c08e9c6244f1ce41ae329915"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/exo-v0.1.0/exo-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c9249ef8cbdfcd3144f6a571993d20aab21a32c65f4894b292a51c6cc426c682"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/exo-v0.1.0/exo-x86_64-unknown-linux-gnu.tar.gz"
      version "0.1.0"
      sha256 "19a4d82dc8af4132bba096f9967ce2b29b646e1b5f949038bc307addbc1f08a1"
    end
  end

  def install
    bin.install "bin/exo", "bin/exod"
    pkgshare.install "release.json"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/exo --version")
    assert_match version.to_s, shell_output("#{bin}/exod --version")
  end
end
