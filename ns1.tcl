set val(chan)           Channel/WirelessChannel    
set val(prop)           Propagation/TwoRayGround   
set val(netif)          Phy/WirelessPhy            
set val(mac)            Mac/802_11                 
set val(ifq)            Queue/DropTail/PriQueue    
set val(ll)             LL                         
set val(ant)            Antenna/OmniAntenna        
set val(ifqlen)         50                         
set val(nn)             03                         
set val(rp)             AODV                       
set val(x)              500                        
set val(y)              400                       
set val(stop)           150                         

set ns [new simulator]


set tracefd [open out.tr w]
set namtrace [open out.nam w]
$ns trace-all $tracefd
$ns namtrace_all_wireless $namtrace $val(x) $val(y)

set topo [new topography]
$topo load_flatgrid $val(x) $val(y)
set god [create_god $val(nn)]







$ns node_config    -adhocrouting $val(rp) \
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
}

$node_(0)setx-50.0
$node_(0)sety-50.0
$node_(0)setz-0.0
$node_(1)setx-150.0
$node_(1)sety-50.0
$node_(1)setz-50.0
$node_(2)setx-300.0
$node_(2)sety-50.0
$node_(2)setz-50.0

set tcp0 [new Agent/TCP]
$ns attach-agent $node_(0) $tcp0
set sink0 [new Agent/TCPSink]

$ns attach-agent $node_(2) $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 3.0 "$ftp0 start"
$ns at 150.0 "$ftp0 stop"


for{set i 0{{$i<$val(nn)}{incr i}{
$ns_intial_node_pos $node_($i)50
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam wireless2.nam &
}
$ns run
