class Facetty < Formula
  desc "Video calls in your terminal, drawn in ASCII"
  homepage "https://github.com/KristalAlfred/facetty"
  version "0.1.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-aarch64-apple-darwin.tar.xz"
      sha256 "ca38582149816b5f51bfc05d61939b2cff27fcd2f029f5ba0fe5fd3aed8a16c9"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-x86_64-apple-darwin.tar.xz"
      sha256 "0e1799cd39877f3b3a88c67c77a9aff2f6b1b5606f7b92ad07cafd6835d5a717"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "0d686aa48699138c908d1f5675910aa6646e192e853684a3f73d0275e2bc449a"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "414cd1be23c38a1bbc78b9b6bc2ea04f8f416b952839a562dc406d89e2e116dc"
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
