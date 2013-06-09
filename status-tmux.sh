#!/bin/bash
#tmux console status bar file
TIMING=0.1
net_if="enp10s0"

memory()
{
	sys_mem="`free -h | grep '\-/+' | awk {'print $3'}`"
	sys_mem_b="`free -b | grep "\-/+" | awk {'print $3'}`"
	sys_tot="`free -h | grep "Mem:" | awk {'print $2'}`"
	sys_tot_b="`free -b | grep "Mem:" | awk {'print $2'}`"
	taux=$(( (( ($sys_mem_b) * 100)) / ($sys_tot_b) ))
	echo "MEM $sys_mem""iB/$sys_tot""iB"
}
processor()
{
	sys_cpu=$(eval $(awk '/^cpu /{print "previdle=" $5 ";prevtotal=" $2+$3+$4+$5 }' /proc/stat);
	sleep 0.4;
	eval $(awk '/^cpu /{print "idle=" $5 "; total=" $2+$3+$4+$5 }' /proc/stat);
	intervaltotal=$((total-${prevtotal:-0}));
	echo "$((100*( (intervaltotal) - ($idle-${previdle:-0}) ) / (intervaltotal) ))")
	echo "CPU $sys_cpu%"
}
netstat()
{
	net_upload_1=$(cat /sys/class/net/$net_if/statistics/tx_bytes)
	net_download_1=$(cat /sys/class/net/$net_if/statistics/rx_bytes)
	sleep 0.5
	net_upload_2=$(cat /sys/class/net/$net_if/statistics/tx_bytes)
	net_download_2=$(cat /sys/class/net/$net_if/statistics/rx_bytes)
	net_upload=$(( ((net_upload_2 - net_upload_1)) / 512 ))
	net_download=$(( ((net_download_2 - net_download_1)) / 512 ))
	net_oper=$(cat /sys/class/net/$net_if/operstate)
	echo "UP $net_upload""Kbp/s"" DOWN $net_download""Kbp/s"
}
battery()
{
	charge_current="$(cat /sys/class/power_supply/BAT0/charge_now)"
	charge_full="$(cat /sys/class/power_supply/BAT0/charge_full)"
	charge="$((((($charge_current)*100))/($charge_full)))"
	echo "BAT $charge%"
}
statustext()
{
	echo "$(battery)::$(processor)::$(memory)::$(netstat)"
}
statustext
