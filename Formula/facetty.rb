class Facetty < Formula
  desc "Video calls in your terminal, drawn in ASCII"
  homepage "https://github.com/KristalAlfred/facetty"
  version "0.1.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-aarch64-apple-darwin.tar.xz"
      sha256 "93409a2b83538a1430cc9a048188d634e9a863fabfd5bb0eb0499dfd16d25159"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-x86_64-apple-darwin.tar.xz"
      sha256 "1f6bf312d98280300ed2d5e9b4adba298fa5bc128860c2bff7b469322d652827"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "e34ffb93f538a3c6269ea34d9ae34acf045a308739e323742d5a13735faca6cc"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.1.0/facetty-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "7c904a72e68ccecad37f4f1abfe82a2224b1221cf2ac66047279fe75d864911b"
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
