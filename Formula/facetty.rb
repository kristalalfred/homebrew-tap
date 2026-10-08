class Facetty < Formula
  desc "Video calls in your terminal, drawn in ASCII"
  homepage "https://github.com/KristalAlfred/facetty"
  version "0.1.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-aarch64-apple-darwin.tar.xz"
      sha256 "e8bb15a5c22fedf6e1caa6359016377ae16c92a8182553850f1923fb1f64c0a3"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-x86_64-apple-darwin.tar.xz"
      sha256 "80824bf681b2577a10554753f77fef7bf61c4da68173c6ac41b345c39868efc1"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "f039548048a8dbee3c9e3d52643626d49c2876e5d24d9a6b9946f75a65fd794d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "bcdf2e3a158e34df6e7fbfa2b554ae519c5ca4170eb630f6a78d9fe795d1838c"
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
