@echo off
title 薛定猫一键配置 OpenClaw Clawdbot
color 0A

REM 测试脚本是否可以运行
echo 正在加载脚本...

REM 设置 UTF-8 编码
chcp 65001 >nul 2>&1
if errorlevel 1 (
    echo 警告: 无法设置UTF-8编码，继续运行...
)

REM 启用延迟变量扩展
setlocal enabledelayedexpansion
if errorlevel 1 (
    echo 错误: 无法启用延迟变量扩展！
    pause
    exit /b 1
)

cls
echo.
echo ========================================
echo   薛定猫 OpenClaw Clawdbot 一键配置脚本
echo ========================================
echo.
echo 正在初始化...
echo.

REM 检查管理员权限
echo [检查] 检测权限...
net session >nul 2>&1
if errorlevel 1 (
    echo [提示] 当前为普通用户权限（建议使用管理员权限）
) else (
    echo [成功] 已获取管理员权限
)
echo.
timeout /t 1 >nul

REM 第一步：检查 Node.js 环境
echo ========================================
echo [步骤 1/7] 检查 Node.js 环境
echo ========================================
echo.
echo 正在检测 Node.js...
set "NODE_FOUND=0"
cmd /c node --version > "%TEMP%\node_ver.txt" 2>&1
if exist "%TEMP%\node_ver.txt" (
    set /p NODE_VERSION=<"%TEMP%\node_ver.txt"
    del "%TEMP%\node_ver.txt" >nul 2>&1
    if not "!NODE_VERSION!"=="" (
        echo [成功] 已安装 Node.js !NODE_VERSION!
        set "NODE_FOUND=1"
    )
)

if "!NODE_FOUND!"=="0" (
    echo.
    echo [提示] 未检测到 Node.js！
    echo.
    set /p INSTALL_NODE="是否自动下载并安装 Node.js? (Y/N): "
    if /i "!INSTALL_NODE!"=="Y" (
        echo.
        echo [下载] 正在检测系统架构...
        if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
            set "NODE_ARCH=x64"
        ) else if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
            set "NODE_ARCH=arm64"
        ) else (
            set "NODE_ARCH=x86"
        )
        set "NODE_DL_VER=v22.14.0"
        set "NODE_MSI=node-!NODE_DL_VER!-!NODE_ARCH!.msi"
        set "NODE_URL=https://nodejs.org/dist/!NODE_DL_VER!/!NODE_MSI!"
        set "NODE_DL_PATH=%TEMP%\!NODE_MSI!"
        echo [下载] 正在下载 Node.js !NODE_DL_VER! ^(!NODE_ARCH!^)...
        echo [下载] 地址: !NODE_URL!
        echo.
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('!NODE_URL!', '!NODE_DL_PATH!')"
        if not exist "!NODE_DL_PATH!" (
            echo.
            echo [错误] Node.js 下载失败！
            echo [提示] 请检查网络连接，或手动下载安装: https://nodejs.org/
            echo.
            echo 按任意键退出...
            pause >nul
            exit /b 1
        )
        echo [下载] 下载完成！
        echo.
        echo [安装] 正在安装 Node.js（可能需要管理员权限）...
        echo [安装] 安装过程中请勿关闭窗口...
        echo.
        msiexec /i "!NODE_DL_PATH!" /qn /norestart
        if errorlevel 1 (
            echo [提示] 静默安装未成功，尝试使用交互式安装...
            msiexec /i "!NODE_DL_PATH!"
            if errorlevel 1 (
                echo.
                echo [错误] Node.js 安装失败！
                echo [提示] 请手动运行安装包: !NODE_DL_PATH!
                echo.
                echo 按任意键退出...
                pause >nul
                exit /b 1
            )
        )
        echo.
        echo [安装] Node.js 安装完成！正在刷新环境变量...
        echo.
        REM 刷新 PATH 环境变量以识别新安装的 Node.js
        set "NEW_NODE_DIR=C:\Program Files\nodejs"
        if not exist "!NEW_NODE_DIR!\node.exe" (
            set "NEW_NODE_DIR=C:\Program Files (x86)\nodejs"
        )
        if exist "!NEW_NODE_DIR!\node.exe" (
            set "PATH=!NEW_NODE_DIR!;!PATH!"
        ) else (
            echo [警告] 未在默认路径找到 Node.js，尝试从注册表获取...
            for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do (
                set "PATH=%%B"
            )
        )
        REM 清理安装包
        del "!NODE_DL_PATH!" >nul 2>&1
        REM 验证安装结果
        cmd /c node --version > "%TEMP%\node_ver.txt" 2>&1
        if exist "%TEMP%\node_ver.txt" (
            set /p NODE_VERSION=<"%TEMP%\node_ver.txt"
            del "%TEMP%\node_ver.txt" >nul 2>&1
        )
        if "!NODE_VERSION!"=="" (
            echo.
            echo [错误] 安装后仍无法检测到 Node.js！
            echo [提示] 请关闭此窗口，重新打开命令行后再次运行本脚本
            echo.
            echo 按任意键退出...
            pause >nul
            exit /b 1
        )
        echo [成功] Node.js !NODE_VERSION! 安装并验证成功！
    ) else (
        echo.
        echo [提示] 请手动安装 Node.js: https://nodejs.org/
        echo.
        echo 按任意键退出...
        pause >nul
        exit /b 1
    )
)
echo.

REM 检查 npm
echo 正在检测 npm...
cmd /c npm --version > "%TEMP%\npm_ver.txt" 2>&1
if not exist "%TEMP%\npm_ver.txt" (
    echo.
    echo [错误] npm 未正确安装！
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)
set /p NPM_VERSION=<"%TEMP%\npm_ver.txt"
if "!NPM_VERSION!"=="" (
    echo.
    echo [错误] npm 未正确安装！
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)
del "%TEMP%\npm_ver.txt" >nul 2>&1
echo [成功] npm 版本: !NPM_VERSION!
echo.

REM 第二步：全局安装 clawdbot
echo ========================================
echo [步骤 2/7] 安装 clawdbot
echo ========================================
echo.
echo 正在全局安装 clawdbot（可能需要几分钟，请耐心等待）...
echo.
cmd /c npm i -g clawdbot
if errorlevel 1 (
    echo.
    echo [错误] clawdbot 安装失败！
    echo [提示] 请检查网络连接或尝试切换 npm 镜像源
    echo.
    echo.  
    echo 按任意键退出...
    pause >nul
    exit /b 1
)
echo.
echo [成功] clawdbot 安装完成
echo.

REM 第三步：执行初始化引导
echo ========================================
echo [步骤 3/7] 执行初始化引导
echo ========================================
echo.
echo [重要] 请按照提示完成基础设置：
echo   - 设置工作目录
echo   - 选择默认模型
echo   - 其他配置选项
echo.
echo 开始初始化...
echo.
call clawdbot onboard
if errorlevel 1 (
    echo.
    echo [错误] 初始化失败！
    echo [提示] 请检查是否正确完成了引导设置
    echo.
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)
echo.
echo [成功] 初始化完成
echo.

REM 第四步：获取用户API密钥
echo ========================================
echo [步骤 4/7] 配置 API 密钥
echo ========================================
echo.
echo 请访问 xuedingmao.top 获取您的 API 密钥
echo.
echo [提示] 如果暂时没有密钥，可以先输入占位符，稍后再修改
echo.
set /p GPT_KEY="请输入 GPT API Key (sk-开头): "
set /p CLAUDE_KEY="请输入 Claude API Key (sk-开头): "
set /p GOOGLE_KEY="请输入 Google API Key (sk-开头): "
echo.

REM 验证密钥格式
if "!GPT_KEY!"=="" (
    echo [警告] GPT API Key 为空
)
if "!CLAUDE_KEY!"=="" (
    echo [警告] Claude API Key 为空
)
if "!GOOGLE_KEY!"=="" (
    echo [警告] Google API Key 为空
)
echo.

REM 第五步：备份原配置文件
echo ========================================
echo [步骤 5/7] 备份原配置文件
echo ========================================
echo.
set CONFIG_DIR=%USERPROFILE%\.clawdbot
set AGENT_CONFIG=%CONFIG_DIR%\agents\main\agent

if exist "%CONFIG_DIR%\clawdbot.json" (
    copy "%CONFIG_DIR%\clawdbot.json" "%CONFIG_DIR%\clawdbot.json.backup" >nul 2>&1
    echo [成功] 已备份 clawdbot.json
)

if exist "%AGENT_CONFIG%\auth-profiles.json" (
    copy "%AGENT_CONFIG%\auth-profiles.json" "%AGENT_CONFIG%\auth-profiles.json.backup" >nul 2>&1
    echo [成功] 已备份 auth-profiles.json
)
echo.

REM 第六步：修改主配置文件
echo ========================================
echo [步骤 6/7] 修改配置文件
echo ========================================
echo.
echo 正在生成配置文件...

REM 获取工作目录并转换路径
set "WORKSPACE_RAW=%USERPROFILE%\clawd"
set "WORKSPACE_JSON=!WORKSPACE_RAW:\=\\!"

REM 创建主配置文件
(
echo {
echo   "gateway": {
echo     "mode": "local"
echo   },
echo   "agents": {
echo     "defaults": {
echo       "workspace": "%WORKSPACE_JSON%",
echo       "models": {
echo         "api-proxy-gpt/gpt-4o": { "alias": "GPT-4o" },
echo         "api-proxy-claude/claude-sonnet-4-5-20250929": { "alias": "Claude Sonnet 4.5" },
echo         "api-proxy-google/gemini-3-pro-preview": { "alias": "Gemini 3 Pro" }
echo       },
echo       "model": {
echo         "primary": "api-proxy-claude/claude-sonnet-4-5-20250929"
echo       }
echo     }
echo   },
echo   "auth": {
echo     "profiles": {
echo       "api-proxy-gpt:default": { "provider": "api-proxy-gpt", "mode": "api_key" },
echo       "api-proxy-claude:default": { "provider": "api-proxy-claude", "mode": "api_key" },
echo       "api-proxy-google:default": { "provider": "api-proxy-google", "mode": "api_key" }
echo     }
echo   },
echo   "models": {
echo     "mode": "merge",
echo     "providers": {
echo       "api-proxy-gpt": {
echo         "baseUrl": "https://xuedingmao.top/v1",
echo         "api": "openai-completions",
echo         "models": [
echo           { "id": "gpt-4o", "name": "GPT-4o", "contextWindow": 128000, "maxTokens": 8192 }
echo         ]
echo       },
echo       "api-proxy-claude": {
echo         "baseUrl": "https://xuedingmao.top",
echo         "api": "anthropic-messages",
echo         "models": [
echo           { "id": "claude-sonnet-4-5-20250929", "name": "Claude Sonnet 4.5", "contextWindow": 200000, "maxTokens": 8192 }
echo         ]
echo       },
echo       "api-proxy-google": {
echo         "baseUrl": "https://xuedingmao.top/v1beta",
echo         "api": "google-generative-ai",
echo         "models": [
echo           { "id": "gemini-3-pro-preview", "name": "Gemini 3 Pro", "contextWindow": 2000000, "maxTokens": 8192 }
echo         ]
echo       }
echo     }
echo   }
echo }
) > "%CONFIG_DIR%\clawdbot.json"

if errorlevel 1 (
    echo.
    echo [错误] clawdbot.json 配置失败！
    echo [提示] 请检查是否有足够的磁盘空间和写入权限
    echo.
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)
echo [成功] 已更新 clawdbot.json
echo.

REM 创建鉴权配置文件
if not exist "%AGENT_CONFIG%" (
    mkdir "%AGENT_CONFIG%"
)

(
echo {
echo   "version": 1,
echo   "profiles": {
echo     "api-proxy-gpt:default": {
echo       "type": "api_key",
echo       "provider": "api-proxy-gpt",
echo       "key": "%GPT_KEY%"
echo     },
echo     "api-proxy-claude:default": {
echo       "type": "api_key",
echo       "provider": "api-proxy-claude",
echo       "key": "%CLAUDE_KEY%"
echo     },
echo     "api-proxy-google:default": {
echo       "type": "api_key",
echo       "provider": "api-proxy-google",
echo       "key": "%GOOGLE_KEY%"
echo     }
echo   },
echo   "lastGood": {
echo     "api-proxy-gpt": "api-proxy-gpt:default",
echo     "api-proxy-claude": "api-proxy-claude:default",
echo     "api-proxy-google": "api-proxy-google:default"
echo   }
echo }
) > "%AGENT_CONFIG%\auth-profiles.json"

if errorlevel 1 (
    echo.
    echo [错误] auth-profiles.json 配置失败！
    echo [提示] 请检查目录权限
    echo.
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)
echo [成功] 已更新 auth-profiles.json
echo.

REM 第七步：运行健康检查
echo ========================================
echo [步骤 7/7] 运行健康检查
echo ========================================
echo.
echo 正在检查配置...
echo.
call clawdbot doctor
echo.

REM 完成提示
echo.
echo ========================================
echo   安装配置完成！
echo ========================================
echo.
echo 配置文件位置：
echo   [主配置]  !CONFIG_DIR!\clawdbot.json
echo   [鉴权]    !AGENT_CONFIG!\auth-profiles.json
echo.
echo 中转站地址: xuedingmao.top
echo.
echo 下一步操作：
echo   1. 启动服务: clawdbot gateway
echo   2. 访问控制台: 
echo.
echo.

REM 使用 set /p 代替 choice 以提高兼容性
set /p START_NOW="是否现在启动 Gateway 服务? (Y/N): "
if /i "!START_NOW!"=="Y" (
    echo.
    echo 正在启动 clawdbot gateway...
    echo [提示] 启动后请访问 http://127.0.0.1:18789/
    echo [提示] 按 Ctrl+C 可停止服务
    echo.
    timeout /t 2 >nul
    call clawdbot gateway
    echo.
    echo Gateway 服务已停止
) else (
    echo.
    echo 您可以稍后手动运行: clawdbot gateway
    echo.
)

echo.
echo 安装配置完成，按任意键退出...
pause >nul

REM 全局错误捕获
goto :EOF

:ERROR_HANDLER
echo.
echo ========================================
echo   发生未预期的错误！
echo ========================================
echo.
echo 错误代码: %ERRORLEVEL%
echo.
echo 请检查：
echo   1. Node.js 是否正确安装
echo   2. 网络连接是否正常
echo   3. 是否有足够的磁盘空间
echo   4. 是否有必要的权限
echo.
echo 按任意键退出...
pause >nul
exit /b %ERRORLEVEL%