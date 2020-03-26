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
alias shscreen='screen -r `screen -ls | grep Detached | awk '\''{print $1}'\''`'
alias topmyself='top -c -u `whoami`'
alias psmyself='ps -ef | egrep `whoami`[[:space:]]+[[:digit:]]+'

alias buildlog='tail -f ${swbuildlog}'

alias tftpoam='tftp ${oamip}'

alias cdsw='cd ${sw}'
alias cdbuild='cd ${sw}/build/${board}/OS'
alias cdbuildme='cd /repo/yongwu/buildme'
alias cdglob='cd $glob'
alias cdglobbld='cd ${glob}/build/${globcore}/glob'
alias ctagsglob='ctags -f ~/glob.ctags --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -R $glob'
alias viglob='pushd $glob && vi OS/gltdMain.c && popd'

alias swgrep='grep -i --include=\*.{c,h,cc,cpp,hh,hpp} -rn ${sw} -e'
alias swgrepheader='grep -i --include=\*.{h,hh,hpp} -rn ${sw} -e'
alias swgrepimplementation='grep -i --include=\*.{c,cc,cpp} -rn ${sw} -e'

alias globgrep='grep -i --include=\*.{c,h,cc,cpp,hh,hpp} -rn ${glob} -e'
alias globgrepheader='grep -i --include=\*.{h,hh,hpp} -rn ${glob} -e'
alias globgrepimplementation='grep -i --include=\*.{c,cc,cpp} -rn ${glob} -e'

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

function hgbackup() {
    dates=`date "+%Y%m%d%H%M%S"`
    versions=`hg parents --template "{basename(reporoot)}.{short(node)}"`
    hg diff -b > ~/diffs/${versions}.${dates}.diff
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
    export globcore=`grep FPGA_ARCH_${board} ${sw}/vobs/dsl/sw/flat/GponGlob/Makefile | awk -F= '{print $2}' | sed 's/^\s*//'`
    export globbin=`grep TARGET_${board} ${sw}/vobs/dsl/sw/flat/GponGlob/Makefile | awk -F= '{print $2}' | sed 's/^\s*//' | sed 's/\$.*/\-METH\.bin/'`

    echo after update...
    echoboard
    echoglob
    
    echo update done
}

function showchangesets() {
    pushd ${sw}
    echo sw changeset: 
    hg log -r "ancestor($1)"

    echo glob changeset: 
    hg cat vobs/dsl/sw/flat/BUILDCFG/extRepo/GponGlob_glob.cfg -r "ancestor($1)"

    revision=`hg cat vobs/dsl/sw/flat/BUILDCFG/extRepo/GponGlob_glob.cfg -r "ancestor($1)" | grep REVISION | awk -F= '{print $2}'`
    popd
    
    hg log -r ${revision} --repository ${glob}
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
    globcfg=${sw}/vobs/dsl/sw/flat/BUILDCFG/extRepo/GponGlob_glob.cfg
    
    echo before update...
    cat ${globcfg} 
    
    echo "[GponGlob/glob]" > ${globcfg}
    echo "REPO=glob" >> ${globcfg}
    echo `hg parents --template "REVISION={node}" --repository ${glob}` >> ${globcfg}
    echo "SUBDIR=glob" >> ${globcfg}
    echo "HG_SERVER=/repo/yongwu" >> ${globcfg}

    echo after update...
    cat ${globcfg}

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

# libs needed for FWLT-C
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/gpongem/lib/:/home/yongwu/lib/

PS1='`pwd` \$'

