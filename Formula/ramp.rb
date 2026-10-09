class Ramp < Formula
  desc "Programmable terminal frontend for agent harnesses"
  homepage "https://github.com/kristalalfred/homebrew-tap#ramp"
  license "MIT"

  depends_on "kristalalfred/tap/exo"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ramp-v0.1.0/ramp-aarch64-apple-darwin.tar.gz"
      sha256 "834d3bb084102b4240727a99d5e67b8c350c18464b596f6a81ba7a74fba43567"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ramp-v0.1.0/ramp-x86_64-apple-darwin.tar.gz"
      sha256 "8f2e6296fc5acf70f2b6272192562472220e1c1d666612e8fd934778cc0cb878"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ramp-v0.1.0/ramp-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "ddbc377b2dc961a817a91d90ca948fe53cffbb631caef228a3c92a9702ead2f0"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ramp-v0.1.0/ramp-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "150ebb10ab551e76fb08e17ff8d6b6e89d8a6a9108a96b84700628a513de6526"
    end
  end

  def install
    bin.install "bin/ramp"
    pkgshare.install "release.json"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ramp --version")
  end
end
