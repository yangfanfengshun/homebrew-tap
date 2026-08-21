cask "specweaver" do
  version "0.1.5"
  sha256 "5709785f27cda84a07d17be10ad6dbe94904f37b342c7a04988f67aa85dbfaa8"

  url "https://github.com/yangfanfengshun/SpecWeaver-App/releases/download/v#{version}/SpecWeaver_#{version}_universal.dmg"
  name "SpecWeaver"
  desc "Console for toggling SpecWeaver MCP and Skills across Claude Code, Codex and Cursor"
  homepage "https://github.com/yangfanfengshun/SpecWeaver-App"

  livecheck do
    url :url
    strategy :github_latest
  end

  # 写成符号而不是 ">= :monterey" 字符串——后者已被 Homebrew 弃用，
  # 符号形式本身就表示「该版本及以上」。
  depends_on macos: :monterey
  # MCP 是 Python 实现、靠 uv 启动。缺了它开关能开但宿主拉不起 MCP，
  # 装期带上，省得用户装完再被 App 提示一次。
  depends_on formula: "uv"
  # sw merge 全程靠 glab 调 GitLab、靠 jq 解析它的 JSON 输出。
  # 缺了它们 App 会锁住 GitLab 的配置入口，这里一并带上。
  depends_on formula: "glab"
  depends_on formula: "jq"

  app "SpecWeaver.app"
  # 命令行入口随 App 一起分发。指向 .app 内的脚本而不是 ~/.specweaver/，
  # 后者要等 App 首次启动同步完才存在，装完就敲 sw 会扑空。
  binary "#{appdir}/SpecWeaver.app/Contents/Resources/runtime/scripts/sw"

  # 应用未做签名公证，首次打开会被 Gatekeeper 拦下并提示「已损坏」。
  # 这里替用户剥掉 quarantine，等同于手动敲 xattr。
  # 官方 homebrew-cask 的 audit 会拒绝这段，自建 tap 才能用；将来签名了就删掉。
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/SpecWeaver.app"]
    # 打包过程可能丢执行位，binary 软链过去也就跑不起来
    system_command "/bin/chmod",
                   args: ["+x", "#{appdir}/SpecWeaver.app/Contents/Resources/runtime/scripts/sw"]
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
