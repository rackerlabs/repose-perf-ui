Feature: Network results Page
	In order to view network data
	As a performance test user
	I want to view the network test results

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with network nstat metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/nstat/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response
=begin
command: nstat
#kernel
IpInReceives                    133243             0.0
IpInDelivers                    133243             0.0
IpOutRequests                   92904              0.0
IcmpOutErrors                   97                 0.0
IcmpOutTimeExcds                97                 0.0
IcmpMsgOutType3                 97                 0.0
TcpActiveOpens                  538                0.0
TcpEstabResets                  56                 0.0
TcpInSegs                       129837             0.0
TcpOutSegs                      89720              0.0
TcpRetransSegs                  42                 0.0
TcpOutRsts                      704                0.0
UdpInDatagrams                  3255               0.0
UdpNoPorts                      97                 0.0
UdpOutDatagrams                 3270               0.0
Ip6OutNoRoutes                  206                0.0
TcpExtTW                        141                0.0
TcpExtDelayedACKs               508                0.0
TcpExtDelayedACKLocked          1                  0.0
TcpExtDelayedACKLost            42                 0.0
TcpExtTCPHPHits                 117659             0.0
TcpExtTCPPureAcks               2158               0.0
TcpExtTCPHPAcks                 605                0.0
TcpExtTCPSackRecovery           1                  0.0
TcpExtTCPLossUndo               16                 0.0
TcpExtTCPSackFailures           4                  0.0
TcpExtTCPFastRetrans            1                  0.0
TcpExtTCPSlowStartRetrans       3                  0.0
TcpExtTCPTimeouts               33                 0.0
TcpExtTCPDSACKOldSent           40                 0.0
TcpExtTCPDSACKRecv              5                  0.0
TcpExtTCPAbortOnData            120                0.0
TcpExtTCPAbortOnClose           55                 0.0
TcpExtTCPSackShiftFallback      9                  0.0
IpExtInOctets                   180131682          0.0
IpExtOutOctets                  7289106            0.0
=end

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with network ss metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/ss/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response
=begin
command: ss -s
Total: 786 (kernel 804)
TCP:   65 (estab 40, closed 7, orphaned 0, synrecv 0, timewait 6/0), ports 56
Transport Total     IP        IPv6
*	  804       -         -
RAW	  1         1         0
UDP	  12        9         3
TCP	  58        52        6
INET	  71        62        9
FRAG	  0         0         0
=end

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with network ss metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/ip/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response
=begin
command: ip -s link
1: lo:  mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast
    1444187    9960     0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1444187    9960     0       0       0       0
2: eth0:  mtu 1500 qdisc mq state UP qlen 1000
    link/ether b8:ac:6f:65:31:e5 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1221956483 991501   0       0       0       24
    TX: bytes  packets  errors  dropped carrier collsns
    75623937   720272   0       0       0       0
3: wlan0:  mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:21:6a:ca:9b:10 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    0          0        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    0          0        0       0       0       0
4: pan0:  mtu 1500 qdisc noop state DOWN
    link/ether 4a:c7:5f:0e:8e:d8 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    0          0        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    0          0        0       0       0       0
8: ppp0:  mtu 1496 qdisc pfifo_fast state UNKNOWN qlen 3
    link/ppp
    RX: bytes  packets  errors  dropped overrun mcast
    2419881    3848     0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    284151     4287     0       0       0       0
=end

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with network ss metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/sar/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response
=begin
command: sar -n DEV 1 3
Linux 2.6.32-220.2.1.el6.x86_64 (www.cyberciti.biz)    Tuesday 13 March 2012   _x86_64_        (2 CPU)
01:44:03  CDT     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
01:44:04  CDT        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
01:44:04  CDT      eth0    161.70    154.26    105.20     26.63      0.00      0.00      0.00
01:44:04  CDT      eth1    145.74    142.55     25.11    144.94      0.00      0.00      0.00
01:44:04  CDT     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
01:44:05  CDT        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
01:44:05  CDT      eth0    162.14    156.31    107.46     42.18      0.00      0.00      0.00
01:44:05  CDT      eth1    135.92    138.83     39.38    104.92      0.00      0.00      0.00
01:44:05  CDT     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
01:44:06  CDT        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
01:44:06  CDT      eth0    303.92    293.14    272.91     37.40      0.00      0.00      0.00
01:44:06  CDT      eth1    252.94    290.20     34.87    263.50      0.00      0.00      0.00
Average:        IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
Average:           lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:         eth0    210.37    202.34    163.19     35.66      0.00      0.00      0.00
Average:         eth1    178.93    191.64     33.36    171.60      0.00      0.00  
=end