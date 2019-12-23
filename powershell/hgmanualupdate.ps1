"hg manual update, used for windows, to skip case-foldings"
"pull incomings from server"
hg pull

$target="tip"
if ($args.count > 0)
{
    $target=$args[0]
}

$current=hg parents --template "{node}"
$target=hg log -r $target --template "{node}"

if ($current -ne $target)
{
    "update from $current to $target at $(get-date)"
    hg debugsetparents $target
    hg debugrebuildstate
    hg revert --no-backup -I **/*.h -I **/*.hh -I **/*.hpp -I **/*.c -I **/*.cc -I **/*.cpp -I **/makefile -I **/*.xml -I **/*.json
}

"update finished at $(get-date)"
