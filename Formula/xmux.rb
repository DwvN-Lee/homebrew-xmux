class Xmux < Formula
  desc "XMux communication harness for Codex and Claude"
  homepage "https://github.com/DwvN-Lee/XMux"
  url "https://github.com/DwvN-Lee/XMux.git",
      tag:      "v1.0.2",
      revision: "e65a21702ae1ec680ea20f3beb05e386a6fa6bf5"
  version "1.0.2"
  license "MIT"
  head "https://github.com/DwvN-Lee/XMux.git", branch: "main"

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
    assert_match "xmux 1.0.2", shell_output("#{bin}/xmux --version")
    assert_predicate libexec/"assets/claude/skills/xmux-codex/SKILL.md", :file?
    assert_predicate libexec/"assets/codex/skills/xmux-claude/SKILL.md", :file?
    assert_predicate libexec/"assets/codex/skills/xmux-implement/SKILL.md", :file?
    assert_predicate libexec/"assets/claude/agents/xmux-review.md", :file?
    assert_predicate libexec/"src/xmux/setup.js", :file?
    assert_predicate libexec/"src/xmux/workflow-cli.js", :file?
    assert_predicate libexec/"dist/xmux/setup.js", :file?
    assert_predicate libexec/"dist/xmux/workflow-cli.js", :file?

    system "zsh", "-f", "-c", <<~ZSH
      set -euo pipefail
      cd "#{testpath}"
      mkdir -p .git
      export HOME="#{testpath}/home"
      export CLAUDE_HOME="#{testpath}/claude-home"
      "#{bin}/xmux" setup-xmux --home "#{testpath}/codex-home" --refresh >/dev/null
      "#{bin}/xmux" doctor-xmux --home "#{testpath}/codex-home" --json >/dev/null
      test -f "#{testpath}/codex-home/config.toml"
      test -f "#{testpath}/home/.agents/skills/xmux-claude/SKILL.md"
      test -f "#{testpath}/claude-home/settings.json"
      test -f "#{testpath}/claude-home/skills/xmux-codex/SKILL.md"
      test -f "#{testpath}/claude-home/agents/xmux-review.md"
    ZSH
  end
end
