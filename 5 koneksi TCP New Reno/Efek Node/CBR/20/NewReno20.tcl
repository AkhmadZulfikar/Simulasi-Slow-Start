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
set windowVsTime2 [open winnewreno20_1.tr w]
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



# pasang 1
set tcp [new Agent/TCP/Reno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(9) $sink
$ns connect $tcp $sink
$tcp set packetSize_ 1Mb

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp
$cbr set packetSize_ 1Mb
$cbr set rate_ 11.0Mb
$ns at 1.0 "$cbr start"
$ns at 60.0 "$cbr stop"


# pasang 2
set tcp1 [new Agent/TCP/Reno]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns attach-agent $node_(1) $tcp1
$ns attach-agent $node_(8) $sink1
$ns connect $tcp1 $sink1
$tcp1 set packetSize_ 1Mb

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $tcp1
$cbr1 set packetSize_ 1Mb
$cbr1 set rate_ 11.0Mb
$ns at 1.0 "$cbr1 start"
$ns at 60.0 "$cbr1 stop"


# pasang 3
set tcp3 [new Agent/TCP/Reno]
$tcp3 set class_ 2
set sink3 [new Agent/TCPSink]
$ns attach-agent $node_(2) $tcp3
$ns attach-agent $node_(7) $sink3
$ns connect $tcp3 $sink3
$tcp3 set packetSize_ 1Mb

set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $tcp3
$cbr3 set packetSize_ 1Mb
$cbr3 set rate_ 11.0Mb
$ns at 1.0 "$cbr3 start"
$ns at 60.0 "$cbr3 stop"


# pasang 4
set tcp4 [new Agent/TCP/Reno]
$tcp4 set class_ 2
set sink4 [new Agent/TCPSink]
$ns attach-agent $node_(3) $tcp4
$ns attach-agent $node_(6) $sink4
$ns connect $tcp4 $sink4
$tcp4 set packetSize_ 1Mb

set cbr4 [new Application/Traffic/CBR]
$cbr4 attach-agent $tcp4
$cbr4 set packetSize_ 1Mb
$cbr4 set rate_ 11.0Mb
$ns at 1.0 "$cbr4 start"
$ns at 60.0 "$cbr4 stop"



# pasang 5
set tcp5 [new Agent/TCP/Reno]
$tcp5 set class_ 2
set sink5 [new Agent/TCPSink]
$ns attach-agent $node_(4) $tcp5
$ns attach-agent $node_(5) $sink5
$ns connect $tcp5 $sink5
$tcp5 set packetSize_ 1Mb

set cbr5 [new Application/Traffic/CBR]
$cbr5 attach-agent $tcp5
$cbr5 set packetSize_ 1Mb
$cbr5 set rate_ 11.0Mb
$ns at 1.0 "$cbr5 start"
$ns at 60.0 "$cbr5 stop"


# Printing the window size
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 1.0 "plotWindow $tcp $windowVsTime2"

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
