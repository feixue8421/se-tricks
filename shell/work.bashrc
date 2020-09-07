# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# project relates exports
export bbhistory=~/sw.bb.history
export glob=/repo/yongwu/glob
export globcore=brugal/fwlt-c
export globbin=uglob
export sw=/repo/yongwu/sw
export board=fwlt-c
export swbuildlog=~/board.make.log
export globcfg=vobs/dsl/sw/flat/BUILDCFG/extRepo/GponGlob_glob.cfg
export buildserver=yongwu@172.24.213.197
export bldversion=017


# User specific aliases and functions
alias ll='ls -lh'
alias startvnc='start_vnc 1920x1080'
alias stopvnc='vncserver -list | grep '\''^:'\'' | awk '\''{print $1}'\'' | xargs -r -L 1 vncserver -kill'
alias brcacheclean='pushd ${sw}/build/reborn && ll | egrep "br-[0-9a-f]{24}" | sort -rd | sed "1,2d" | awk '\''{print $9}'\'' | xargs -r -L 1 rm -rf && popd'
alias findbyname='find ./ -name'
alias agrep='alias | grep'
alias hgrep='history | grep'
alias lgrep='ll | grep'
alias pwdgrep='grep -rn . -e'
alias echoglob='echo glob:${glob} globcore:${globcore} globbin:${globbin}'
alias echoboard='echo sw:${sw} board:${board} bldversion:${bldversion}'
alias echooamip='echo oamip:${oamip}'
alias shrefresh='source ~/.bashrc'
alias topmyself='top -c -u `whoami`'
alias oamipbmt='export oamip=135.251.192.162' #'135.251.214.211'
alias oamiplab='export oamip=10.9.69.237'


alias sshbuildserver='ssh ${buildserver}'
alias buildlog='tail -f ${swbuildlog}'
alias tftpoam='tftp ${oamip}'
alias cdsw='cd ${sw}'
alias cdbuild='cd ${sw}/build/${board}/OS'
alias cdglob='cd $glob'
alias cdglobbld='cd ${glob}/build/${globcore}/glob'
alias ctagsglob='ctagsrepository $glob glob'
alias ctagssw='ctagsrepository $sw sw'
alias viglob='ctagsglob && pushd $glob && vi . && popd'
alias swlog='hg log -b . --graph --repository=$sw'
alias globlog='hg log -b . --graph --repository=$glob'

alias globmakelinux='globmake E=LINUX'

PATH=$PATH:$HOME/.local/bin:$HOME/bin:/ap/local/Linux_x86_64/shell

export PATH

oamiplab

function pushdinalias() {
    eval pushd `alias $1 | awk -F= '{print $2}' | awk '{print $2}' | sed "s/'$//"`
}

function _baseexpect() {
    echo '
        set timeout 30;
        spawn octopus STDIO ${oamip}:udp:23;
        send "\r\r";
        expect "*ogin:";
        send "shell\r";
        expect "*assword:";
        send "nt\r";
        expect "]\>";
        send "eqpt displayasam -s\r";
        expect "]\>";
    '
}

# usage: sshexpect <user> <ip> <password> <port>
function sshexpect() {
    _port="22"
    [ -z "$4" ] || _port=$4

    expect -c "
        set timeout 30
        spawn ssh -oPort=${_port} -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $1@$2
        send \"\r\r\"
        expect \"*assword:\"
        send \"$3\r\"
        interact
    "
}

function ltshell() {
    export expltip=127.0.17.$((16#${1:2:2}))
    port="5022"
    [ -z "$2" ] || port=$2
    export expport=$port

    export expmorecommand='
        send "natp del_tcp ${expport}\r"
        expect "]\>"
        send "natp add_tcp ${expport} ${expltip} 22\r"
        expect "]\>"
        exit
    '
    expect -c "`(_baseexpect && echo $expmorecommand) | envsubst`"

    sleep 5
    echo " "
    echo "connect to lt $1 with $port"

    sshexpect root $oamip 2x2=4 $port
}

function clioam() {
    # another way to login is using "telnet ${oamip}"
    expect -c "
        set timeout 30
        spawn ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -l isadmin ${oamip}
        expect \"*assword:\"
        send \"      \r\"
        interact
    "
}

function ntoam() {
    expect -c "`(_baseexpect && echo 'interact;') | envsubst`"
}

function ltoam() {
    export expltboard=$1
    export expmorecommand='
        send "rcom exec -b ${expltboard} -c login kill 0\r";
        expect "]\>";
        sleep 5;
        send "login board ${expltboard}\r";
        expect "]\>";
        interact;
    '
    expect -c "`(_baseexpect && echo $expmorecommand) | envsubst`"
}

function setboard() {
    echo before update...
    echoboard
    echoglob

    export board=$1
    export globcore=`grep FPGA_ARCH_${board} ${sw}/vobs/dsl/sw/flat/GponGlob/module.mk | awk -F= '{print $2}' | sed 's/^\s*//'`
    export globbin=`grep TARGET_${board} ${sw}/vobs/dsl/sw/flat/GponGlob/module.mk | awk -F= '{print $2}' | sed 's/^\s*//' | sed 's/\$.*/\-METH\.bin/'`

    echo after update...
    echoboard
    echoglob

    echo update done
}

function showchangesets() {
    pushd $sw
    echo sw changeset:
    hg log -r $1

    echo glob changeset in sw:
    hg cat $globcfg -r $1

    revision=`hg cat $globcfg -r $1 | grep ^REVISION | awk -F= '{print $2}'`
    popd

    echo glob changeset:
    hg log -r ${revision} --repository ${glob}


    if [ -n "$2" ]; then
        hg tag -l -r $1 --repository=$sw $2
        hg tag -l -r $revision --repository=$glob $2
    fi
}

function swmake() {
    pushdinalias cdbuild
    nohup docker-make IVY=ivy BUILDROOT_CACHE_ENABLE=1 $@ VERS=${bldversion} -j24 >${swbuildlog} 2>&1 &
    popd

    buildlog --pid=$!
}

function globmake() {
    pushdinalias cdglobbld
    make $@
    popd
}

function hgupdateglob() {
    swglobcfg=${sw}/$globcfg

    echo before update...
    cat ${swglobcfg}

    echo "[GponGlob/glob]" > ${swglobcfg}
    echo "REPO=glob" >> ${swglobcfg}
    echo `hg parents --template "REVISION={node}" --repository ${glob}` >> ${swglobcfg}
    echo "SUBDIR=glob" >> ${swglobcfg}
    echo "HG_SERVER=/repo/yongwu" >> ${swglobcfg}

    echo after update...
    cat ${swglobcfg}

    echo sw/GponGlob/glob removed if exists
    rm -rf ${sw}/src/GponGlob/glob
}

function ctagsrepository() {
    revision=`hg parents --template "{node}" --repository $1`
    revisiontag=~/.ctags/$2.${revision}.ctags
    targettag=$2.ctags
    if [ ! -f $revisiontag ]; then
        ctags -f - --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -R $1 > $revisiontag
    fi

    pushd ~
    ln -s -f $revisiontag $targettag
    popd
}

function updaterepository() {
    sshbuildserver hg pull --repository=$sw
    sshbuildserver hg pull --repository=$glob

    hg pull --repository=$sw
    hg pull --repository=$glob
}

function synchronizebuildserver() {
    cmd="rsync -rci --delete-after"
    $cmd $buildserver:~/.bashrc /mnt/c/Repository/se-tricks/shell/work.bashrc
    $cmd $buildserver:~/.vimrc /mnt/c/Repository/se-tricks/shell/work.vimrc
    $cmd $buildserver:$sw/.hg/localtags $sw/.hg/localtags
    $cmd $buildserver:$glob/.hg/localtags $glob/.hg/localtags
    $cmd $buildserver:~/cpptaste/ /mnt/c/Repository/se-tricks/cpp/linux/

    shrefresh
}

function where() {
    if [ "yongwu" = `whoami` ]; then
        echo ON BUILDSERVER
    else
        echo ON LOCAL
    fi
}

function globprepush() {
    pushdinalias cdglob
    for ((idx=0;idx<10;idx++))
    do
        echo ---------------------------- $(($idx+1)) ----------------------------
        build/pre_push.sh && echo **************** prepush succeeded!! **************** &&  break
        sleep 5s
    done
    popd
}

function bmtrepository() {
    hg update --repository=$sw bmt_sw6203_typeb
    hg update --repository=$glob bmt_glob6203_typeb
}

function updateltblackbuild() {
    pushdinalias cdbuild

    expect -c "
        set timeout 120;
        spawn tftp $oamip;
        expect \">\" { send \"b\r\" }
        expect \">\" { send \"put images/${1:0:-3}${bldversion} /ONT/Sw/$1\r\" }
        expect \">\" { send \"q\r\" }
        expect eof
    "
    popd

    ltoam $2
}

# libs needed for FWLT-C
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/gpongem/lib/:/home/yongwu/lib/

PS1='`pwd` \$'

