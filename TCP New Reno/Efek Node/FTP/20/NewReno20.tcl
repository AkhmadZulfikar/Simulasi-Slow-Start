# Define options
Phy/WirelessPhy set bandwidth_ 11Mb                ;
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type

set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             20                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              1000                       ;# X dimension of topography
set val(y)              1000                       ;# Y dimension of topography
set val(stop)           60                         ;# time of simulation end

set ns            [new Simulator]
set tracefd       [open NewReno20.tr w]
set windowVsTime2 [open winnewreno20.tr w]
set namtrace      [open NewReno20.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)


# configure the nodes
        $ns node-config -adhocRouting $val(rp) \
             -llType $val(ll) \
             -macType $val(mac) \
             -ifqType $val(ifq) \
             -ifqLen $val(ifqlen) \
             -antType $val(ant) \
             -propType $val(prop) \
             -phyType $val(netif) \
             -channelType $val(chan) \
             -topoInstance $topo \
             -agentTrace ON \
             -routerTrace ON \
             -macTrace OFF \
             -movementTrace ON

    for {set i 0} {$i < $val(nn) } { incr i } {
        set node_($i) [$ns node]
        $node_($i) set X_ [ expr 10+round(rand()*1000) ]
        $node_($i) set Y_ [ expr 10+round(rand()*1000) ]
        $node_($i) set Z_ 0.0
    }

    for {set i 0} {$i < $val(nn) } { incr i } {
        $ns at 1.0 "$node_($i) setdest [ expr round(rand()*1000) ] [ expr round(rand()*1000) ] [ expr round(rand()*10) ]"
        
    }

#for {set i 0} {$i < $val(nn)} {incr i} {
#$node_($i) set X_ [expr rand()*$val(x)]
#$node_($i) set Y_ [expr rand()*$val(y)]
#$node_($i) set Z_ 0
#}
#******************Defining Mobility ************************#
# For mobility 300= movement x value, 100=movement y value, 50=speed in m/s
#$ns at 1.0 "$node_(0) setdest 600 500 10"
#*****************Defining Random Mobility *******************#
#Random mobility for all the nodes
#for { set i 1} {$i < $val(nn)} {incr i} {
#set xr [expr rand()*$val(x)]
#set yr [expr rand()*$val(y)]
#$ns at 1.0 "$node_($i) setdest $xr $yr 10"
#}



# Set a TCP connection between node_(1) and node_(5)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(4) $sink
$ns connect $tcp $sink
$tcp set packetSize_ 1500
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.01 "$ftp start"


# Printing the window size
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 0.01 "plotWindow $tcp $windowVsTime2"

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 25 defines the node size for nam
$ns initial_node_pos $node_($i) 25
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 60 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
}

$ns run
