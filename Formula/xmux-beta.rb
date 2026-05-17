class XmuxBeta < Formula
  desc "Codex-Claude hook harness runtime beta"
  homepage "https://github.com/DwvN-Lee/XMux"
  url "https://github.com/DwvN-Lee/XMux/archive/refs/tags/v2.0.2-beta.6.tar.gz"
  sha256 "a46e02e8b38930b8fac0d1aa52e568785cbc8e5b06033ace608e449974feb6f6"
  license "MIT"

  depends_on "node"
  depends_on "tmux"
  depends_on "zsh"

  def install
    libexec.install "assets"
    libexec.install "bin"
    libexec.install "dist"
    libexec.install "runtime"
    libexec.install "share" if buildpath.join("share").directory?
    libexec.install "src"

    chmod 0755, libexec/"bin/xmux"
    chmod 0755, libexec/"runtime/claude/pane-run.py"
    chmod 0755, libexec/"runtime/codex/pane-run.py"

    (bin/"xmux").write <<~ZSH
      #!/usr/bin/env zsh
      set -euo pipefail
      export XMUX_INSTALL_DIR="#{opt_libexec}"
      exec "#{opt_libexec}/bin/xmux" "$@"
    ZSH

    zsh_completion.install "share/zsh/site-functions/_xmux" if buildpath.join("share/zsh/site-functions/_xmux").file?
  end

  test do
    assert_match "xmux 2.0.2-beta.6", shell_output("#{bin}/xmux --version")
    assert_predicate libexec/"assets/claude/skills/xmux-codex/SKILL.md", :file?
    assert_predicate libexec/"assets/codex/skills/xmux-claude/SKILL.md", :file?
    assert_predicate libexec/"src/xmux/setup.js", :file?
    assert_predicate libexec/"dist/xmux/setup.js", :file?

    system "zsh", "-f", "-c", <<~ZSH
      set -euo pipefail
      cd "#{testpath}"
      mkdir -p .git
      export HOME="#{testpath}"
      export CLAUDE_HOME="#{testpath}/claude-home"
      "#{bin}/xmux" setup-xmux --home "#{testpath}/codex-home" --refresh >/dev/null
      "#{bin}/xmux" doctor-xmux --home "#{testpath}/codex-home" --json >/dev/null
      test -f "#{testpath}/codex-home/config.toml"
      test -f "#{testpath}/codex-home/hooks.json"
      test -f "#{testpath}/.agents/skills/xmux-claude/SKILL.md"
      test -f "#{testpath}/claude-home/settings.json"
      test -f "#{testpath}/claude-home/skills/xmux-codex/SKILL.md"
    ZSH
  end
end
