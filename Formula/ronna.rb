class Ronna < Formula
  desc "Command-line client for Ronna team workspaces"
  homepage "https://github.com/kristalalfred/homebrew-tap#ronna"
  license :cannot_represent

  on_macos do
    depends_on macos: :monterey

    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.2.0/ronna-aarch64-apple-darwin.tar.gz"
      sha256 "7f750cc99378211a46e4c24128cfc91a9b502681075608d314957944f5165cf4"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.2.0/ronna-x86_64-apple-darwin.tar.gz"
      version "0.2.0"
      sha256 "a2f66715e375eab478856d977e439f8fedca3430cc7591d87ad415f7056700c1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.2.0/ronna-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "31f7016bcb1f726b974a2899b85fb2800829b7f0810880e9a48680bb018e59d2"
    end

    on_intel do
      url "https://github.com/kristalalfred/homebrew-tap/releases/download/ronna-v0.2.0/ronna-x86_64-unknown-linux-gnu.tar.gz"
      version "0.2.0"
      sha256 "862750991c54b065729dca73838ff08eb7d6c73b0ae090e4def3bbb5123fb66a"
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
