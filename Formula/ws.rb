class Ws < Formula
  desc "Ronna workspaces as Rex hosts"
  homepage "https://github.com/kristalalfred/homebrew-tap#ws"
  license :cannot_represent

  depends_on "kristalalfred/tap/ronna"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ws-v0.1.0/ws-aarch64-apple-darwin.tar.gz"
      sha256 "d5640f04cb84dcb8d6000ec2a8db494371d0ab63f568ab52c8c7e548e832fad7"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ws-v0.1.0/ws-x86_64-apple-darwin.tar.gz"
      version "0.1.0"
      sha256 "4f8477818097a23400772464529c4bc7178eaa9b9601064b67e717211ccc9da2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ws-v0.1.0/ws-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f22a9c57e5e2f3191aea82111f472fda46ee02add6072648613f724b757d389c"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ws-v0.1.0/ws-x86_64-unknown-linux-gnu.tar.gz"
      version "0.1.0"
      sha256 "dae3cd92bdaa76ee92d2fc15431e2efa370b21399c5c7ce47f05a236907f67a6"
    end
  end

  def install
    bin.install "bin/ws"
    pkgshare.install "release.json"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ws --version")
  end
end
