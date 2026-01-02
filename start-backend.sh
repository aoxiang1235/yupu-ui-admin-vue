#!/bin/bash

# 后端服务启动脚本（本地开发 + 服务器均可用）
# 使用方法: ./start-backend.sh {start|stop|restart|status|logs}
#
# 说明：
# - 不再写死 /root/java 路径，统一改为相对当前项目目录
# - 默认使用本地打包后的 yudao-server.jar 以守护进程方式运行
# - 如果还没打包 JAR，会给出清晰提示，避免默默失败

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
JAR_NAME="yudao-server.jar"
JAR_DIR="$BASE_DIR/ruoyi-vue-pro/yudao-server/target"
JAR_PATH="$JAR_DIR/$JAR_NAME"
RUNTIME_DIR="$BASE_DIR/java-runtime"
PID_FILE="$RUNTIME_DIR/yudao-server.pid"
LOG_FILE="$RUNTIME_DIR/logs/yudao-server.log"
PROFILE="${PROFILE:-local}"  # 默认使用 local，可通过环境变量 PROFILE 覆盖

# 创建运行与日志目录
mkdir -p "$RUNTIME_DIR/logs"

# 启动服务
start_service() {
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "服务已经在运行中，PID: $(cat "$PID_FILE")"
        return 1
    fi

    if [ ! -f "$JAR_PATH" ]; then
        echo "❌ 未找到 JAR 文件：$JAR_PATH"
        echo "请先执行以下命令打包后端服务："
        echo ""
        echo "  cd \"$BASE_DIR/ruoyi-vue-pro\""
        echo "  ./mvnw -pl yudao-server -am package"
        echo ""
        exit 1
    fi

    echo "正在启动后端服务..."
    echo "JAR文件: $JAR_PATH"
    echo "配置文件: $PROFILE"
    echo "日志文件: $LOG_FILE"

    # 启动服务（后台守护进程）
    nohup java -jar "$JAR_PATH" --spring.profiles.active="$PROFILE" > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"

    sleep 3

    if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "✅ 后端服务启动成功！"
        echo "PID: $(cat "$PID_FILE")"
        echo "日志: tail -f $LOG_FILE"
        echo "端口: 48080（默认 local 配置）"
    else
        echo "❌ 后端服务启动失败！"
        echo "请检查日志: $LOG_FILE"
        return 1
    fi
}

# 停止服务
stop_service() {
    if [ ! -f "$PID_FILE" ]; then
        echo "PID文件不存在，服务可能未运行"
        return 1
    fi

    PID="$(cat "$PID_FILE")"
    if ! kill -0 "$PID" 2>/dev/null; then
        echo "服务未运行"
        rm -f "$PID_FILE"
        return 1
    fi

    echo "正在停止后端服务 (PID: $PID)..."
    kill "$PID"

    for _ in {1..10}; do
        if ! kill -0 "$PID" 2>/dev/null; then
            echo "✅ 后端服务已停止"
            rm -f "$PID_FILE"
            return 0
        fi
        sleep 1
    done

    echo "强制停止服务..."
    kill -9 "$PID" 2>/dev/null
    rm -f "$PID_FILE"
    echo "✅ 后端服务已强制停止"
}

# 重启服务
restart_service() {
    echo "正在重启后端服务..."
    stop_service || true
    sleep 2
    start_service
}

# 查看服务状态
status_service() {
    if [ ! -f "$PID_FILE" ]; then
        echo "❌ 服务未运行（PID 文件不存在）"
        return 1
    fi

    PID="$(cat "$PID_FILE")"
    if kill -0 "$PID" 2>/dev/null; then
        echo "✅ 服务正在运行"
        echo "PID: $PID"
        if command -v lsof >/dev/null 2>&1; then
            echo "端口信息:"
            lsof -i:48080 || echo "  （未检测到 48080 端口占用，可能使用了其他配置文件）"
        fi
        if command -v ps >/dev/null 2>&1; then
            echo "内存使用: $(ps -p "$PID" -o rss= | awk '{print $1/1024 \"MB\"}')"
        fi
    else
        echo "❌ 服务未运行 (PID 文件存在但进程不存在)"
        rm -f "$PID_FILE"
    fi
}

# 查看日志
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "显示最近50行日志:"
        tail -n 50 "$LOG_FILE"
        echo ""
        echo "实时查看日志: tail -f $LOG_FILE"
    else
        echo "日志文件不存在: $LOG_FILE"
    fi
}

# 主逻辑
case "${1:-}" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service
        ;;
    status)
        status_service
        ;;
    logs)
        show_logs
        ;;
    *)
        echo "使用方法: $0 {start|stop|restart|status|logs}"
        echo ""
        echo "命令说明:"
        echo "  start   - 启动后端服务"
        echo "  stop    - 停止后端服务"
        echo "  restart - 重启后端服务"
        echo "  status  - 查看服务状态"
        echo "  logs    - 查看服务日志"
        exit 1
        ;;
esac



