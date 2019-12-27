"synchronise files between linux server and local backups"

$server="yongwu@172.24.213.197"
$files=".bashrc",".vimrc"
$prefix="work"

pushd "c:\repository\se-tricks\shell"

foreach ($file in $files)
{
    "-----------------------------------------------"
    "synchronise $file ..."
    $local=get-filehash "work$file" -algorithm MD5
    ($local -match "(?<md5>[0-9a-zA-Z]{32})") | out-null
    $local = $matches['md5']
    "local: $local"

    $remote=ssh $server md5sum "~/$file"
    "remote: $remote"

    if ($remote -imatch $local)
    {
        "no need to update $file"
    }
    else
    {
        scp ($server + ":~/$file") "$prefix$file"
    }
    "-----------------------------------------------"
}

popd

"synchronise done !!"
