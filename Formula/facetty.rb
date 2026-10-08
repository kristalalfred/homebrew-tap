class Facetty < Formula
  desc "Video calls in your terminal, drawn in ASCII"
  homepage "https://github.com/KristalAlfred/facetty"
  version "0.2.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.2.0/facetty-aarch64-apple-darwin.tar.xz"
      sha256 "fdb83f5ebf0a9853709f282ca2ed13f770aef044bb7009e5d3210bd30ac5ff8e"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.2.0/facetty-x86_64-apple-darwin.tar.xz"
      sha256 "f39c9455104bbe19ed54f92546ce55d407e33f99d8ada178e2aad59411f860a9"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.2.0/facetty-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "9d467b44da8fcc5b417064d45f60535b55266567c308933c834b1fe748279f68"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.2.0/facetty-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "3b3e7a47e4fc8caadcd7e43dab5eac6849325b854abba8468736acd39e19b882"
    end
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":      {},
    "aarch64-unknown-linux-gnu": {},
    "x86_64-apple-darwin":       {},
    "x86_64-pc-windows-gnu":     {},
    "x86_64-unknown-linux-gnu":  {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "facetty"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "facetty"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "facetty"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "facetty"
    end

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
