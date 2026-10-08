class Facetty < Formula
  desc "Video calls in your terminal, drawn in ASCII"
  homepage "https://github.com/KristalAlfred/facetty"
  version "0.2.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.2.1/facetty-aarch64-apple-darwin.tar.xz"
      sha256 "3c767d4accee80106875a821824c17554af07a523618bc942bd3a89a2ebee5f0"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.2.1/facetty-x86_64-apple-darwin.tar.xz"
      sha256 "9905701a242ac7863b1227745c07e245af94e1a7af80fe2bdfdf09a30bf72184"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.2.1/facetty-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "9da78cacb3fcc9fedd436b7fc03e2468dec88f10daee47cd1a6f11b26651210d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/KristalAlfred/facetty/releases/download/v0.2.1/facetty-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "d623b8029f57d98761ee46078ff761dd5ae0478845118f6880662e423a687322"
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
