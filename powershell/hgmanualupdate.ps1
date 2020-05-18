"hg manual update, used for windows, to skip case-foldings"

if (0 -lt $args.count)
{
	if (1 -lt $args.count)
	{
		"pull incomings from server $args[1]"
		hg pull $args[1]
	}
	
    $target=$args[0]
}
else
{
	$target="tip"
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
