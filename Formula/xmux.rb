class Xmux < Formula
  desc "Codex-led tmux teammate runtime"
  homepage "https://github.com/DwvN-Lee/XMux"
  url "https://github.com/DwvN-Lee/XMux/releases/download/v1.3.0/xmux-1.3.0.tar.gz"
  sha256 "50a07121279d92938c4efd467a1d8cd0c6011adb05d873d80d8a71adadaa3a9a"
  license "MIT"
  head "https://github.com/DwvN-Lee/XMux.git", branch: "main"

  XMUX_PUBLIC_SKILLS = %w[
    xmux-teams
    xmux-claude
    xmux-gemini
    xmux-copilot
    xmux-diagnosis
    xmux-send-pane
  ].freeze

  depends_on "node"
  depends_on "tmux"
  depends_on "zsh"

  def install
    libexec.install "bin"
    libexec.install "runtime"
    (libexec/"mcp").install "mcp/setup"
    libexec.install "share" if buildpath.join("share").directory?
    XMUX_PUBLIC_SKILLS.each do |name|
      src = buildpath.join("plugins/xmux/skills", name)
      (libexec/"share/xmux/skills").install src if src.directory?
    end

    chmod 0755, libexec/"bin/xmux"
    chmod 0755, libexec/"runtime/relay/xmux-bridge.zsh"
    chmod 0755, libexec/"mcp/setup/claude.js"
    chmod 0755, libexec/"mcp/setup/codex.js"
    chmod 0755, libexec/"mcp/setup/copilot.js"
    chmod 0755, libexec/"mcp/setup/gemini.js"

    (bin/"xmux").write <<~ZSH
      #!/usr/bin/env zsh
      set -euo pipefail
      export XMUX_INSTALL_DIR="#{opt_libexec}"
      exec "#{opt_libexec}/bin/xmux" "$@"
    ZSH

    zsh_completion.install "share/zsh/site-functions/_xmux" if buildpath.join("share/zsh/site-functions/_xmux").file?
  end

  test do
    assert_match "xmux 1.3.0", shell_output("#{bin}/xmux --version")
    assert_predicate libexec/"share/xmux/skills/xmux-teams", :directory?

    (testpath/".codex").mkpath
    system "zsh", "-f", "-c", <<~ZSH
      set -euo pipefail
      cd "#{testpath}"
      export XMUX_INSTALL_DIR="#{opt_libexec}"
      source "#{opt_libexec}/runtime/shell/xmux.zsh"
      test "$XMUX_INSTALL_DIR" = "#{opt_libexec}"
      test "$XMUX_PROJECT_DIR" = "#{testpath}"
      test "$XMUX_STATE_DIR" = "#{testpath}/.codex/xmux"
      "#{opt_libexec}/bin/xmux" --help >/dev/null 2>&1
    ZSH
  end
end
