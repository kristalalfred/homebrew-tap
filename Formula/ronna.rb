class Ronna < Formula
  desc "Client for Ronna coding sessions and native runners"
  homepage "https://github.com/kristalalfred/homebrew-tap#ronna"
  license :cannot_represent

  depends_on "kristalalfred/tap/exo"

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.0/ronna-aarch64-apple-darwin.tar.gz"
      sha256 "f96dc8b3cb3e28372d1164161370fe6c99fa18570fb6f577a8271b27d7e64275"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.0/ronna-x86_64-apple-darwin.tar.gz"
      version "0.1.0"
      sha256 "1be5faccc94aece5c2ab1f7e05dfae7b7cb8413e6c85edff6e6440699c4f23e9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.0/ronna-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "6fef3377bc6174434a44db93498be20b6961357b1296e4ef2979172392d56aa0"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.1.0/ronna-x86_64-unknown-linux-gnu.tar.gz"
      version "0.1.0"
      sha256 "e83a0f2b0aec6ad3b5b315f446dc83161c81b6baf8649cd5a5ef0c957bb206c6"
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
