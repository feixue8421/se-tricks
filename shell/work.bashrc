# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# project relates exports
export glob=/repo/yongwu/glob
export globcore=brugal/fwlt-c
export globbin=uglob
export sw=/repo/yongwu/sw
export board=fwlt-c
export swbuildlog=~/board.make.log
export globcfg=vobs/dsl/sw/flat/BUILDCFG/extRepo/GponGlob_glob.cfg
export buildserver=yongwu@172.24.213.197
export autoctags=auto.generated.ctags

# User specific aliases and functions
alias ll='ls -lh'
alias startvnc='start_vnc 1920x1080'
alias stopvnc='vncserver -list | grep '\''^:'\'' | awk '\''{print $1}'\'' | xargs -r -L 1 vncserver -kill'
alias brcacheclean='pushd ${sw}/build/reborn && ll | egrep "br-[0-9a-f]{24}" | sort -rd | sed "1,2d" | awk '\''{print $9}'\'' | xargs -r -L 1 rm -rf && popd'
alias findbyname='find ./ -name'
alias agrep='alias | grep'
alias hgrep='history | grep'
alias lgrep='ll | grep'
alias fgrep='cat ~/.bashrc | grep "^# usage: " | grep'
alias pwdgrep='grep -rn . -e'
alias echoglob='echo glob:${glob} globcore:${globcore} globbin:${globbin}'
alias echoboard='echo sw:${sw} board:${board} bldversion:${bldversion}'
alias echoboardsw='cat ~/board.sw | sed -n "/DESCRIPTION.*${board^^}/,/END/p"'
alias echooamip='echo oamip:${oamip}'
alias shrefresh='source ~/.bashrc'
alias topmyself='top -c -u `whoami`'
alias oamipbmt='export oamip=135.251.214.105' #135.251.192.162 135.251.214.211
alias oamiplab='export oamip=10.9.69.237'

alias httpserver='nohup http-server ${buildserver##*@} 8421 /home/yongwu/httphome/ >/dev/null 2>&1 &'
alias sshbuildserver='ssh ${buildserver}'
alias buildlog='tail -f ${swbuildlog}'
alias cdsw='cd ${sw}'
alias cdbuild='cd ${sw}/build/${board}/OS'
alias cdglob='cd $glob'
alias cdglobbld='cd ${glob}/build/${globcore}/glob'
alias viglob='pushd $glob && pwdctags && vi OS/gltdMain.cpp && popd'
alias swlog='hg log -b . --graph --repository=$sw'
alias globlog='hg log -b . --graph --repository=$glob'
alias synclog='rsync -rci --delete-after $buildserver:/users/yongwu* ~/logs/'
alias globmakelinux='globmake E=LINUX'
alias expectexecute='expexecute "$expprefix" "$expcommand" "$exppostfix"'
alias ntcraft='fxcraft 2001 01'
alias ltgici='fxcraft 4002 02'
alias scp='scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null'
alias a2assh='sshexpect root 135.251.202.220 2x2=4 923'

PATH=$PATH:$HOME/.local/bin:$HOME/bin:/ap/local/Linux_x86_64/shell

export PATH

oamiplab

function pushdinalias() {
    eval pushd `alias $1 | awk -F= '{print $2}' | awk '{print $2}' | sed "s/'$//"`
}

export expectnt='
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
function expexecute() {
    expect -c "`(echo $1 && echo $2 && echo $3) | envsubst`"
}

# usage: sshexpect <user> <ip> <password> <port> <command>
function sshexpect() {
    expprefix="
        set timeout 15;
        spawn ssh -oPort=${4:-22} -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $1@$2;
        send \"\r\r\";
        expect \"*assword:\";
        send \"$3\r\";
    "
    expcommand=""
    exppostfix="${5:-interact;}"
    expectexecute
}

# usage: ltshell <lt> <port> <command>
function ltshell() {
    ltip=127.0.17.$((16#${1:2:2}))
    port=${2:-5022}

    expprefix=$expectnt
    expcommand="
        send \"natp del_tcp ${port}\r\";
        expect \"]\>\";
        send \"natp add_tcp ${port} ${ltip} 22\r\";
        expect \"]\>\";
    "
    exppostfix='exit;'
    expectexecute

    sleep 5
    echo " " && echo "connect to lt $1 with $port"
    sshexpect root $oamip 2x2=4 $port "$3"
}

# usage: clioam
function clioam() {
    # another way to login is using "telnet ${oamip}"
    IFSBAK=$IFS
    IFS=$(echo -en "\n\b")
    sshexpect isadmin $oamip "${1:-isamcli!}"
    IFS=$IFSBAK
}

# usage: ntoam
function ntoam() {
    expprefix=$expectnt && expcommand='' && exppostfix='interact;' && expectexecute
}

# usage: fxcraft <sshport> <piport>
function fxcraft() {
    piip=135.251.192.71
    portrestart="
        expect \"*pi@raspberry*\";
        send \"./kill${2}.sh\r\";
        expect \"*pi@raspberry*\";
        send \"./ps${2}.sh\r\";
        expect \"*pi@raspberry*\";
        exit;
    "
    sshexpect pi $piip '1qaz!QAZ' 22 "${portrestart}"
    telnet $piip $1
}

# usage: ltoam <lt> <command>
function ltoam() {
    expprefix=$expectnt
    expcommand="
        send \"rcom exec -b $1 -c login kill 0\r\";
        expect \"]\>\";
        sleep 5;
        send \"login board $1\r\r\";
        expect \"lt*$1*]\>\" \\n timeout { exit 1 };
    "
    exppostfix="${2:-interact;}"
    expectexecute
}

# usage: setboard <board>
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

# usage: showchangesets <revid>
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

# usage: swmake <arg>...
function swmake() {
    pushdinalias cdbuild
    nohup docker-make IVY=ivy BUILDROOT_CACHE_ENABLE=1 $@ VERS=${bldversion} -j24 >${swbuildlog} 2>&1 &
    popd

    buildlog --pid=$!
}

# usage: globmake <arg>...
function globmake() {
    pushdinalias cdglobbld
    make $@
    popd
}

# usage: hgupdateglob
function hgupdateglob() {
    swglobcfg=${sw}/$globcfg

    echo before update...
    cat ${swglobcfg}

    newversion=`hg parents --template "{node}" --repository ${glob}`
    sed -i "s/[0-9a-f]\{40\}/$newversion/g;/HG_SERVER/d;/REPO=/a HG_SERVER=ssh://builder@${buildserver##*@}//repo/yongwu" ${swglobcfg}

    echo after update...
    cat ${swglobcfg}

    echo sw/GponGlob/glob removed if exists
    rm -rf ${sw}/src/GponGlob/glob
}

# usage: updaterepository
function updaterepository() {
    sshbuildserver hg pull --repository=$sw
    sshbuildserver hg pull --repository=$glob

    hg pull --repository=$sw
    hg pull --repository=$glob
}

# usage: synchronizebuildserver
function synchronizebuildserver() {
    cmd="rsync -rci --delete-after"
    $cmd $buildserver:~/.bashrc ~/se-tricks/shell/work.bashrc
    $cmd $buildserver:~/.vimrc ~/se-tricks/shell/work.vimrc
    $cmd $buildserver:$sw/.hg/localtags $sw/.hg/localtags
    $cmd $buildserver:$glob/.hg/localtags $glob/.hg/localtags

    shrefresh
}

# usage: where
function where() {
    [ "yongwu" = `whoami` ] && echo ON BUILDSERVER || echo ON LOCAL
}

# usage: globprepush
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

# usage: bmtrepository
function bmtrepository() {
    hg update --repository=$sw bmt_isr64_typeb
    hg update --repository=$glob bmt_isr64_glob_typeb
}

# usage: updateltblackbuild <IMAGE> <LT> [<BUILD>]
function updateltblackbuild() {
    while echo "==================updateltblackbuild start=================="
    do
        [ -z "$3" ] && swmake
        tail -n 1 $swbuildlog | grep rror && break
        echo "==================SW make successfully=================="

        pushdinalias cdbuild
        expect -c "
            set timeout 300;
            spawn tftp $oamip;
            expect \">\" { send \"b\r\" }
            expect \">\" { send \"put images/${1:0:-3}${bldversion} /ONT/Sw/$1\r\" }
            expect \">\" { send \"q\r\" }
            expect eof
        " | grep rror && popd && break
        popd
        echo "==================Update Binarry successfully=================="

        ltoam $2 'send "err poweron\r";sleep 5;exit;' || break
        echo "==================Reboot initialized=================="
        break
    done
    echo "==================updateltblackbuild done=================="
}

# usage: pwdctags
function pwdctags() {
    ctagfile="`pwd | md5sum | cut -c1-12`_`hg parent --template '{short(node)}' 2>/dev/null || echo norepository`.ctags"
    ctagfolder=~/.ctags
    ctagfile=$ctagfolder/$ctagfile
    [ -f $ctagfile ] || ctags -f - --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -R "`pwd`" > $ctagfile

    touch $ctagfile
    ln -s -f $ctagfile $autoctags

    pushd $ctagfolder
    ls -t1 | sed '1,5d' | xargs -r -L 1 rm
    popd
}

# usage: generateontcfg 1/1/7/1 10 100 2
# usage: generateontcfg 1/1/7/1 10 100 2 ng2:1/1
function generateontcfg() {
    chpair=$1
    ont=${5:-$chpair}
    vlan=$3
    for ((idx=$2;idx<$2+$4;idx++))
    do
        cat <<-ECHOEOF
configure equipment ont interface ${ont}/$idx ${5:+pref-channel-pair $chpair} sernum ALCL:ABCD00$idx sw-ver-pland disabled
configure equipment ont interface ${ont}/$idx admin-state up
configure equipment ont slot ${ont}/$idx/1 planned-card-type ethernet plndnumdataports 4 plndnumvoiceports 0
configure equipment ont slot ${ont}/$idx/1 admin-state up
configure interface port uni:${ont}/$idx/1/1 admin-up
configure qos interface ${5:+uni:}${ont}/$idx/1/1 upstream-queue 0 bandwidth-profile name:1G bandwidth-sharing uni-sharing
configure bridge port ${ont}/$idx/1/1 max-unicast-mac 128
configure vlan id $vlan mode residential-bridge in-qos-prof-name name:Default_TC0
configure bridge port ${ont}/$idx/1/1 vlan-id $vlan tag single-tagged
ECHOEOF

    vlan=$(($vlan+1))
done
}

export bbhistory=~/sw.bb.history

function bldversionupdate() {
    if [ ! -f $bbhistory ]; then
        echo latest=017 > $bbhistory
    fi
    export bldversion=`head -n 1 ${bbhistory} | awk -F= '{printf "%03d", ++$2 % 1000}'`

    if [ `grep -cxe '--*' $bbhistory` -gt 10 ]; then
        grep -nxe '--*' $bbhistory | head -n2 | cut -d: -f1 | paste -s | awk '{print $1 - 1 "," $2 "d"}' | xargs -I% sed -ie '%' $bbhistory
    fi
}

function recordbb() {
    sed -i "1s/[0-9]\+/${bldversion}/g" ${bbhistory}

    cat <<-CATEOF >> $bbhistory

---------------------------------------
bldversion: ${bldversion}
sw changeset: `hg parents --repository ${sw} --template "{node}"`
changes:
`hg diff -b --repository ${sw}`
---------------------------------------
CATEOF

    bldversionupdate
}

# libs needed for FWLT-C
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/gpongem/lib/:/home/yongwu/lib/

bldversionupdate

PS1='`pwd` \$'

