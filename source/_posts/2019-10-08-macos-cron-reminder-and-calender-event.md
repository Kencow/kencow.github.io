---
title: 如何在 MacOS 定时创建提醒事项和日历日程
date: 2019-10-08 17:33:56
tags: macos
categories: 技术
---

<br>

## 目的
---
#### 在 MacOS 下用定时任务来创建一个提醒事项，通过 iCloud 同步并即时显示在 iPhone 上。
<br>

## 方法一：通过 cron 服务执行 AppleScript
---
<!-- more-->

1. 在 /Users/\<username\>/ 下创建脚本 **cron_reminder.sh** ：

   ``` bash
   #!/bin/bash
   
   osascript << END
   set mydate to (current date) + (1 * minutes)
   tell application "Reminders"
       make new reminder with properties {name:"This is a cron reminder", remind me date:mydate, due date:mydate}
   end tell
   END
   ```

   提醒时间设为当前时间再加一分钟，如果不加，在 MacOS 上会即时弹出提醒，但 iPhone 不会弹出（因为当前这一分钟已经过时了）。

   Reminders 的参数可以参考 “脚本编辑器”，打开「脚本编辑器」 → 新建一个脚本 → 用快捷键 ⌘⇧O 打开 AppleScript 字典（Dictionary）。

2. 给脚本赋予执行权限

   ```bash bash.cmd
   chmod +x cron_reminder.sh
   ```

3. 设置 cron job

   {% codeblock lang:bash %}
   crontab -e
   * * * * * /Users/<username>/cron_reminder.sh
   {% endcodeblock %}

4. 设置权限
      在 [设置] - [安全性与隐私] - [隐私] - [提醒事项] 里，把 ”cron“ 和 ”终端“ 勾上。有时系统会自动弹出提示要不要允许它们访问提醒事项，选“是”就行了。



* 可以在脚本的前面添加你想要创建提醒事项的触发条件，例如监控某个商品降价的时候就给你发个提醒，看你怎么发挥了。

* 用 AppleScript 添加日历日程的例子（可以在“脚本编辑器”里进行调试）：

  ``` applescript
  tell application "Calendar"
  	tell calendar "calendar-name"
  		set theCurrentDate to current date
  		make new event at end with properties {description:"Event Decription", summary:"Event Name", location:"Event Location", start date:theCurrentDate + 1 * minutes, end date:theCurrentDate + 2 * minutes, url:"https://bing.com"}
  	end tell
  end tell
  ```

  

#### 参考

##### [AppleScript 入门：探索 macOS 自动化](https://sspai.com/post/46912)

##### [How can I add reminders via the command line?](https://apple.stackexchange.com/questions/66981/how-can-i-add-reminders-via-the-command-line)

##### [Applescript set string to date and add 30 minutes](http://www.howapple.com/question/1185)

##### [Applescript or Terminal : Add a event on calendar](https://stackoverflow.com/questions/38243987/applescript-or-terminal-add-a-event-on-calendar)

<br>

## 方法二：通过 Mac launchd 执行 automator
---

1. 打开 ”自动操作“ （automator），新建一个 ”工作流程“，在左边资源库里选 [日历]，把 [新建提醒事项项目] 拖到右边窗口，就可以设定标题和日期等参数。设置好并保存为 /Users/\<username\>/**launchd_reminder.workflow**

2. 再创建一个执行上面 workflow 的脚本 /Users/\<username\>/**launchd_reminder.sh**

   ```bash
   #!/bin/bash
   automator /Users/<username>/launchd_reminder.workflow
   ```

3. 到 ~/Library/LaunchAgents 下新建文件 **com.<username\>.reminder.plist**，注意替换里面 `ProgramArguments` 的脚本路径和 `StartInterval` 间隔时间（秒）。

   ```
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
     <key>Label</key>
     <string>com.test.reminder</string>
   
     <key>ProgramArguments</key>
     <array>
       <string>/Users/<username>/launchd_reminder.sh</string>
     </array>
   
     <key>Nice</key>
     <integer>1</integer>
   
     <key>StartInterval</key>
     <integer>60</integer>
   
     <key>RunAtLoad</key>
     <true/>
   
     <key>StandardErrorPath</key>
     <string>/tmp/cron.err</string>
   
     <key>StandardOutPath</key>
     <string>/tmp/cron.out</string>
   </dict>
   </plist>
   ```
   
4. 加载 plist

   ```
   launchctl load com.<username>.reminder.plist
   ```

   可以用 list 查看刚才加载的服务（用 Label 标识）

   ```
   launchctl list com.test.reminder
   ```

5. 第一次执行会弹出安全提示，效果跟 [设置] - [安全性与隐私] - [隐私] 里设置一样，点击 “是” 就OK了。如果要取消定时任务，则用 unload 卸载。

   ```
   launchctl unload com.<username>.reminder.plist
   ```



#### 参考

##### [Mac crontab: Creating MacOS startup jobs with crontab, er, launchd](https://alvinalexander.com/mac-os-x/mac-osx-startup-crontab-launchd-jobs)

<br>

### 总结
---
* 方法一：简单直接，可以自由发挥，但要熟悉 AppleScript ，有一定的难度；

* 方法二：可以傻瓜式选择要自动运行的服务和参数，但过程有点复杂。遗憾的是该方法不能设置当前时间为提醒时间，达不到iPhone 即时提醒的效果。

