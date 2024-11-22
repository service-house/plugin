#!/bin/bash

# Function to determine OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     os=linux;;
        Darwin*)    os=darwin;;
        CYGWIN*)    os=windows;;
        MINGW*)     os=windows;;
        *)          os="unknown"
    esac
    echo $os
}

# Function to determine architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64)     arch=amd64;;
        arm64)      arch=arm64;;
        aarch64)    arch=arm64;;
        arm*)       arch=arm;;
        i386)       arch=386;;
        i686)       arch=386;;
        *)          arch="unknown"
    esac
    echo $arch
}

# Function to determine ARM version (if applicable)
detect_arm_version() {
    if [ "$(detect_arch)" = "arm" ]; then
        # This is a simplistic way to determine ARM version, may need more robust handling
        arm_version=$(uname -m | sed 's/armv\(.*\)\(.*\)/\1/')
        echo $arm_version
    else
        echo ""
    fi
}

download_myservers() {
  os=$(detect_os)
  arch=$(detect_arch)
  arm_version=$(detect_arm_version)

  if [ "$arm_version" != "" ]; then
      filename="${serverName}-${os}-${arch}${arm_version}"
  else
      filename="${serverName}-${os}-${arch}"
  fi
  base_url="http://qiniuyun.codeloverme.cn"

  # Full URL to the binary
  url="${base_url}/${filename}"

  # Download the binary
  echo "下载中，请不要关闭终端... $appPath from $url"
  curl  --progress-bar -o "$appPath" "$url"
  chmod +x $appPath
}

# Main script starts here
serverName=$1
app_dir=$2

if [ "$serverName" == "" ]; then
  serverName="myservers"
fi

# 检查密钥长度是否为32
if [ ${#secret_key} -ne 32 ]; then
    secret_key=$(generate_random_string 32)
fi

oldImg=`docker ps -a --filter ancestor=myservers/my_servers --format "{{.ID}}"`
if [ "$oldImg" != "" ]; then
  docker stop ${oldImg}
  docker rm ${oldImg}
fi

oldImg=`docker ps -a --filter ancestor=myservers/my_servers:dev --format "{{.ID}}"`
if [ "$oldImg" != "" ]; then
  docker stop ${oldImg}
  docker rm ${oldImg}
fi

ps aux | grep './myservers' | grep -v grep | awk '{print $2}' | xargs kill -9
download_myservers

cd ${app_dir}
./myservers &