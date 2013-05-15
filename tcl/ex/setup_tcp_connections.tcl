# source other files

source logging_app.tcl
source stat_collector.tcl

# TCP servers
for { set i 0 } { $i < $opt(num_tcp) } { incr i } {
  # Create TCP Agents with congestion control specified in opt(tcp)
  set tcp_server($i) [ new Agent/$opt(tcp) ]
  if { $opt(tcp) == "TCP/Linux" } {
    puts "TCP/Linux is buggy, exiting "
    exit 5
  }

  # Attach TCP Agent to basestation Node
  $ns attach-agent $basestation $tcp_server($i)

  # set flow id
  $tcp_server($i) set fid_ $counter
  set fid($i) $counter
  set counter [ incr counter ]

  # Attach source (such as FTP) to TCP Agent
  set src($fid($i)) [ $tcp_server($i) attach-source $opt(app) ]
}

# TCP clients
for { set i 0 } { $i < $opt(num_tcp) } { incr i } {
  # Create node corresponding to mobile user
  set tcp_client_node($i) [ $ns node ]

  # Create forward and reverse links from basestation to mobile user
  create_link $ns $opt(bottleneck_bw) $opt(bottleneck_latency) $basestation $tcp_client_node($i) $opt(bottleneck_qdisc) $fid($i)

  # Get handles to link and queue from basestation to user
  set cell_link [ [ $ns link $basestation $tcp_client_node($i) ] link ]
  set cell_queue [ [ $ns link $basestation $tcp_client_node($i) ] queue ]

  # All the non-standard queue neutering:
  neuter_queue $cell_queue

  # Set user_id and other stuff for SFD
  if { $opt(bottleneck_qdisc) == "SFD" } {
    setup_sfd $cell_queue $ensemble_scheduler
  }

  # Attach trace_file to queue.
  $ns trace-queue $basestation $tcp_client_node($i) $trace_file

  # Attach queue and link to ensemble_scheduler
  attach_to_scheduler $ensemble_scheduler $fid($i) $cell_queue $cell_link

  # Attach link to rate generator
  $rate_generator attach-link $cell_link $fid($i)

  # Create tcp sinks
  set tcp_client($i) [ new Agent/TCPSink/Sack1 ]
  $ns attach-agent $tcp_client_node($i) $tcp_client($i)

  # Create ON-OFF pattern if required
  if { $opt(enable_on_off) == "true" } {
    set onoff_server($i) [new LoggingApp $fid($i)]
    $onoff_server($i) attach-agent $tcp_client($i)
    $ns at 0.0 "$onoff_server($i) start"

    # start only the odd-numbered connections immediately
    if { [expr $i % 2] == 0 } {
      $onoff_server($i) go 0.0
    } else {
      $onoff_server($i) go [$onoff_server($i) sample_off_duration]
    }
  } else {
    $ns at 0.0 "$src($fid($i)) start"
  }

  # Connect them to their sources
  $ns connect $tcp_server($i) $tcp_client($i)
  set tcp_senders($fid($i)) $tcp_server($i)

  # Setup stat collector
  set stats($i) [new StatCollector $i $opt(tcp)]
}