import os

# 讀取 IP 地址列表
def ReadServerList(file_path):
    with open(file_path, 'r') as file:
        ServerList = file.read().splitlines()
    return ServerList

def GenerateConfig(ServerList, OutputDirectory) -> None:
    if not os.path.exists(OutputDirectory):
        os.makedirs(OutputDirectory)
    
    for Server in ServerList:
        ConfigContent = Format.format(endpoint=f"{Server}")
        ConfigFilename = os.path.join(OutputDirectory, f"CloudFlare-{Server.replace(":", "_")}.conf")
        with open(ConfigFilename, 'w') as ConfigFile:
            ConfigFile.write(ConfigContent)

# WireGuard 配置模板
Format = """
[Interface]
PrivateKey = +K+/uZI9cYAYQPLtw3JVNt0VF4F82gzcjRZvkRfAo1k=
Address = 172.16.0.2/32, 2606:4700:110:8100:8d1f:be40:d840:b4f8/128
DNS = 1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001
MTU = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = {endpoint}
"""

# 輸入文件名
ServerFilePath = input("請輸入 IP 地址列表文件名 [TXT]: ")
OutputDirectory = input("請輸入配置文件輸出目錄名 [Config]: ")
ServerAddress = ReadServerList(ServerFilePath)
GenerateConfig(ServerAddress, OutputDirectory)
print(f"生成了 {len(ServerAddress)} 個配置文件在 {OutputDirectory} 文件夾中。")
