# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# project relates exports
export bbhistory=~/sw.bb.history

function versionupdate() {
    export bldversion=`head -n 1 ${bbhistory} | awk -F= '{printf "%03d", ++$2 % 1000}'`
}

export glob=/repo/yongwu/glob
export globcore=brugal/fwlt-c
export globbin=uglob
export sw=/repo/yongwu/sw
export board=fwlt-c
export oamip=10.9.69.237
export swbuildlog=~/board.make.log
export globcfg=vobs/dsl/sw/flat/BUILDCFG/extRepo/GponGlob_glob.cfg
export buildserver=yongwu@172.24.213.197

# update bld version
versionupdate

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
alias psmyself='ps -ef | egrep `whoami`[[:space:]]+[[:digit:]]+'

alias sshbuildserver='ssh ${buildserver}'
alias buildlog='tail -f ${swbuildlog}'
alias tftpoam='tftp ${oamip}'
alias cdsw='cd ${sw}'
alias cdbuild='cd ${sw}/build/${board}/OS'
alias cdbuildme='cd /repo/yongwu/buildme'
alias cdglob='cd $glob'
alias cdglobbld='cd ${glob}/build/${globcore}/glob'
alias ctagsglob='ctagsrepository $glob glob'
alias ctagssw='ctagsrepository $sw sw'
alias viglob='ctagsglob && pushd $glob && vi . && popd'
alias vicpptaste='pushd ~/cpptaste && vi main.cpp && popd'

alias swgrep='grep -i --include=\*.{c,h,cc,cpp,hh,hpp} -rn ${sw} -e'
alias swgrepheader='grep -i --include=\*.{h,hh,hpp} -rn ${sw} -e'
alias swgrepimplementation='grep -i --include=\*.{c,cc,cpp} -rn ${sw} -e'

alias globgrep='grep -i --include=\*.{c,h,cc,cpp,hh,hpp} -rn ${glob} -e'
alias globgrepheader='grep -i --include=\*.{h,hh,hpp} -rn ${glob} -e'
alias globgrepimplementation='grep -i --include=\*.{c,cc,cpp} -rn ${glob} -e'
alias globmakelinux='globmake E=LINUX'

PATH=$PATH:$HOME/.local/bin:$HOME/bin:/ap/local/Linux_x86_64/shell

export PATH

function ltshell() {
    ltip=127.0.17.${1:2:2}
    port="5022"
    [ -z "$2" ] || port=$2
    
    expscript=~/.ltshell.expect
    echo "#!/usr/bin/expect" > ${expscript}
    echo set timeout 30 >> ${expscript}
    echo spawn octopus STDIO ${oamip}:udp:23 >> ${expscript} 
    echo "send \"\\r\\r\"" >> ${expscript}
    echo expect \"*ogin:\" >> ${expscript}
    echo "send \"shell\\r\"" >> ${expscript}
    echo expect \"*assword:\" >> ${expscript}
    echo "send \"nt\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo "send \"eqpt displayasam -s\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo "send \"natp del_tcp ${port}\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo "send \"natp add_tcp ${port} ${ltip} 22\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo exit >> ${expscript}
    expect -f ${expscript}

    sleep 5
    echo " "
    echo "connect to lt $1 with $port"
    
    echo "#!/usr/bin/expect" > ${expscript}
    echo set timeout 30 >> ${expscript}
    echo spawn ssh -oPort=${port} -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@${oamip} >> ${expscript}
    echo "send \"\\r\\r\"" >> ${expscript}
    echo expect \"*assword:\" >> ${expscript}
    echo "send \"2x2=4\\r\"" >> ${expscript}
    echo interact >> ${expscript}
    expect -f ${expscript}   
}

function pushdinalias() {
    eval pushd `alias $1 | awk -F= '{print $2}' | awk '{print $2}' | sed "s/'$//"`
}

function clioam() {
    expscript=~/.cli.expect
    clipwd="      "
    [ -z "$1" ] || clipwd=$1
    echo "#!/usr/bin/expect" > ${expscript}
    echo set timeout 30 >> ${expscript}
    # another way to login is using "telnet ${oamip}"
    echo spawn ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -l isadmin ${oamip} >> ${expscript} 
    echo expect \"*assword:\" >> ${expscript}
    echo "send \"${clipwd}\\r\"" >> ${expscript}
    echo interact >> ${expscript}
    expect -f ${expscript}
}

function ntoam() {
    expscript=~/.ntoam.expect
    echo "#!/usr/bin/expect" > ${expscript}
    echo set timeout 30 >> ${expscript}
    echo spawn octopus STDIO ${oamip}:udp:23 >> ${expscript} 
    echo "send \"\\r\\r\"" >> ${expscript}
    echo expect \"*ogin:\" >> ${expscript}
    echo "send \"shell\\r\"" >> ${expscript}
    echo expect \"*assword:\" >> ${expscript}
    echo "send \"nt\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo "send \"eqpt displayasam -s\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo interact >> ${expscript}
    expect -f ${expscript}
}

function ltoam() {
    expscript=~/.ltoam.expect
    echo "#!/usr/bin/expect" > ${expscript}
    echo set timeout 30 >> ${expscript}
    echo spawn octopus STDIO ${oamip}:udp:23 >> ${expscript} 
    echo "send \"\\r\\r\"" >> ${expscript}
    echo expect \"*ogin:\" >> ${expscript}
    echo "send \"shell\\r\"" >> ${expscript}
    echo expect \"*assword:\" >> ${expscript}
    echo "send \"nt\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo "send \"eqpt displayasam -s\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo "send \"rcom exec -b $1 -c login kill 0\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo "send \"login board $1\\r\"" >> ${expscript}
    echo expect \"]\>\" >> ${expscript}
    echo interact >> ${expscript}
    expect -f ${expscript}
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

function recordbb() {
    sed -i "1s/[0-9]\+/${bldversion}/g" ${bbhistory}

    echo -e "\n---------------------------------------\n" >> ${bbhistory}
    echo "bldversion:" ${bldversion} >> ${bbhistory}
    echo "sw changeset:" >> ${bbhistory}
    hg parents --repository ${sw} >> ${bbhistory}
    echo "changes:" >> ${bbhistory}
    hg diff -b --repository ${sw} >> ${bbhistory}
    echo -e "\n---------------------------------------\n" >> ${bbhistory}

    versionupdate
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

# libs needed for FWLT-C
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/gpongem/lib/:/home/yongwu/lib/

PS1='`pwd` \$'

