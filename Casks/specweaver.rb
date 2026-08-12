cask "specweaver" do
  version "0.1.1"
  sha256 "a8af46ef0712ada2dc1b9e0e374192c5fe49b232c6ae88ab1529486389b4d666"

  url "https://github.com/yangfanfengshun/SpecWeaver-App/releases/download/v#{version}/SpecWeaver_#{version}_universal.dmg"
  name "SpecWeaver"
  desc "Console for toggling SpecWeaver MCP and Skills across Claude Code, Codex and Cursor"
  homepage "https://github.com/yangfanfengshun/SpecWeaver-App"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :monterey"
  # MCP 是 Python 实现、靠 uv 启动。缺了它开关能开但宿主拉不起 MCP，
  # 而且 App 界面上看不出异常，所以在安装期就把它带上。
  depends_on formula: "uv"

  app "SpecWeaver.app"

  # 应用未做签名公证，首次打开会被 Gatekeeper 拦下并提示「已损坏」。
  # 这里替用户剥掉 quarantine，等同于手动敲 xattr。
  # 官方 homebrew-cask 的 audit 会拒绝这段，自建 tap 才能用；将来签名了就删掉。
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/SpecWeaver.app"]
  end

  # 只在 brew uninstall --zap 时执行。~/.specweaver 里存着用户配置的认证信息，
  # public-repo/README.md 的卸载一节已写明这点。
  # 后两项对应 tauri.conf.json 的 identifier，改 identifier 时这里要跟着改。
  zap trash: [
    "~/.specweaver",
    "~/Library/Preferences/com.specweaver.gui.plist",
    "~/Library/Caches/com.specweaver.gui",
  ]
end
