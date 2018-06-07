#前提:系统开始栏搜索"powershell"以管理员权限启动,执行Set-ExecutionPolicy RemoteSigned,选择Y
#1.$trunkPath默认是当前脚本所在文件夹, 也可以文本编辑器打开CopyTrunk2Unit.ps1修改具体的$trunkPath目录
#2.a.可以右键菜单powershell执行;b.可以在powershell中直接输入文件路径执行;c.可以在cmd中以"powershell.exe -file ps1脚本路径执行"

"START..."
#$trunkPath = "E:\CODES\DEV\200 - mis\report\trunk"
$trunkPath = Split-Path -Parent $MyInvocation.MyCommand.Definition 
$trunkPath += "\trunk"

$allTrunkFiles = Get-ChildItem -LiteralPath $trunkPath -Recurse
$copyList=@()
$allTrunkFiles | Where-Object { $_.Length -ne $null } | foreach {
 if(-not $_.Name.toLower().EndsWith(".svn")){
     $trunkFilePath = $_.FullName
     $unitFilePath = $trunkFilePath.Replace("trunk","unit")
     if(Test-Path $unitFilePath){
        $trunkFileTime = $_.LastWriteTime
        $unitFileTime = (Get-Item $unitFilePath).LastWriteTime
        if($trunkFileTime -gt $unitFileTime){
            #"---trunk file lastwritetime gt unit file lastwritetime, override---"  
            "---Copy [$trunkFilePath] TO [$unitFilePath]---"
            Copy-Item -Path $trunkFilePath -Destination $unitFilePath -Force -Passthru
            $copyList+=$trunkFilePath
        }
     }else{
        #"---trunk file not exist in unit, copy---"
        "---Copy [$trunkFilePath] TO [$unitFilePath]---"
		 $null = New-Item -Path $unitFilePath -Type File -Force 
         Copy-Item -Path $trunkFilePath -Destination $unitFilePath -Force -Passthru
         $copyList+=$trunkFilePath
     }
 }
}
"=================================================================="
"-------------------------Total:"+$copyList.Count+"-----------------------------"
$copyList
"-------------------------Total:"+$copyList.Count+"-----------------------------"
"=================================================================="
"END..."
read-host